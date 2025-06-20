import 'package:flutter/material.dart';
import 'package:roommates/model/db_helper.dart';
import 'package:roommates/screens/add_roommate.dart';
import 'package:roommates/screens/roommate_detail.dart';

class Roommates extends StatefulWidget {
  const Roommates({super.key});

  @override
  RoommateListScreenState createState() => RoommateListScreenState();
}

class RoommateListScreenState extends State<Roommates> {
  List<Map<String, dynamic>> roommates = [];

  @override
  void initState() {
    super.initState();
    fetchRoommates();
  }

  Future<void> fetchRoommates() async {
    final data = await DBHelper().getRoommates();
    setState(() {
      roommates = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: roommates.isEmpty
          ? const Center(child: Text("No roommates added yet."))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: roommates.length,
              itemBuilder: (context, index) {
                final roommate = roommates[index];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.amber,
                      child: Text(
                        roommate['full_name'][0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      roommate['full_name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      roommate['email']?.isNotEmpty == true
                          ? roommate['email']
                          : roommate['mobile_no'] ?? '',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RoommateDetailScreen(roommate: roommate),
                        ),
                      );
                      if (result == true) {
                        fetchRoommates();
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddRoommate()),
          );
          if (result == true) {
            fetchRoommates();
          }
        },
        label: const Text("Add Roommate"),
        icon: const Icon(Icons.person_add),
        backgroundColor: const Color.fromARGB(255, 255, 214, 93),
        foregroundColor: Colors.black,
      ),
    );
  }
}
