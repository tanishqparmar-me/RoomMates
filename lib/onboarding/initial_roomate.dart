import 'package:flutter/material.dart';
import 'package:roommates/home.dart';
import 'package:roommates/model/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitialRoomate extends StatefulWidget {
  const InitialRoomate({super.key});

  @override
  State<InitialRoomate> createState() => _InitialRoomateState();
}

class _InitialRoomateState extends State<InitialRoomate> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController aadharNo = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image(
                  image: AssetImage('assets/logo/roommates.png'),
                  width: 100,
                ),
                Text("Add Initial RoomMate", style: TextStyle(fontSize: 25)),
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
                      } else if (!RegExp(
                        r'^[^@]+@[^@]+\.[^@]+',
                      ).hasMatch(value)) {
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
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        DBHelper? pro = DBHelper();
                        pro.insertRoommate({
                          'full_name': name.text.trim(),
                          'email': email.text.trim(),
                          'mobile_no': int.parse(phone.text),
                          'address': address.text.trim(),
                          'aadhar_no': int.parse(aadharNo.text),
                        });
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setBool('isFirstTime', true);
                        if(!mounted)return;
                        Navigator.pushReplacement(
                          this.context,
                          MaterialPageRoute(builder: (context) => Home()),
                        );
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
      ),
    );
  }
}
