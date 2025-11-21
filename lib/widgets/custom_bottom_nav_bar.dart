import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/focus_timer_service.dart';

class CustomBottomNavBar extends StatelessWidget {
  // Current selected tab index and callback
  final int currentIndex;
  final Function(int) onTabSelected;
  // final Color backgroundColor;
  // When true, the nav renders with floating visuals (rounded pill, shadow)
  final bool floating;
  // Horizontal margin when floating
  final double horizontalMargin;
  // Bottom margin when floating
  final double bottomMargin;

  // final Color color;
  // Border radius for the nav bar
  // final double borderRadius;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    // this.color = const Color.fromARGB(218, 23, 17, 17),
    // this.backgroundColor = const Color.fromARGB(218, 23, 17, 17),
    this.floating = true,
    this.horizontalMargin = 8.0,
    this.bottomMargin = 4.0,
    // this.borderRadius = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    List<_NavTab> tabs = [
      _NavTab(label: 'Home', icon: Icons.home_outlined),
      _NavTab(label: 'Plan', icon: Icons.calendar_month_outlined),
      // _NavTab(label: 'Stats', icon: Icons.bar_chart_outlined),
      _NavTab(label: 'Community', icon: Icons.people_outline),
    ];

    // Prefer outlined / lighter icon variants when available to achieve a thinner look.
    final Map<String, IconData> thinIconMap = {
      'Home': Icons.home_outlined,
      'Plan': Icons.calendar_month_outlined,
      // 'Stats': Icons.bar_chart_outlined,
      'Community': Icons.people_outline,
    };

    final widget = ClipRRect(
      borderRadius: floating ? BorderRadius.circular(28) : const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(246, 235, 243, 1).withValues(alpha: 95),
            borderRadius: floating ? BorderRadius.circular(28) : null,
            boxShadow: floating
                ? [
                    BoxShadow(
                      color: const Color.fromARGB(245, 20, 20, 20).withValues(alpha: 80),
                      blurRadius: 36,
                      offset: const Offset(0, 36),
                    )
                  ]
                : [],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(tabs.length, (i) {
              final isActive = i == currentIndex;
              return GestureDetector(
                onTap: () => onTabSelected(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isActive
                      ? const Color.fromARGB(255, 37, 36, 36).withValues( alpha:0.50)
                      : Colors.white.withValues( alpha:0.0),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: isActive
                        ? [BoxShadow(
                            color: Colors.black.withValues( alpha:0.30),
                            blurRadius: 20,
                            offset: const Offset(0, 3)
                          )]
                        : [],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      if (i == 0)
                        // Show a small badge when a focus session is active
                        ValueListenableBuilder<bool>(
                          valueListenable: FocusTimerService.instance.isActive,
                          builder: (context, isActiveSession, _) {
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(
                                  thinIconMap[tabs[i].label] ?? tabs[i].icon,
                                  blendMode: BlendMode.srcOver,
                                  color: isActive ? Colors.white : Colors.grey[800]!.withValues(alpha: 0.78),
                                  size: 16,
                                ),
                                if (isActiveSession)
                                  Positioned(
                                    right: -6,
                                    top: -6,
                                        child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                        boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.2 * 255).round()), blurRadius: 4)],
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        )
                      else
                        Icon(
                          thinIconMap[tabs[i].label] ?? tabs[i].icon,
                          blendMode: BlendMode.srcOver,
                          color: isActive ? Colors.white : Colors.grey[800]!.withValues(alpha: 0.78),
                          size: 16,
                        ),
                      const SizedBox(width: 7),
                      if (isActive)
                        Text(
                          tabs[i].label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                            fontSize: 15,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );

    if (floating) {
      return Padding(
        padding: EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, bottomMargin),
        child: widget,
      );
    }

    return widget;
  }
}

class _NavTab {
  final String label;
  final IconData icon;
  _NavTab({required this.label, required this.icon});
}
