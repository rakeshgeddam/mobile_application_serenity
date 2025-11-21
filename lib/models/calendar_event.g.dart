// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CalendarEventAdapter extends TypeAdapter<CalendarEvent> {
  @override
  final int typeId = 0;

  @override
  CalendarEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CalendarEvent(
      id: fields[0] as String,
      title: fields[1] as String,
      startTime: fields[2] as DateTime,
      endTime: fields[3] as DateTime,
      color: fields[4] as String,
      type: fields[5] as String,
      notes: fields[6] as String,
      recurringInfo: fields[7] as String,
      desiredFocusProfile: fields[8] as String,
      notificationInfo: fields[9] as String?,
      isSynced: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CalendarEvent obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.color)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.recurringInfo)
      ..writeByte(8)
      ..write(obj.desiredFocusProfile)
      ..writeByte(9)
      ..write(obj.notificationInfo)
      ..writeByte(10)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
