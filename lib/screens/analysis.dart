import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../model/db_helper.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ExpensePieChartScreen extends StatefulWidget {
  const ExpensePieChartScreen({super.key});

  @override
  State<ExpensePieChartScreen> createState() => _ExpensePieChartScreenState();
}

class _ExpensePieChartScreenState extends State<ExpensePieChartScreen> {
  Map<String, double> expenseMap = {};
  Map<String, Color> colorMap = {};
  double totalExpense = 0.0;
  bool _loading = true;

  final List<Color> availableColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.brown,
    Colors.pink,
    Colors.indigo,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _calculateExpenses();
  }

  Future<void> _calculateExpenses() async {
    final expenses = await DBHelper().getExpenses();
    Map<String, double> tempMap = {};
    Map<String, Color> tempColorMap = {};

    for (var exp in expenses) {
      int id = exp['roommate_id'];
      String? name = await DBHelper().getRoommateNameById(id) ?? 'Unknown';
      double amount = (exp['amount'] as num).toDouble();

      if (!tempMap.containsKey(name)) {
        tempMap[name] = amount;
        tempColorMap[name] =
            availableColors[tempColorMap.length % availableColors.length];
      } else {
        tempMap[name] = tempMap[name]! + amount;
      }
    }

    setState(() {
      expenseMap = tempMap;
      colorMap = tempColorMap;
      totalExpense = expenseMap.values.fold(0.0, (sum, item) => sum + item);
      _loading = false;
    });
  }

  List<PieChartSectionData> _getSections() {
    return expenseMap.entries.map((entry) {
      final color = colorMap[entry.key]!;
      final value = entry.value;
      return PieChartSectionData(
        value: value,
        color: color,
        title: '${(value / totalExpense * 100).toStringAsFixed(1)}%',
        titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
        radius: 80,
      );
    }).toList();
  }

  BarChartData _getBarChartData() {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: (expenseMap.values.isEmpty
          ? 100
          : (expenseMap.values.reduce((a, b) => a > b ? a : b)) + 50),
      barTouchData: BarTouchData(enabled: true),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (index, _) {
              final keys = expenseMap.keys.toList();
              return Text(
                keys[index.toInt()],
                style: const TextStyle(fontSize: 10),
              );
            },
            reservedSize: 42,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: expenseMap.entries
          .toList()
          .asMap()
          .entries
          .map(
            (entry) => BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.value,
                  color:
                      colorMap[entry.value.value == 0
                          ? 'Unknown'
                          : entry.value.value == 0
                          ? 'Unknown'
                          : expenseMap.keys.elementAt(entry.key)] ??
                      Colors.grey,
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  final PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              SizedBox(width: 5),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Visualization of Expenses\n',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'myfont',
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: 'Swipe to See bar plot',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontFamily: 'myfont',
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 5),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _loading = true;
                  });
                  _calculateExpenses();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                child: Icon(Icons.refresh, size: 20),
              ),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : expenseMap.isEmpty
            ? const Center(
                child: Text(
                  'No expense yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 240,
                      child: PageView(
                        controller: _pageController,
                        children: [
                          PieChart(
                            PieChartData(
                              sections: _getSections(),
                              centerSpaceRadius: 30,
                              sectionsSpace: 2,
                            ),
                          ),
                          BarChart(_getBarChartData()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: 2,
                      effect: ExpandingDotsEffect(
                        activeDotColor: Colors.amber,
                        dotHeight: 5,
                      ),
                    ),
                    const Text(
                      'Paid By -',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: ListView(
                          children: expenseMap.entries.map((entry) {
                            final color = colorMap[entry.key]!;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: color,
                                child: Text(
                                  entry.key.isNotEmpty
                                      ? entry.key[0].toUpperCase()
                                      : '',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                              title: Text(entry.key),
                              trailing: Text(
                                '₹${entry.value.toStringAsFixed(2)}',
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    Text(
                      'Total Expense: ₹${totalExpense.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
