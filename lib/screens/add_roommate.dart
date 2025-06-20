import 'package:flutter/material.dart';
import 'package:roommates/model/db_helper.dart';

class AddRoommate extends StatefulWidget {
  const AddRoommate({super.key});

  @override
  State<AddRoommate> createState() => _AddRoommateState();
}

class _AddRoommateState extends State<AddRoommate> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController aadharNo = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add RoomMate"),
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
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  controller: email,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  controller: phone,
                  keyboardType: const TextInputType.numberWithOptions(),
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixText: '+91 ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number is required';
                    } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Enter a valid 10-digit number';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  controller: address,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Address is required';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  controller: aadharNo,
                  keyboardType: const TextInputType.numberWithOptions(),
                  decoration: const InputDecoration(
                    labelText: 'Adhar Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Aadhar number is required';
                    } else if (!RegExp(r'^\d{12}$').hasMatch(value)) {
                      return 'Enter a valid 12-digit Aadhar number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 355,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      DBHelper? pro = DBHelper();
                      pro.insertRoommate({
                        'full_name': name.text.trim(),
                        'email': email.text.trim(),
                        'mobile_no': int.parse(phone.text),
                        'address': address.text.trim(),
                        'aadhar_no': int.parse(aadharNo.text),
                      });
                      Navigator.pop(context, true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Add', style: TextStyle(fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
