import 'package:flutter/material.dart';
import 'package:roommates/model/db_helper.dart';

class AddExpenseForm extends StatefulWidget {
  const AddExpenseForm({super.key});

  @override
  State<AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<AddExpenseForm> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedRoommateId;
  String _itemName = '';
  String _paymentMode = 'Cash';
  double _amount = 0;
  String _purpose = '';

  List<Map<String, dynamic>> _roommates = [];
  final List<String> _paymentModes = ['Cash', 'Online', 'Card'];

  @override
  void initState() {
    super.initState();
    _fetchRoommates();
  }

  Future<void> _fetchRoommates() async {
    final data = await DBHelper().getRoommates();
    setState(() {
      _roommates = data;
    });
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final expenseData = {
        'date': now.toIso8601String().split('T')[0],
        'time': now.toIso8601String().split('T')[1].split('.')[0],
        'amount': _amount,
        'payment_mode': _paymentMode,
        'purpose': _purpose,
        'item_name': _itemName,
        'roommate_id': _selectedRoommateId,
      };

      await DBHelper().insertExpense(expenseData);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Expense saved!')));
      if(!mounted)return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _roommates.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Select Roommate',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedRoommateId,
                      items: _roommates
                          .map(
                            (roommate) => DropdownMenuItem<int>(
                              value: roommate['id'],
                              child: Text(roommate['full_name']),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRoommateId = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a roommate' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Item Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => _itemName = value,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter item name'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          _amount = double.tryParse(value) ?? 0,
                      validator: (value) =>
                          value == null || double.tryParse(value) == null
                          ? 'Enter valid amount'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Purpose',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => _purpose = value,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Payment Mode',
                        border: OutlineInputBorder(),
                      ),
                      value: _paymentMode,
                      items: _paymentModes
                          .map(
                            (mode) => DropdownMenuItem<String>(
                              value: mode,
                              child: Text(mode),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _paymentMode = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _saveExpense,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Save Expense'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
