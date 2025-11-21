import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../platform/focus_handler.dart';

class FocusTimerService with ChangeNotifier {
  FocusTimerService._internal();
  static final FocusTimerService instance = FocusTimerService._internal();

  late Box _box;
  late Box _historyBox;

  String? presetKey;
  int totalSeconds = 0;
  int remainingSeconds = 0;
  bool running = false;

  Timer? _timer;

  // Notifiers for UI
  final ValueNotifier<bool> isActive = ValueNotifier(false);
  final ValueNotifier<int> remainingNotifier = ValueNotifier(0);

  Future<void> init() async {
    _box = await Hive.openBox('focusBox');
    _historyBox = await Hive.openBox('focusHistory');
    _loadFromBox();
  }

  void _loadFromBox() {
    final data = _box.get('current');
    if (data is Map) {
      try {
        presetKey = data['presetKey'] as String?;
        totalSeconds = (data['totalSeconds'] as int?) ?? 0;
        remainingSeconds = (data['remainingSeconds'] as int?) ?? 0;
        running = (data['running'] as bool?) ?? false;
        if (running && remainingSeconds > 0) {
          _startTimer();
        } else {
          _clearPersisted();
        }
        remainingNotifier.value = remainingSeconds;
        isActive.value = running && remainingSeconds > 0;
      } catch (_) {
        _clearPersisted();
      }
    }
  }

  Future<void> startNewSession(String preset, int seconds) async {
    presetKey = preset;
    totalSeconds = seconds;
    remainingSeconds = seconds;
    running = true;
    remainingNotifier.value = remainingSeconds;
    isActive.value = true;
    await _persist();
    _startTimer();
    
    // Trigger platform focus
    final end = DateTime.now().add(Duration(seconds: seconds));
    await FocusHandler.instance().startFocus(
      profile: preset,
      title: 'Focus: $preset',
      start: DateTime.now(),
      end: end,
      eventId: 'timer_${DateTime.now().millisecondsSinceEpoch}',
    );
    
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (remainingSeconds <= 1) {
        t.cancel();
        running = false;
        remainingSeconds = 0;
        isActive.value = false;
        remainingNotifier.value = 0;
        
        // Save session history
        _saveSession(totalSeconds);
        
        await _clearPersisted();
        
        // Stop platform focus
        await FocusHandler.instance().stopFocus();
        
        notifyListeners();
        return;
      }
      remainingSeconds = remainingSeconds - 1;
      remainingNotifier.value = remainingSeconds;
      await _persist();
    });
  }

  Future<void> pause() async {
    _timer?.cancel();
    running = false;
    isActive.value = false;
    await _persist();
    
    // Stop platform focus on pause
    await FocusHandler.instance().stopFocus();
    
    notifyListeners();
  }

  Future<void> resume() async {
    if (remainingSeconds <= 0) return;
    running = true;
    isActive.value = true;
    await _persist();
    _startTimer();
    
    // Resume platform focus
    final end = DateTime.now().add(Duration(seconds: remainingSeconds));
    await FocusHandler.instance().startFocus(
      profile: presetKey ?? 'Focus',
      title: 'Focus: ${presetKey ?? 'Resume'}',
      start: DateTime.now(),
      end: end,
      eventId: 'timer_resume_${DateTime.now().millisecondsSinceEpoch}',
    );
    
    notifyListeners();
  }

  Future<void> stop() async {
    _timer?.cancel();
    running = false;
    remainingSeconds = 0;
    isActive.value = false;
    remainingNotifier.value = 0;
    await _clearPersisted();
    
    // Stop platform focus
    await FocusHandler.instance().stopFocus();
    
    notifyListeners();
  }

  // Called when user chooses to keep running while leaving the screen
  Future<void> keepRunningInBackground() async {
    // Ensure running is true and persisted; timer should already be running
    running = true;
    isActive.value = true;
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      await _box.put('current', {
        'presetKey': presetKey,
        'totalSeconds': totalSeconds,
        'remainingSeconds': remainingSeconds,
        'running': running,
      });
    } catch (_) {}
  }

  Future<void> _clearPersisted() async {
    try {
      await _box.delete('current');
    } catch (_) {}
  }

  Future<void> _saveSession(int durationSeconds) async {
    try {
      final session = {
        'presetKey': presetKey,
        'duration': durationSeconds,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await _historyBox.add(session);
    } catch (_) {}
  }
}
