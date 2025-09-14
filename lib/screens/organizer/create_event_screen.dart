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

  Future<void> createEvent() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
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
          const SnackBar(content: Text("Event created successfully")),
        );
        widget.onEventCreated?.call(); // Trigger refresh in MyEventsScreen
        Navigator.pop(context);
      } else {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Failed to create event")),
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
          _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
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
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (val) => val == null || val.isEmpty ? "Enter title" : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                validator: (val) => val == null || val.isEmpty ? "Enter description" : null,
              ),
              TextFormField(
                controller: _venueController,
                decoration: const InputDecoration(labelText: "Venue"),
                validator: (val) => val == null || val.isEmpty ? "Enter venue" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                items: const [
                  DropdownMenuItem(value: 'technical', child: Text('Technical')),
                  DropdownMenuItem(value: 'cultural', child: Text('Cultural')),
                  DropdownMenuItem(value: 'sports', child: Text('Sports')),
                ],
                onChanged: (val) => setState(() => _category = val!),
                decoration: const InputDecoration(labelText: "Category"),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_selectedDate != null
                    ? "Date: ${_selectedDate!.toLocal()}"
                    : "Pick Date & Time"),
                trailing: const Icon(Icons.calendar_today),
                onTap: pickDate,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : createEvent,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Create Event"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
