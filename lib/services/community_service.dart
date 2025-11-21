import 'package:flutter/material.dart';
import '../models/community_models.dart';

class CommunityService extends ChangeNotifier {
  CommunityService._internal();
  static final CommunityService instance = CommunityService._internal();

  final List<CommunityEvent> _events = [];
  final List<CommunityEvent> _proposedEvents = [];
  final List<Hobby> _hobbies = [];

  // Initialize with some dummy data
  void init() {
    final now = DateTime.now();
    
    // Official Events
    _events.addAll([
      CommunityEvent(
        id: '1',
        title: 'Morning Yoga in the Park',
        description: 'Start your day with a refreshing yoga session.',
        startTime: DateTime(now.year, now.month, now.day, 7, 0),
        endTime: DateTime(now.year, now.month, now.day, 8, 0),
        location: 'Central Park',
        attendeesCount: 12,
        color: Colors.teal,
      ),
      CommunityEvent(
        id: '2',
        title: 'Coding Meetup',
        description: 'Discuss latest tech trends and network.',
        startTime: DateTime(now.year, now.month, now.day, 18, 0),
        endTime: DateTime(now.year, now.month, now.day, 20, 0),
        location: 'Tech Hub',
        attendeesCount: 25,
        color: Colors.indigo,
      ),
      CommunityEvent(
        id: '3',
        title: 'Weekend Hike',
        description: 'A scenic hike through the trails.',
        startTime: DateTime(now.year, now.month, now.day + 2, 9, 0),
        endTime: DateTime(now.year, now.month, now.day + 2, 13, 0),
        location: 'Blue Hills',
        attendeesCount: 8,
        color: Colors.green,
      ),
    ]);

    // Proposed Events
    _proposedEvents.addAll([
      CommunityEvent(
        id: 'p1',
        title: 'Book Club: Sci-Fi',
        description: 'Reading "Dune" this month.',
        startTime: DateTime(now.year, now.month, now.day + 3, 19, 0),
        endTime: DateTime(now.year, now.month, now.day + 3, 21, 0),
        location: 'City Library',
        attendeesCount: 3,
        isProposed: true,
        color: Colors.purple,
      ),
    ]);

    // Hobbies
    _hobbies.addAll([
      Hobby(
        id: 'h1',
        name: 'Guitar Practice',
        description: 'Learn new chords and songs.',
        weeklyGoalMinutes: 120,
        currentProgressMinutes: 45,
        color: Colors.orange,
      ),
      Hobby(
        id: 'h2',
        name: 'Reading',
        description: 'Read 30 pages daily.',
        weeklyGoalMinutes: 210,
        currentProgressMinutes: 90,
        color: Colors.blueAccent,
      ),
    ]);
  }

  List<CommunityEvent> getEventsForWeek(DateTime startOfWeek) {
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return _events.where((e) => 
      e.startTime.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) && 
      e.startTime.isBefore(endOfWeek)
    ).toList();
  }

  List<CommunityEvent> getProposedEvents() {
    return List.unmodifiable(_proposedEvents);
  }

  List<Hobby> getHobbies() {
    return List.unmodifiable(_hobbies);
  }

  void proposeEvent(CommunityEvent event) {
    _proposedEvents.add(event);
    notifyListeners();
  }

  void addHobby(Hobby hobby) {
    _hobbies.add(hobby);
    notifyListeners();
  }
  
  // "Join" logic could be handled here or in UI to add to calendar
  // For now, we just return the event to confirm
  CommunityEvent? joinEvent(String eventId) {
    try {
      return _events.firstWhere((e) => e.id == eventId);
    } catch (_) {
      return null;
    }
  }
}
