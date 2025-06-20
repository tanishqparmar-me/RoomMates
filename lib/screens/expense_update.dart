import 'package:flutter/material.dart';
import '../model/db_helper.dart';

class UpdateExpenseScreen extends StatefulWidget {
  final Map<String, dynamic> expense;

  const UpdateExpenseScreen({super.key, required this.expense});

  @override
  State<UpdateExpenseScreen> createState() => _UpdateExpenseScreenState();
}

class _UpdateExpenseScreenState extends State<UpdateExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController dateController;
  late TextEditingController timeController;
  late TextEditingController amountController;
  late TextEditingController purposeController;
  late TextEditingController itemNameController;

  String selectedPaymentMode = 'Cash';
  List<Map<String, dynamic>> roommates = [];
  int? selectedRoommateId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    dateController = TextEditingController(text: widget.expense['date']);
    timeController = TextEditingController(text: widget.expense['time']);
    amountController = TextEditingController(
      text: widget.expense['amount'].toString(),
    );
    purposeController = TextEditingController(text: widget.expense['purpose']);
    itemNameController = TextEditingController(
      text: widget.expense['item_name'],
    );
    selectedPaymentMode = widget.expense['payment_mode'];
    selectedRoommateId = widget.expense['roommate_id'];
    fetchRoommates();
  }

  void fetchRoommates() async {
    final data = await DBHelper().getRoommates();
    setState(() {
      roommates = data;
      isLoading = false;
    });
  }

  Future<void> _updateExpense() async {
    if (_formKey.currentState!.validate()) {
      final updatedData = {
        'date': dateController.text.trim(),
        'time': timeController.text.trim(),
        'amount': double.parse(amountController.text.trim()),
        'payment_mode': selectedPaymentMode,
        'purpose': purposeController.text.trim(),
        'item_name': itemNameController.text.trim(),
        'roommate_id': selectedRoommateId,
      };

      try {
        await DBHelper().updateExpense(widget.expense['id'], updatedData);
        if (!mounted) return;
        Navigator.pop(context, true); // return true to trigger refresh
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Expense updated")));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    }
  }

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    amountController.dispose();
    purposeController.dispose();
    itemNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Expense"),
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
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: dateController,
                      decoration: const InputDecoration(labelText: 'Date'),
                    ),
                    TextFormField(
                      controller: timeController,
                      decoration: const InputDecoration(labelText: 'Time'),
                    ),
                    TextFormField(
                      controller: amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixText: '₹  ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedPaymentMode,
                      decoration: const InputDecoration(
                        labelText: 'Payment Mode',
                      ),
                      items: ['Cash', 'Online', 'Card']
                          .map(
                            (mode) => DropdownMenuItem(
                              value: mode,
                              child: Text(mode),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedPaymentMode = value);
                        }
                      },
                    ),
                    TextFormField(
                      controller: purposeController,
                      decoration: const InputDecoration(labelText: 'Purpose'),
                    ),
                    TextFormField(
                      controller: itemNameController,
                      decoration: const InputDecoration(labelText: 'Item Name'),
                    ),
                    DropdownButtonFormField<int>(
                      value: roommates.any((r) => r['id'] == selectedRoommateId)
                          ? selectedRoommateId
                          : null,
                      decoration: const InputDecoration(labelText: 'Roommate'),
                      items: roommates.map((roommate) {
                        return DropdownMenuItem<int>(
                          value: roommate['id'],
                          child: Text(roommate['full_name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRoommateId = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a roommate' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateExpense,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text("Update Expense"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
