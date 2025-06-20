import 'package:flutter/material.dart';
import '../model/db_helper.dart';

class UpdateRoommateScreen extends StatefulWidget {
  final Map<String, dynamic> roommate;
  const UpdateRoommateScreen({super.key, required this.roommate});

  @override
  State<UpdateRoommateScreen> createState() => _UpdateRoommateScreenState();
}

class _UpdateRoommateScreenState extends State<UpdateRoommateScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController mobileController;
  late TextEditingController addressController;
  late TextEditingController aadharController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.roommate['full_name']);
    emailController = TextEditingController(text: widget.roommate['email']);
    mobileController = TextEditingController(
      text: widget.roommate['mobile_no'],
    );
    addressController = TextEditingController(text: widget.roommate['address']);
    aadharController = TextEditingController(
      text: widget.roommate['aadhar_no'],
    );
  }

  Future<void> _updateRoommate() async {
    if (_formKey.currentState!.validate()) {
      final updatedData = {
        'id': widget.roommate['id'], 
        'full_name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'mobile_no': mobileController.text.trim(),
        'address': addressController.text.trim(),
        'aadhar_no': aadharController.text.trim(),
      };

      try {
        final db = DBHelper();
        await db.updateRoommate(widget.roommate['id'], updatedData);

        final updatedRoommate = await db.getRoommateById(widget.roommate['id']);

        if (context.mounted) {
          if (!mounted) return;
          Navigator.pop(context, updatedRoommate); 
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Roommate updated successfully")),
          );
        }
      } catch (e) {
        if (context.mounted) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
        }
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    addressController.dispose();
    aadharController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Roommate"),
         flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 255, 234, 73), Color.fromARGB(255, 255, 164, 6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: mobileController,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
              ),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextFormField(
                controller: aadharController,
                decoration: const InputDecoration(labelText: 'Aadhar Number'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateRoommate,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                child: const Text("Update Roommate"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
