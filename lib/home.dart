import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roommates/screens/roommates.dart';
import 'package:roommates/screens/add_expense.dart';
import 'package:roommates/screens/add_roommate.dart';
import 'package:roommates/screens/analysis.dart';
import 'package:roommates/screens/drawer.dart';
import 'package:roommates/screens/due.dart';
import 'package:roommates/screens/expenses.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectIndex = 0;

  final GlobalKey<ExpenseListScreenState> _expenseKey = GlobalKey();
  final GlobalKey<RoommateListScreenState> roommateListKey =
      GlobalKey<RoommateListScreenState>();

  late final List<Widget> _screens = [
    ExpenseListScreen(key: _expenseKey),
    ExpensePieChartScreen(),
    SettlementScreen(),
    Roommates(key: roommateListKey),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'RoomMates      ',
            style: TextStyle(fontFamily: 'myfont', fontSize: 25),
          ),
        ),
        // backgroundColor: Colors.amber,
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
      body: _screens[_selectIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color.fromARGB(255, 255, 248, 226),
        animationDuration: Duration(milliseconds: 1600),
        labelPadding: EdgeInsets.all(0),
        indicatorColor: const Color.fromARGB(255, 255, 211, 80),
        height: 60,
        selectedIndex: _selectIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.monetization_on),
            label: 'Expenses',
          ),
          NavigationDestination(icon: Icon(Icons.analytics), label: 'Analysis'),
          NavigationDestination(
            icon: Icon(FontAwesomeIcons.scaleBalanced),
            label: 'Settlement',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'RoomMates'),
        ],
      ),
      floatingActionButton: _selectIndex == 0 
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _selectIndex == 0
                        ? const AddExpenseForm()
                        : const AddRoommate(),
                  ),
                );

                if (result == true) {
                  if (_selectIndex == 0) {
                    _expenseKey.currentState?.fetchExpenses();
                  } else if (_selectIndex == 2) {
                    roommateListKey.currentState?.fetchRoommates();
                  }
                }
              },
              backgroundColor: const Color.fromARGB(255, 255, 221, 118),
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,

      drawer: CustomDrawer(),
    );
  }
}
