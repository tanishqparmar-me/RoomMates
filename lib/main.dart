import 'package:flutter/material.dart';
import 'package:roommates/home.dart';
import 'package:roommates/onboarding/onboarding.dart';
import 'package:roommates/screens/about.dart';
import 'package:roommates/screens/add_roommate.dart';
import 'package:roommates/screens/expenses.dart';
import 'package:roommates/screens/month_end.dart';
import 'package:roommates/screens/table_expense.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isOnboardingCompleted = prefs.getBool('isFirstTime') ?? false;

  runApp(RoomMate(pro: isOnboardingCompleted));
}

class RoomMate extends StatefulWidget {
  final bool pro;
  const RoomMate({super.key, required this.pro});

  @override
  State<RoomMate> createState() => _RoomMateState();
}

class _RoomMateState extends State<RoomMate> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "RoomMate",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'myfont'),
      home: widget.pro ? const Home() : const OnboardingScreen(),
      routes: {
        '/expenses': (context) => const ExpenseListScreen(),
        '/addRoommate': (context) => const AddRoommate(),
        '/monthlySummary': (context) => const MonthlySummaryScreen(),
        '/table': (context) => const ExpenseTableScreen(),
        '/about': (context) => const AboutScreen(),
      },
    );
  }
}
