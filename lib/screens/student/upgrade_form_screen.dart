import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpgradeToParticipantScreen extends StatefulWidget {
  const UpgradeToParticipantScreen({super.key});

  @override
  _UpgradeToParticipantScreenState createState() => _UpgradeToParticipantScreenState();
}

class _UpgradeToParticipantScreenState extends State<UpgradeToParticipantScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController enrolmentController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController collegeIdController = TextEditingController();
  bool isSubmitting = false;

  Future<void> submitUpgrade() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    try {
      final response = await UserService.upgradeToParticipant(
        enrolmentController.text,
        departmentController.text,
        collegeIdController.text,
      );

      if (response['message'] != null) {
        // Update local role
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('role', 'participant');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );

        // Return true to indicate success
        Navigator.pop(context, true);
      } else {
        throw Exception("Upgrade failed");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upgrade failed: $e")),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upgrade to Participant")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: enrolmentController,
                decoration: const InputDecoration(labelText: "Enrolment Number"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: departmentController,
                decoration: const InputDecoration(labelText: "Department"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: collegeIdController,
                decoration: const InputDecoration(labelText: "College ID Proof (URL)"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSubmitting ? null : submitUpgrade,
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
