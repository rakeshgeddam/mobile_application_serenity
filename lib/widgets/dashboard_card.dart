import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  const DashboardCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(title),
    ));
  }
}
