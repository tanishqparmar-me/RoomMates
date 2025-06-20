import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roommates/screens/expense_detail.dart';
import '../model/db_helper.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ExpenseListScreenState createState() => ExpenseListScreenState();
}

class ExpenseListScreenState extends State<ExpenseListScreen> {
  List<Map<String, dynamic>> _expenses = [];
  List<Map<String, dynamic>> _filteredExpenses = [];
  Map<int, String> _roommateMap = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadExpenses();
    _searchController.addListener(() {
      _filterExpenses(_searchController.text);
    });
  }

  void fetchExpenses() async {
    final data = await DBHelper().getExpenses();
    setState(() {
      _expenses = data;
      _filteredExpenses = data;
    });
  }

  Future<void> loadExpenses() async {
    final dbHelper = DBHelper();

    final roommates = await dbHelper.getRoommates();
    final roommateMap = {
      for (var rm in roommates) rm['id'] as int: rm['full_name'] as String,
    };

    final expenses = await dbHelper.getExpenses();

    setState(() {
      _roommateMap = roommateMap;
      _expenses = expenses;
      _filteredExpenses = expenses;
    });
  }

  void _filterExpenses(String query) {
    final filtered = _expenses.where((expense) {
      final itemName = expense['item_name'].toString().toLowerCase();
      return itemName.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredExpenses = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Row(
            children: [
              SizedBox(width: 40),
              Icon(Icons.receipt_long_outlined, size: 40),
              SizedBox(width: 20),
              Text('Expense List →'),
            ],
          ),
        ),
        backgroundColor: const Color.fromARGB(33, 255, 237, 170),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by item name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredExpenses.isEmpty
                ? const Center(child: Text('No expenses found'))
                : ListView.builder(
                    itemCount: _filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = _filteredExpenses[index];
                      final roommateName =
                          _roommateMap[expense['roommate_id']] ?? 'Unknown';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: expense['payment_mode'] == 'Card'
                              ? Icon(Icons.credit_card)
                              : Icon(
                                  expense['payment_mode'] == 'Cash'
                                      ? FontAwesomeIcons.moneyBill1
                                      : Icons.phone_iphone,
                                ),
                          title: Text(
                            '${expense['item_name']} - ₹${expense['amount']}',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Roommate: $roommateName'),
                              Text('Mode: ${expense['payment_mode']}'),
                              Text('Purpose: ${expense['purpose'] ?? 'N/A'}'),
                              Text(
                                'Date: ${expense['date']}  Time: ${expense['time']}',
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ExpenseDetailScreen(expense: expense),
                              ),
                            ).then((_) {
                              loadExpenses();
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
