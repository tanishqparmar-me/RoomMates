import 'package:flutter/material.dart';
import 'package:roommates/screens/roommate_update.dart';
import '../model/db_helper.dart';

class RoommateDetailScreen extends StatefulWidget {
  final Map<String, dynamic> roommate;

  const RoommateDetailScreen({super.key, required this.roommate});

  @override
  State<RoommateDetailScreen> createState() => _RoommateDetailScreenState();
}

class _RoommateDetailScreenState extends State<RoommateDetailScreen> {
  late Map<String, dynamic> _roommate;

  @override
  void initState() {
    super.initState();
    _roommate = widget.roommate;
  }

  void _deleteRoommate(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Roommate"),
        content: const Text("Are you sure you want to delete this roommate?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DBHelper().deleteRoommate(_roommate['id']);
      if (!mounted) return;
      ScaffoldMessenger.of(
        this.context,
      ).showSnackBar(const SnackBar(content: Text('Roommate deleted')));
      Navigator.pop(this.context, true);
    }
  }

  void _editRoommate(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UpdateRoommateScreen(roommate: _roommate),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _roommate = result;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        this.context,
      ).showSnackBar(const SnackBar(content: Text('Roommate updated')));
      Navigator.pop(this.context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("RoomMate: ${_roommate['full_name'] ?? 'Roommate'}"),
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
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                title: const Text('Full Name'),
                subtitle: Text(_roommate['full_name'] ?? ''),
              ),

              ListTile(
                title: const Text('Email'),
                subtitle: Text(_roommate['email'] ?? ''),
              ),
              ListTile(
                title: const Text('Mobile'),
                subtitle: Text(_roommate['mobile_no'] ?? ''),
              ),
              ListTile(
                title: const Text('Address'),
                subtitle: Text(_roommate['address'] ?? ''),
              ),
              ListTile(
                title: const Text('Aadhar'),
                subtitle: Text(_roommate['aadhar_no'] ?? ''),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit"),
                    onPressed: () => _editRoommate(context),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      iconColor: Colors.blue,
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      iconColor: Colors.red,
                    ),
                    icon: const Icon(Icons.delete),
                    label: const Text("Delete"),
                    onPressed: () => _deleteRoommate(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
