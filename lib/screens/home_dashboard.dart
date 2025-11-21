import 'package:flutter/material.dart';
import 'wrapper.dart';
import 'focus_screen.dart';
import '../widgets/focus_timer_card.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Core colors (update to match your theme)
    const bgColor = Color.fromARGB(229, 212, 245, 250);
    final double navReserve = MediaQuery.of(context).viewPadding.bottom + 80.0;

    final bodyContent = AppResponsiveContainer(
      child: Padding(
        padding: EdgeInsets.only(bottom: navReserve),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: weather and avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.wb_sunny_outlined, size: 20),
                      SizedBox(width: 4),
                      Text("68°F", style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color.fromARGB(155, 70, 241, 201),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Greeting & Date
              const Text(
                "Monday, October 28",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                "Good morning, Alex",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),

              // "Ready to focus?" card (tap to open FocusScreen)
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _FocusNavLauncher()));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB0DDDF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Card Left
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Ready to focus?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                          Text("High energy\npredicted", style: TextStyle(fontSize: 13)),
                        ],
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Colors.black54),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // "Your next small step" card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7F8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(0xFFDDE0E4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Your next small step", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    const SizedBox(height: 6),
                    const Text("Draft the project kickoff email", style: TextStyle(fontSize: 14)),
                    // Progress bar
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.6, // Dummy progress
                      minHeight: 7,
                      color: const Color(0xFF6E8480),
                      backgroundColor: const Color(0xFFDFE4E8),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB0DDDF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        ),
                        child: const Text("Complete Task", style: TextStyle(color: Color(0xFF6E8480), fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),

              // Volunteer Event card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7F8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(0xFFDDE0E4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card left side
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(0xFFF5A257).withAlpha((0.18 * 255).round()),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('High Trust', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 11)),
                          ),
                          const SizedBox(height: 7),
                          const Text('Local Volunteer Event', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 3),
                          const Text('Park cleanup at Green\nMeadows this Saturday.', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    // Card right side: Interested button
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5A257),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: const Text("Inter...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Floating basket button (bottom right)
              Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: () {},
                  backgroundColor: const Color.fromARGB(155, 70, 241, 201),
                  elevation: 0,
                  child: const Icon(Icons.shopping_basket_rounded, size: 28, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: bgColor,
      body: bodyContent,
    );
  }
}

// Small launcher widget screen to choose a preset before opening the focus timer.
class _FocusNavLauncher extends StatelessWidget {
  const _FocusNavLauncher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1720),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text('Start Focus')),
      body: SafeArea(
        child: Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              FocusTimerCard(
                title: 'Pomodoro',
                subtitle: '25:00',
                keyName: 'pomodoro',
                background: const Color(0xFFFF4D4F),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FocusScreen(presetKey: 'pomodoro'))),
              ),
              FocusTimerCard(
                title: 'Deep Work',
                subtitle: '60:00',
                keyName: 'deep',
                background: const Color(0xFF7C4DFF),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FocusScreen(presetKey: 'deep'))),
              ),
              FocusTimerCard(
                title: 'Custom',
                subtitle: '30:00',
                keyName: 'custom',
                background: const Color(0xFFFFC107),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FocusScreen(presetKey: 'custom'))),
              ),
              FocusTimerCard(
                title: 'Sprint',
                subtitle: '15:00',
                keyName: 'sprint',
                background: const Color(0xFFFFF176),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FocusScreen(presetKey: 'sprint'))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/*
import 'package:flutter/material.dart';
import 'wrapper.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'plan.dart';
import 'stats.dart';
import 'community.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  void _onTabSelected(BuildContext context, int idx) {
    if (idx == 0) return; // already on home
    Widget page;
    switch (idx) {
      case 1:
        page = const PlanScreen();
        break;
      case 2:
        page = const StatsScreen();
        break;
      case 3:
        page = const CommunityScreen();
        break;
      default:
        return;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    // Core colors (update to match your theme)
    const bgColor = Color(0xFFFDFDFD);
    const cardColor = Color(0xFFF5F7F8);
    const accentBlue = Color(0xFFB0DDDF);
    const buttonBlue = Color(0xFF6E8480);
    const progressBarColor = Color(0xFF6E8480);
    const orange = Color(0xFFF5A257);
    const accentGreen = Color(0xFF547E74);

    return Scaffold(
      backgroundColor: bgColor,
      body: AppResponsiveContainer(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Center(
            // Center all content (including on tablets)
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              // Main padding for all sides
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: weather and avatar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.wb_sunny_outlined, size: 20),
                          SizedBox(width: 4),
                          Text("68°F", style: TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: accentGreen,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Greeting & Date
                  const Text(
                    "Monday, October 28",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Good morning, Alex",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 18),

                  // "Ready to focus?" card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: accentBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Card Left
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Ready to focus?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                            Text("High energy\npredicted", style: TextStyle(fontSize: 13)),
                          ],
                        ),
                        // Card Right: Start Focus Session Button
                        // ElevatedButton(
                        //   onPressed: () {},
                        //   style: ElevatedButton.styleFrom(
                        //     backgroundColor: buttonBlue,
                        //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        //     elevation: 0,
                        //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        //   ),
                        //   child: const Text("Start Focus Ses...", style: TextStyle(fontWeight: FontWeight.w600)),
                        // ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // "Your next small step" card
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Color(0xFFDDE0E4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Your next small step", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                        const SizedBox(height: 6),
                        const Text("Draft the project kickoff email", style: TextStyle(fontSize: 14)),
                        // Progress bar
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: 0.6, // Dummy progress
                          minHeight: 7,
                          color: progressBarColor,
                          backgroundColor: Color(0xFFDFE4E8),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentBlue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            ),
                            child: const Text("Complete Task", style: TextStyle(color: buttonBlue, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Volunteer Event card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Color(0xFFDDE0E4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card left side
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                      color: orange.withAlpha((0.18 * 255).round()),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('High Trust', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 11)),
                              ),
                              const SizedBox(height: 7),
                              const Text('Local Volunteer Event', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 3),
                              const Text('Park cleanup at Green\nMeadows this Saturday.', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                        // Card right side: Interested button
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: orange,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          child: const Text("Inter...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Floating basket button (bottom right)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton(
                      onPressed: () {},
                      backgroundColor: accentGreen,
                      elevation: 0,
                      child: const Icon(Icons.shopping_basket_rounded, size: 28, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
          ),
        ),
      ),
    );
  }
}
*/