import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _launchURL() async {
    final Uri url = Uri.parse('https://tanishqparmar.site');
    launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('About This App'),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Roommate Expense Manager',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Track shared expenses, settle balances, and visualize contributions in an easy way.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              const Text(
                'Developer',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.amber,
                  child: Text('T', style: TextStyle(color: Colors.white)),
                ),
                title: Text('Tanishq Parmar'),
                subtitle: Text('Flutter & Django Developer'),
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  onPressed: _launchURL,
                  icon: const Icon(Icons.open_in_new, color: Colors.white),
                  label: const Text(
                    'Visit Portfolio',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const Spacer(),
              const Center(
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
