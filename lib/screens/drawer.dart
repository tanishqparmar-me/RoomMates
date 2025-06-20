import 'package:flutter/material.dart';
import '../model/db_helper.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  Map<String, dynamic>? profile;

  @override
  void initState() {
    super.initState();
    loadSmallestIdRoommate();
  }

  Future<void> loadSmallestIdRoommate() async {
    final data = await DBHelper().getRoommates();
    final roommates = List<Map<String, dynamic>>.from(data);

    if (roommates.isNotEmpty) {
      roommates.sort((a, b) => a['id'].compareTo(b['id']));
      setState(() {
        profile = roommates.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: profile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(
                    profile!['full_name'] ?? '',
                    style: TextStyle(color: Colors.black),
                  ),
                  accountEmail: Text(
                    profile!['email'] ?? '',
                    style: TextStyle(color: Colors.black),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      (profile!['full_name'] ?? '')
                          .toString()
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigoAccent,
                      ),
                    ),
                  ),
                  decoration: const BoxDecoration(color: Colors.amber),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.monetization_on),
                  title: const Text('Expenses'),
                  onTap: () {
                    Navigator.pushNamed(context, '/expenses');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.timelapse_sharp),
                  title: const Text('Month end'),
                  onTap: () {
                    Navigator.pushNamed(context, '/monthlySummary');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.table_chart),
                  title: const Text('Expense Table'),
                  onTap: () {
                    Navigator.pushNamed(context, '/table');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('About'),
                  onTap: () {
                    Navigator.pushNamed(context, '/about');
                  },
                ),
                SizedBox(height: 230,),
      Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            Text(
              'Made by Tanishq Parmar',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'v1.0.0',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
              ],
            ),
    );
  }
}
