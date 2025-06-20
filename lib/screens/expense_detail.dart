import 'package:flutter/material.dart';
import 'package:roommates/screens/expense_update.dart';
import '../model/db_helper.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> expense;

  const ExpenseDetailScreen({super.key, required this.expense});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  late Map<String, dynamic> expense;
  String roommateName = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    expense = Map<String, dynamic>.from(widget.expense);
    fetchRoommateName();
  }

  void exportExpenseAsPdf(Map<String, dynamic> expense) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Expense Details',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Date: ${expense['date'] ?? ''}'),
            pw.Text('Time: ${expense['time'] ?? ''}'),
            pw.Text('Amount: Rs${expense['amount'].toString()}'),
            pw.Text('Payment Mode: ${expense['payment_mode'] ?? ''}'),
            pw.Text('Purpose: ${expense['purpose'] ?? ''}'),
            pw.Text('Item Name: ${expense['item_name'] ?? ''}'),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  void fetchRoommateName() async {
    final id = expense['roommate_id'];
    final name = await DBHelper().getRoommateNameById(id);
    setState(() {
      roommateName = name ?? 'Unknown';
      isLoading = false;
    });
  }

  void deleteExpense() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Expense"),
        content: const Text("Are you sure you want to delete this expense?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DBHelper().deleteExpense(expense['id']);
      if (context.mounted) {
        if (!mounted) return;
        Navigator.pop(context, true);
      }
    }
  }

  void editExpense() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UpdateExpenseScreen(expense: expense)),
    );

    if (updated == true) {
      final updatedExpense = (await DBHelper().getExpenses()).firstWhere(
        (e) => e['id'] == expense['id'],
        orElse: () => expense,
      );

      setState(() {
        expense = updatedExpense;
      });

      fetchRoommateName();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Details"),
         flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 255, 234, 73), Color.fromARGB(255, 255, 164, 6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(onPressed: editExpense, icon: const Icon(Icons.edit)),
          IconButton(onPressed: deleteExpense, icon: const Icon(Icons.delete)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      detailRow("Date", expense['date']),
                      detailRow("Time", expense['time']),
                      detailRow("Amount", "₹${expense['amount']}"),
                      detailRow("Payment Mode", expense['payment_mode']),
                      detailRow("Purpose", expense['purpose'] ?? 'N/A'),
                      detailRow("Item Name", expense['item_name'] ?? 'N/A'),
                      detailRow("Roommate", roommateName),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: editExpense,
                            icon: const Icon(Icons.edit),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              backgroundColor: Colors.amber,
                              iconColor: Colors.blue,
                              foregroundColor: Colors.black,
                              elevation: 3,
                            ),

                            label: const Text("Edit"),
                          ),
                          ElevatedButton.icon(
                            onPressed: deleteExpense,
                            icon: const Icon(Icons.delete),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              iconColor: Colors.red,
                              elevation: 3,
                            ),
                            label: const Text("Delete"),
                          ),
                        ],
                      ),
                      SizedBox(height: 11),
                      ElevatedButton.icon(
                        onPressed: () => exportExpenseAsPdf(expense),
                        icon: const Icon(Icons.picture_as_pdf, size: 20),
                        label: const Text("Export as PDF"),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          backgroundColor: Colors.amber,
                          iconColor: Colors.black,
                          foregroundColor: Colors.black,
                          elevation: 3,
                          iconSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
