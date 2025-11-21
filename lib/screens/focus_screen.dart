import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart';
import '../services/focus_timer_service.dart';

class FocusScreen extends StatefulWidget {
  final String presetKey; // 'pomodoro','deep','custom','sprint'
  const FocusScreen({super.key, required this.presetKey});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  late int _totalSeconds;

  final Map<String, Duration> _presetDurations = {
    'pomodoro': const Duration(minutes: 25),
    'deep': const Duration(hours: 1),
    'custom': const Duration(minutes: 30),
    'sprint': const Duration(minutes: 15),
  };

  // Bright backgrounds per preset as requested
  final Map<String, Color> _backgrounds = {
    'pomodoro': const Color(0xFFFF4D4F), // red
    'deep': const Color(0xFF7C4DFF), // purple
    'custom': const Color(0xFFFFC107), // yellow (amber)
    'sprint': const Color(0xFFFFF176), // lemon yellow
  };

  // Ring / accent colors for each preset
  final Map<String, Color> _ringColors = {
    'pomodoro': const Color(0xFFFF6B6B),
    'deep': const Color(0xFF9C6BFF),
    'custom': const Color(0xFFFFD54F),
    'sprint': const Color(0xFFFFF59D),
  };

  @override
  void initState() {
    super.initState();
    _totalSeconds = (_presetDurations[widget.presetKey] ?? const Duration(minutes: 25)).inSeconds;

    // If there is already a session for this preset running, reuse it
    final svc = FocusTimerService.instance;
    if (svc.running) {
      // if different preset, start a new session for this screen
      if (svc.presetKey != widget.presetKey) {
        svc.startNewSession(widget.presetKey, _totalSeconds);
      }
    } else {
      svc.startNewSession(widget.presetKey, _totalSeconds);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _toggle() {
    final svc = FocusTimerService.instance;
    if (svc.running) {
      svc.pause();
    } else {
      svc.resume();
    }
  }

  String _formatSeconds(int seconds) {
    final d = Duration(seconds: seconds);
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      final hh = d.inHours.toString().padLeft(2, '0');
      return '$hh:$mm';
    }
    return '$mm:$ss';
  }

  double _progressFrom(int remaining) => _totalSeconds == 0 ? 0 : 1 - (remaining / _totalSeconds);

  Future<bool> _onWillPop() async {
    final svc = FocusTimerService.instance;
    if (svc.running && svc.remainingNotifier.value > 0) {
      final keep = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Keep running?'),
          content: const Text('A pomodoro is still running. Keep it running in background?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Stop')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Keep running')),
          ],
        ),
      );

      if (keep == true) {
        await svc.keepRunningInBackground();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigator()),
          (route) => false,
        );
        return false;
      }

      // user chose Stop or dismissed: stop and allow pop
      await svc.stop();
      return true;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final bg = _backgrounds[widget.presetKey] ?? Colors.black;
    final label = {
      'pomodoro': 'Pomodoro',
      'deep': 'Deep Work',
      'custom': 'Custom',
      'sprint': 'Sprint',
    }[widget.presetKey] ?? 'Focus';

    // Keep using WillPopScope for now; the newer PopScope API requires
    // different handler signatures. Suppress the deprecation warning here.
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 260,
                      height: 260,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ValueListenableBuilder<int>(
                            valueListenable: FocusTimerService.instance.remainingNotifier,
                            builder: (context, remaining, _) {
                              final progress = _progressFrom(remaining);
                              return SizedBox(
                                width: 260,
                                height: 260,
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 14,
                                  backgroundColor: Colors.white24,
                                  valueColor: AlwaysStoppedAnimation<Color>(_ringColors[widget.presetKey] ?? Colors.white),
                                ),
                              );
                            },
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ValueListenableBuilder<int>(
                                valueListenable: FocusTimerService.instance.remainingNotifier,
                                builder: (context, remaining, _) {
                                  return Text(
                                    _formatSeconds(remaining),
                                    style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                                  );
                                },
                              ),
                              const SizedBox(height: 6),
                              Text(label.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 12),
                              ValueListenableBuilder<bool>(
                                valueListenable: FocusTimerService.instance.isActive,
                                builder: (context, running, _) {
                                  return IconButton(
                                    onPressed: _toggle,
                                    iconSize: 34,
                                    color: Colors.white,
                                    icon: Icon(running ? Icons.pause_circle : Icons.play_circle_fill),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Keep focus — no distractions',
                      style: TextStyle(color: Colors.white.withAlpha((0.8 * 255).round())),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 12,
                top: 12,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () async {
                    final allow = await _onWillPop();
                    if (allow) Navigator.of(context).pop();
                  },
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white10,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  onPressed: () async {
                    final svc = FocusTimerService.instance;
                    if (svc.running && svc.remainingNotifier.value > 0) {
                      final keep = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Keep running?'),
                          content: const Text('A pomodoro is still running. Keep it running in background?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Stop')),
                            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Keep running')),
                          ],
                        ),
                      );

                      if (keep == true) {
                        await svc.keepRunningInBackground();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const MainNavigator()),
                          (route) => false,
                        );
                        return;
                      }

                      await svc.stop();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MainNavigator()),
                        (route) => false,
                      );
                      return;
                    }

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainNavigator()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home, color: Colors.white),
                  label: const Text('Home', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
