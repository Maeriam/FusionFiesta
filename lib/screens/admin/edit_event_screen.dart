import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../models/event_model.dart';

class EditEventScreen extends StatefulWidget {
  final String token;
  final Event event;

  const EditEventScreen({super.key, required this.token, required this.event});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _venueController;
  late TextEditingController _categoryController;
  late TextEditingController _registrationLimitController;
  late TextEditingController _dateController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _titleController = TextEditingController(text: event.title);
    _descriptionController = TextEditingController(text: event.description);
    _venueController = TextEditingController(text: event.venue);
    _categoryController = TextEditingController(text: event.category);
    _registrationLimitController =
        TextEditingController(text: event.registrationLimit.toString());
    _dateController = TextEditingController(text: event.date.toIso8601String());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _categoryController.dispose();
    _registrationLimitController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final provider = Provider.of<EventProvider>(context, listen: false);

    final updatedData = {
      "title": _titleController.text,
      "description": _descriptionController.text,
      "venue": _venueController.text,
      "category": _categoryController.text,
      "registrationLimit": int.tryParse(_registrationLimitController.text) ?? 0,
      "date": _dateController.text,
    };

    final success = await provider.updateEvent(widget.event.id, updatedData, widget.token);
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? "✅ Event updated successfully" : "❌ Failed to update event",
        ),
      ),
    );

    if (success) Navigator.pop(context);
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFF262626),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      labelStyle: const TextStyle(color: Colors.white70),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text("Edit Event"),
        backgroundColor: Colors.black87,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.deepPurple),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration("Title"),
                style: const TextStyle(color: Colors.white),
                validator: (value) => value!.isEmpty ? "Title is required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: _inputDecoration("Description"),
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? "Description is required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _venueController,
                decoration: _inputDecoration("Venue"),
                style: const TextStyle(color: Colors.white),
                validator: (value) => value!.isEmpty ? "Venue is required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                decoration: _inputDecoration("Category"),
                style: const TextStyle(color: Colors.white),
                validator: (value) => value!.isEmpty ? "Category is required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _registrationLimitController,
                decoration: _inputDecoration("Registration Limit"),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? "Registration limit is required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateController,
                decoration: _inputDecoration("Date (YYYY-MM-DD)"),
                style: const TextStyle(color: Colors.white),
                validator: (value) => value!.isEmpty ? "Date is required" : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
