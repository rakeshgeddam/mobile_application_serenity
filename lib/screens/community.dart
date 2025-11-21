import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/community_models.dart';
import '../models/calendar_event.dart';
import '../services/community_service.dart';
import '../services/event_schedule_service.dart';
import 'wrapper.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CommunityService _service;
  
  // Calendar state
  DateTime _selectedDate = DateTime.now();
  late DateTime _startOfWeek;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _service = CommunityService.instance;
    _service.init(); // Ensure data is loaded
    
    // Calculate start of week (Monday)
    final now = DateTime.now();
    _startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    // Strip time
    _startOfWeek = DateTime(_startOfWeek.year, _startOfWeek.month, _startOfWeek.day);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _joinEvent(CommunityEvent event) async {
    // Add to Calendar Hive Box
    final box = Hive.box<CalendarEvent>('calendarEvents');
    
    // Check if already exists (simple check by ID or title/time)
    final exists = box.values.any((e) => 
      e.title == event.title && e.startTime == event.startTime
    );

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event already in your calendar!'))
      );
      return;
    }

    final calendarEvent = CalendarEvent(
      id: DateTime.now().toIso8601String(),
      title: event.title,
      startTime: event.startTime,
      endTime: event.endTime,
      color: event.color.value.toRadixString(16).padLeft(8, '0'),
      type: 'Community',
      notes: event.description,
      recurringInfo: '',
      desiredFocusProfile: '', // User can edit later to add focus
      notificationInfo: null,
      isSynced: true,
    );

    await box.add(calendarEvent);
    EventScheduleService.instance.rescheduleNextNDays(3);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Joined "${event.title}"! Added to calendar.'))
    );
  }

  void _scheduleHobby(Hobby hobby) async {
    // Show date/time picker to schedule a session
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context, 
      initialDate: now, 
      firstDate: now, 
      lastDate: now.add(const Duration(days: 365))
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context, 
      initialTime: const TimeOfDay(hour: 18, minute: 0)
    );
    if (time == null) return;

    final startDT = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final endDT = startDT.add(const Duration(hours: 1)); // Default 1 hour

    final box = Hive.box<CalendarEvent>('calendarEvents');
    final calendarEvent = CalendarEvent(
      id: DateTime.now().toIso8601String(),
      title: hobby.name,
      startTime: startDT,
      endTime: endDT,
      color: hobby.color.value.toRadixString(16).padLeft(8, '0'),
      type: 'Hobby',
      notes: 'Hobby session for ${hobby.name}',
      recurringInfo: '',
      desiredFocusProfile: 'custom', // Default to custom focus
      notificationInfo: null,
      isSynced: false,
    );

    await box.add(calendarEvent);
    EventScheduleService.instance.rescheduleNextNDays(3);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Scheduled "${hobby.name}" session!'))
    );
  }

  void _suggestEvent() {
    // Simple dialog to suggest event
    final _formKey = GlobalKey<FormState>();
    String title = '';
    String desc = '';
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Suggest Community Event'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Event Title'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => title = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (v) => desc = v ?? '',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                final newEvent = CommunityEvent(
                  id: 'p_${DateTime.now().millisecondsSinceEpoch}',
                  title: title,
                  description: desc,
                  startTime: DateTime.now().add(const Duration(days: 7)), // Mock date
                  endTime: DateTime.now().add(const Duration(days: 7, hours: 2)),
                  location: 'TBD',
                  isProposed: true,
                );
                setState(() {
                  _service.proposeEvent(newEvent);
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Event suggested! It is now in Proposed Events.'))
                );
              }
            },
            child: const Text('Suggest'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double navReserve = MediaQuery.of(context).viewPadding.bottom + 80.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        title: const Text('Community', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF547E74),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF547E74),
          tabs: const [
            Tab(text: 'Local Events'),
            Tab(text: 'My Hobbies'),
          ],
        ),
      ),
      body: AppResponsiveContainer(
        child: Padding(
          padding: EdgeInsets.only(bottom: navReserve),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildEventsTab(),
              _buildHobbiesTab(),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF547E74),
          onPressed: () {
            if (_tabController.index == 0) {
              _suggestEvent();
            } else {
              // Add hobby logic (omitted for brevity, similar to suggest event)
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create Hobby feature coming soon!')));
            }
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEventsTab() {
    final events = _service.getEventsForWeek(_startOfWeek);
    final proposed = _service.getProposedEvents();
    
    // Filter for selected date
    final dayEvents = events.where((e) => 
      e.startTime.year == _selectedDate.year &&
      e.startTime.month == _selectedDate.month &&
      e.startTime.day == _selectedDate.day
    ).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Week Calendar
          Container(
            height: 90,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final date = _startOfWeek.add(Duration(days: index));
                final isSelected = date.year == _selectedDate.year && 
                                   date.month == _selectedDate.month && 
                                   date.day == _selectedDate.day;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = date),
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF547E74) : const Color(0xFFF5F7F8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(date),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Events for Selected Day', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          
          if (dayEvents.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('No events scheduled for this day.', style: TextStyle(color: Colors.grey)),
            )
          else
            ...dayEvents.map((e) => _buildEventCard(e)).toList(),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('Proposed Events', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          
          if (proposed.isEmpty)
             const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('No proposed events.', style: TextStyle(color: Colors.grey)),
            )
          else
            ...proposed.map((e) => _buildEventCard(e, isProposed: true)).toList(),
            
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildEventCard(CommunityEvent e, {bool isProposed = false}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: isProposed ? Colors.purple[50] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: e.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('h:mm a').format(e.startTime)} - ${e.location}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  if (isProposed)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text('PROPOSED', style: TextStyle(color: Colors.purple, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
            if (!isProposed)
              ElevatedButton(
                onPressed: () => _joinEvent(e),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD7EDD4),
                  foregroundColor: Colors.green[800],
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Size(60, 30),
                ),
                child: const Text('Join'),
              )
            else
               IconButton(
                 icon: const Icon(Icons.thumb_up_outlined, size: 20, color: Colors.purple),
                 onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voted for event!')));
                 },
               ),
          ],
        ),
      ),
    );
  }

  Widget _buildHobbiesTab() {
    final hobbies = _service.getHobbies();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: hobbies.length,
      itemBuilder: (context, index) {
        final h = hobbies[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(h.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.calendar_month, color: Color(0xFF547E74)),
                      onPressed: () => _scheduleHobby(h),
                      tooltip: 'Schedule Session',
                    ),
                  ],
                ),
                Text(h.description, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${h.currentProgressMinutes} / ${h.weeklyGoalMinutes} min', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${(h.progress * 100).toInt()}%', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: h.progress,
                  backgroundColor: Colors.grey[200],
                  color: h.color,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
