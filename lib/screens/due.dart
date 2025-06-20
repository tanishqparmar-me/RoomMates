import 'package:flutter/material.dart';
import '../model/db_helper.dart';

class SettlementScreen extends StatefulWidget {
  const SettlementScreen({super.key});

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  Map<String, double> dues = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    calculateSettlements();
  }

  Future<void> calculateSettlements() async {
    final roommates = await DBHelper().getRoommates();
    final expenses = await DBHelper().getExpenses();

    if (roommates.isEmpty || expenses.isEmpty) {
      setState(() {
        loading = false;
      });
      return;
    }

    Map<int, double> paidById = {};
    for (var exp in expenses) {
      int id = exp['roommate_id'] as int;
      double amount = (exp['amount'] as num).toDouble();
      paidById[id] = (paidById[id] ?? 0) + amount;
    }

    double total = paidById.values.fold(0.0, (sum, value) => sum + value);
    int totalRoommates = roommates.length;
    double share = total / totalRoommates;

    Map<String, double> tempDues = {};
    for (var mate in roommates) {
      int id = mate['id'] as int;
      String name = mate['full_name'] as String? ?? 'Unknown';
      double paid = paidById[id] ?? 0.0;
      tempDues[name] = share - paid;
    }

    setState(() {
      dues = tempDues;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settle Expenses')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : dues.isEmpty
          ? const Center(child: Text('No expenses or roommates yet'))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: dues.entries.map((entry) {
                final name = entry.key;
                final amount = entry.value;

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: amount == 0
                          ? Colors.grey
                          : amount > 0
                          ? Colors.red
                          : Colors.green,
                      child: Text(name[0].toUpperCase()),
                    ),
                    title: Text(name),
                    subtitle: amount == 0
                        ? const Text(
                            'Settled',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text(
                            amount > 0
                                ? 'Needs to pay ₹${amount.toStringAsFixed(2)}'
                                : 'Will receive ₹${(-amount).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: amount > 0 ? Colors.red : Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
