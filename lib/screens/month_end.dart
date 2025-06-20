import 'package:flutter/material.dart';
import '../model/db_helper.dart';

class MonthlySummaryScreen extends StatefulWidget {
  const MonthlySummaryScreen({super.key});

  @override
  State<MonthlySummaryScreen> createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends State<MonthlySummaryScreen> {
  double totalExpense = 0.0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _calculateTotalExpense();
  }

  Future<void> _calculateTotalExpense() async {
    final expenses = await DBHelper().getExpenses();
    double total = 0.0;

    for (var expense in expenses) {
      total += (expense['amount'] as num).toDouble();
    }

    setState(() {
      totalExpense = total;
      _loading = false;
    });
  }

  Future<void> _resetAllExpenses() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reset All Expenses"),
        content: const Text("Are you sure you want to delete all expenses?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete All"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DBHelper().deleteAllExpenses();
      setState(() {
        totalExpense = 0.0;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All expenses have been deleted.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Monthly Summary"),
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Total Expense This Month",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "₹${totalExpense.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: _resetAllExpenses,
                    icon: const Icon(Icons.delete_forever),
                    label: const Text("Reset All Expenses"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.red,
                      iconColor: Colors.red
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
