import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'wrapper.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int activeTab = 0; // 0: Analytics, 1: Preferences, 2: Account
  late Box _historyBox;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    _historyBox = await Hive.openBox('focusHistory');
    if (mounted) setState(() => _loading = false);
  }

  Map<String, dynamic> _calculateStats() {
    if (_loading) return {'totalHours': 0.0, 'weekTrend': 0.0, 'dailyData': List.filled(7, 0.0)};

    double totalSeconds = 0;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    
    // 0=Mon, 6=Sun
    List<double> dailyData = List.filled(7, 0.0);

    for (var item in _historyBox.values) {
      if (item is Map) {
        final duration = (item['duration'] as int?) ?? 0;
        final timestamp = (item['timestamp'] as int?) ?? 0;
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);

        totalSeconds += duration;

        if (date.isAfter(startOfWeek) && date.isBefore(endOfWeek)) {
          final dayIndex = date.weekday - 1; // Mon=1 -> 0
          if (dayIndex >= 0 && dayIndex < 7) {
            dailyData[dayIndex] += (duration / 3600.0); // Hours
          }
        }
      }
    }

    return {
      'totalHours': totalSeconds / 3600.0,
      'weekTrend': 0.0, // Placeholder for trend calculation
      'dailyData': dailyData,
    };
  }

  @override
  Widget build(BuildContext context) {
    final double navReserve = MediaQuery.of(context).viewPadding.bottom + 80.0;
    final stats = _calculateStats();
    final totalHours = (stats['totalHours'] as double).toStringAsFixed(1);
    final dailyData = stats['dailyData'] as List<double>;

    final inner = AppResponsiveContainer(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, navReserve),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header
              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFFD7EDD4),
                    child: Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Alex Doe", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text("Cultivating focus & well-being.", style: TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 13),
              // Edit profile button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFD7EDD4),
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 10),

              // Tabs
              Row(
                children: [
                  _tabButton("Analytics", 0),
                  _tabButton("Preferences", 1),
                  _tabButton("Account", 2),
                ],
              ),
              const SizedBox(height: 8),

              // Analytics Tab
              if (activeTab == 0) ...[
                // Focus Time Trends
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7EDD4),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.all(14),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Focus Time Trends", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text("$totalHours hours", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                      const Text("Total Focus Time", style: TextStyle(fontSize: 13)),
                      const SizedBox(height: 13),
                      SizedBox(
                        height: 90,
                        child: BarChart(
                          BarChartData(
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                    if (value.toInt() >= 0 && value.toInt() < 7) {
                                      return Text(days[value.toInt()], style: const TextStyle(fontSize: 10));
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            barGroups: List.generate(7, (index) {
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: dailyData[index],
                                    color: Colors.green[700],
                                    width: 12,
                                    borderRadius: BorderRadius.circular(4),
                                  )
                                ],
                              );
                            }),
                            gridData: FlGridData(show: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 13),
                // Well-being Score (Placeholder for now)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7EDD4),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.all(14),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Well-being Score", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      const Text("8.2/10", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                      const Text("Based on consistency", style: TextStyle(fontSize: 13)),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 70,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: LineChart(
                            LineChartData(
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(show: false),
                              gridData: FlGridData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    FlSpot(0, 7),
                                    FlSpot(1, 7.5),
                                    FlSpot(2, 6.5),
                                    FlSpot(3, 7.9),
                                    FlSpot(4, 8),
                                    FlSpot(5, 8.8),
                                    FlSpot(6, 8.5),
                                    FlSpot(7, 8.7),
                                    FlSpot(8, 8.2),
                                  ],
                                  color: Colors.green[800],
                                  barWidth: 3,
                                  isCurved: true,
                                  dotData: FlDotData(show: false),
                                ),
                              ],
                              minY: 6,
                              maxY: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Placeholders for other tabs
              if (activeTab == 1)
                const Center(child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text('Preferences coming soon...'))),
              if (activeTab == 2)
                const Center(child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text('Account coming soon...'))),
              const Spacer(),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: inner,
    );
  }

  // Tab button widget
  Widget _tabButton(String text, int idx) {
    final isActive = (activeTab == idx);
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ElevatedButton(
        onPressed: () => setState(() => activeTab = idx),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: isActive ? Colors.black : Colors.black54,
          backgroundColor: isActive ? const Color(0xFFF5F7F8) : const Color(0xFFECEDED),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          minimumSize: const Size(85, 34),
        ),
        child: Text(text, style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}
