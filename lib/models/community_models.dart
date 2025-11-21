import 'package:flutter/material.dart';

class CommunityEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final int attendeesCount;
  final bool isProposed; // true if suggested by user and not yet official
  final Color color;

  CommunityEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.attendeesCount = 0,
    this.isProposed = false,
    this.color = Colors.blue,
  });
}

class Hobby {
  final String id;
  final String name;
  final String description;
  final int weeklyGoalMinutes;
  final int currentProgressMinutes;
  final Color color;

  Hobby({
    required this.id,
    required this.name,
    required this.description,
    required this.weeklyGoalMinutes,
    this.currentProgressMinutes = 0,
    this.color = Colors.orange,
  });
  
  double get progress => (weeklyGoalMinutes == 0) ? 0 : (currentProgressMinutes / weeklyGoalMinutes).clamp(0.0, 1.0);
}
