import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class CreateEventScreen extends StatefulWidget {
  final String token;
  final VoidCallback? onEventCreated;

  const CreateEventScreen({super.key, required this.token, this.onEventCreated});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  DateTime? _selectedDate;
  String _category = 'technical';
  bool isLoading = false;

  // Local events list (hardcoded + newly created)
  List<Map<String, String>> upcomingEvents = [
    {
      'title': 'Hackathon 2025',
      'description': 'A 24-hour coding marathon for innovators.',
      'venue': 'Auditorium A',
      'date': '2025-10-12 09:00 AM',
      'category': 'Technical'
    },
    {
      'title': 'Cultural Night',
      'description': 'Music, dance and arts performances.',
      'venue': 'Main Hall',
      'date': '2025-11-01 06:00 PM',
      'category': 'Cultural'
    },
    {
      'title': 'Intercollege Football',
      'description': 'Football competition among colleges.',
      'venue': 'Sports Ground',
      'date': '2025-11-20 04:00 PM',
      'category': 'Sports'
    },
  ];

  Future<void> createEvent() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://localhost:5000/api/events"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'venue': _venueController.text.trim(),
          'date': _selectedDate!.toIso8601String(),
          'category': _category,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Event created successfully")),
        );

        // Add new event to upcomingEvents list for live UI
        setState(() {
          upcomingEvents.insert(0, {
            'title': _titleController.text.trim(),
            'description': _descriptionController.text.trim(),
            'venue': _venueController.text.trim(),
            'date': _selectedDate!.toString(),
            'category': _category[0].toUpperCase() + _category.substring(1),
          });
        });

        widget.onEventCreated?.call();
        _formKey.currentState!.reset();
        _selectedDate = null;
      } else {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "❌ Failed to create event")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _selectedDate =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Event"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // --- FORM CARD ---
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: "Event Title",
                          prefixIcon: const Icon(Icons.title, color: Colors.deepPurple),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                        validator: (val) => val == null || val.isEmpty ? "Enter title" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "Description",
                          prefixIcon: const Icon(Icons.description, color: Colors.deepPurple),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                        validator: (val) => val == null || val.isEmpty ? "Enter description" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _venueController,
                        decoration: InputDecoration(
                          labelText: "Venue",
                          prefixIcon: const Icon(Icons.location_on, color: Colors.deepPurple),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                        validator: (val) => val == null || val.isEmpty ? "Enter venue" : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _category,
                        items: const [
                          DropdownMenuItem(value: 'technical', child: Text('💻 Technical')),
                          DropdownMenuItem(value: 'cultural', child: Text('🎭 Cultural')),
                          DropdownMenuItem(value: 'sports', child: Text('⚽ Sports')),
                        ],
                        onChanged: (val) => setState(() => _category = val!),
                        decoration: InputDecoration(
                          labelText: "Category",
                          prefixIcon: const Icon(Icons.category, color: Colors.deepPurple),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        tileColor: Colors.grey.shade100,
                        title: Text(
                          _selectedDate != null
                              ? "📅 ${_selectedDate!.toLocal()}"
                              : "Pick Date & Time",
                        ),
                        trailing: const Icon(Icons.calendar_month, color: Colors.deepPurple),
                        onTap: pickDate,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : createEvent,
                          icon: isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                              : const Icon(Icons.add),
                          label: const Text("Create Event"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Text("📌 Upcoming Events", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // --- Upcoming Events List ---
            ...upcomingEvents.map((event) {
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade100,
                    child: const Icon(Icons.event, color: Colors.deepPurple),
                  ),
                  title: Text(event['title'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "${event['description']}\n📍 ${event['venue']} | 📅 ${event['date']}",
                      style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                    ),
                  ),
                  isThreeLine: true,
                  trailing: Chip(
                    label: Text(event['category'] ?? ""),
                    backgroundColor: Colors.deepPurple.shade50,
                    labelStyle: const TextStyle(color: Colors.deepPurple),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventPreviewScreen(event: event),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}


class EventPreviewScreen extends StatelessWidget {
  final Map<String, String> event;

  const EventPreviewScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event['title'] ?? "Event"), backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event['title'] ?? "", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(event['description'] ?? "", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Row(children: [const Icon(Icons.location_on, color: Colors.deepPurple), const SizedBox(width: 6), Text(event['venue'] ?? "")]),
            const SizedBox(height: 12),
            Row(children: [const Icon(Icons.calendar_month, color: Colors.deepPurple), const SizedBox(width: 6), Text(event['date'] ?? "")]),
            const SizedBox(height: 20),
            Chip(label: Text(event['category'] ?? ""), backgroundColor: Colors.deepPurple.shade50, labelStyle: const TextStyle(color: Colors.deepPurple)),
          ],
        ),
      ),
    );
  }
}
