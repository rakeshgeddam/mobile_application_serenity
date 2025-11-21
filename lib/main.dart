import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/home_dashboard.dart';
import 'screens/stats.dart';
import 'screens/community.dart';
import 'screens/plan.dart';
import 'models/calendar_event.dart';
import 'widgets/custom_bottom_nav_bar.dart';
import 'services/focus_timer_service.dart';
import 'services/event_schedule_service.dart';

// Entry point for Riverpod
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register the CalendarEvent adapter
  Hive.registerAdapter(CalendarEventAdapter());

  // Open the Hive box for calendar events
  await Hive.openBox<CalendarEvent>('calendarEvents');

  // Initialize focus timer service (loads persisted session if any)
  await FocusTimerService.instance.init();
  // Initialize event scheduling service (pre-schedules next few days)
  await EventScheduleService.instance.init(daysToPreSchedule: 3);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Productivity App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: const Color.fromARGB(229, 212, 245, 250),
      ),
      home: const MainNavigator(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// You can place this in widgets/bottom_nav_bar.dart for reuse
class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;
  final List<Widget> _screens = const [
    HomeDashboardScreen(),
    PlanScreen(),
    StatsScreen(),
    CommunityScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTabSelected: _onTabTapped,
        floating: true,
      ),
    );
  }
}
