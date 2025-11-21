import 'package:flutter/material.dart';
import '../screens/calendar_screen.dart'; // Import event model

// Widget for displaying a single event
class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: event.color.withAlpha((0.4 * 255).round()),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: event.color,
          child: Icon(event.icon, color: Colors.black87),
        ),
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          "${event.description} "
          "\n${event.startTime.format(context)} - ${event.endTime.format(context)}",
        ),
        // Tapping handled by parent; you can add trailing actions here later
      ),
    );
  }
}
