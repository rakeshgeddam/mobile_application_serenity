import 'package:hive/hive.dart';

part 'calendar_event.g.dart';

@HiveType(typeId: 0)
class CalendarEvent extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime startTime;

  @HiveField(3)
  final DateTime endTime;

  @HiveField(4)
  final String color;

  @HiveField(5)
  final String type;

  @HiveField(6)
  final String notes;

  @HiveField(7)
  final String recurringInfo;

  @HiveField(8)
  final String desiredFocusProfile;

  @HiveField(9)
  final String? notificationInfo;

  @HiveField(10)
  final bool isSynced;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.type,
    required this.notes,
    required this.recurringInfo,
    required this.desiredFocusProfile,
    this.notificationInfo,
    this.isSynced = false,
  });
}
