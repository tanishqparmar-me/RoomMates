import 'package:flutter/material.dart';
import 'package:roommates/model/db_helper.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ExpenseTableScreen extends StatefulWidget {
  const ExpenseTableScreen({super.key});

  @override
  State<ExpenseTableScreen> createState() => _ExpenseTableScreenState();
}

class _ExpenseTableScreenState extends State<ExpenseTableScreen> {
  List<Map<String, dynamic>> _expenses = [];
  Map<int, String> roommateNames = {};
  bool _isLoading = true;
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    final expenses = await DBHelper().getExpenses();

    Set<int> roommateIds = expenses
        .map((e) => e['roommate_id'] as int)
        .where((id) => true)
        .toSet();

    Map<int, String> names = {};
    for (int id in roommateIds) {
      final name = await DBHelper().getRoommateNameById(id);
      names[id] = name ?? 'Unknown';
    }

    double total = 0.0;
    for (var exp in expenses) {
      total += (exp['amount'] as num?)?.toDouble() ?? 0.0;
    }

    setState(() {
      _expenses = expenses;
      roommateNames = names;
      _total = total;
      _isLoading = false;
    });
  }

  String _formatAmount(num amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  Future<void> _exportToPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Expense Report', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: [
                  'Date',
                  'Time',
                  'Amount',
                  'Mode',
                  'Item',
                  'Purpose',
                  'Roommate',
                ],
                data: _expenses.map((exp) {
                  return [
                    exp['date'] ?? '',
                    exp['time'] ?? '',
                    _formatAmount(exp['amount']),
                    exp['payment_mode'] ?? '',
                    exp['item_name'] ?? '',
                    exp['purpose'] ?? '',
                    roommateNames[exp['roommate_id']] ?? 'Unknown',
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Grand Total: ${_formatAmount(_total)}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Expense Table'),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 255, 234, 73),
                  Color.fromARGB(255, 255, 164, 6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _exportToPdf,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _expenses.isEmpty
            ? const Center(child: Text("No expenses found."))
            : Column(
                children: [
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                Colors.amber.shade100,
                              ),
                              columns: const [
                                DataColumn(label: Text('Date')),
                                DataColumn(label: Text('Time')),
                                DataColumn(label: Text('Amount')),
                                DataColumn(label: Text('Mode')),
                                DataColumn(label: Text('Item')),
                                DataColumn(label: Text('Purpose')),
                                DataColumn(label: Text('Roommate')),
                              ],
                              rows: _expenses
                                  .map(
                                    (exp) => DataRow(
                                      cells: [
                                        DataCell(Text(exp['date'] ?? '')),
                                        DataCell(Text(exp['time'] ?? '')),
                                        DataCell(
                                          Text(
                                            _formatAmount(exp['amount'] ?? 0),
                                          ),
                                        ),
                                        DataCell(
                                          Text(exp['payment_mode'] ?? ''),
                                        ),
                                        DataCell(Text(exp['item_name'] ?? '')),
                                        DataCell(Text(exp['purpose'] ?? '')),
                                        DataCell(
                                          Text(
                                            roommateNames[exp['roommate_id']] ??
                                                'Unknown',
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Grand Total Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    color: Colors.amber.shade100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Grand Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatAmount(_total),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Export Button
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton.icon(
                      onPressed: _exportToPdf,
                      label: const Text('Export as PDF'),
                      icon: const Icon(Icons.picture_as_pdf),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
