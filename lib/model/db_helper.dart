  import 'package:sqflite/sqflite.dart';
  import 'package:path/path.dart';


  class DBHelper {
    static Database? _db;

    

    Future<Database> get db async {
      if (_db != null) return _db!;
      _db = await initDB();
      return _db!;
    }

    Future<Database> initDB() async {
      final dbPath = await getDatabasesPath();
      String path = join(dbPath, 'roommate_expense.db');

      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    }

    Future<void> _onCreate(Database db, int version) async {
      await db.execute('''
        CREATE TABLE Roommate(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          full_name TEXT NOT NULL,
          email TEXT UNIQUE,
          mobile_no TEXT NOT NULL,
          address TEXT,
          aadhar_no TEXT UNIQUE
        )
      ''');

      await db.execute('''
        CREATE TABLE Expense(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          time TEXT NOT NULL,
          amount REAL NOT NULL,
          payment_mode TEXT CHECK(payment_mode IN ('Cash', 'Online', 'Card')),
          purpose TEXT,
          item_name TEXT,
          roommate_id INTEGER,
          FOREIGN KEY(roommate_id) REFERENCES Roommate(id)
        )
      ''');
    }


    Future<int> insertRoommate(Map<String, dynamic> data) async {
      final dbClient = await db;
      return await dbClient.insert('Roommate', data);
    }

    Future<List<Map<String, dynamic>>> getRoommates() async {
      final dbClient = await db;
      return await dbClient.query('Roommate');
    }

    Future<int> updateRoommate(int id, Map<String, dynamic> data) async {
    final dbClient = await db;
    return await dbClient.update(
      'Roommate',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

    Future<int> deleteRoommate(int id) async {
      final dbClient = await db;
      return await dbClient.delete('Roommate', where: 'id = ?', whereArgs: [id]);
    }


    Future<int> insertExpense(Map<String, dynamic> data) async {
      final dbClient = await db;
      return await dbClient.insert('Expense', data);
    }

    Future<List<Map<String, dynamic>>> getExpenses() async {
      final dbClient = await db;
      return await dbClient.query('Expense');
    }

    Future<List<Map<String, dynamic>>> getExpensesByRoommate(int roommateId) async {
      final dbClient = await db;
      return await dbClient.query('Expense', where: 'roommate_id = ?', whereArgs: [roommateId]);
    }

    Future<int> updateExpense(int id, Map<String, dynamic> data) async {
      final dbClient = await db;
      return await dbClient.update('Expense', data, where: 'id = ?', whereArgs: [id]);
    }

    Future<int> deleteExpense(int id) async {
      final dbClient = await db;
      return await dbClient.delete('Expense', where: 'id = ?', whereArgs: [id]);
    }

    Future<String?> getRoommateNameById(int id) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'Roommate',
      columns: ['full_name'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first['full_name'] as String;
    }
    return null;
  }

 Future<Map<String, dynamic>> getRoommateById(int id) async {
  final dbClient = await db; 
  final result = await dbClient.query('Roommate', where: 'id = ?', whereArgs: [id]);
  return result.first;
}


Future<List<Map<String, dynamic>>> getTotalExpensesByRoommate() async {
  final dbClient = await db;
  return await dbClient.rawQuery('''
    SELECT roommate_id, SUM(amount) as total
    FROM Expense
    GROUP BY roommate_id
  ''');
}

Future<String?> getRoommateNameByIdpro(int id) async {
  final dbClient = await db;
  final result = await dbClient.query(
    'Roommate',
    columns: ['full_name'],
    where: 'id = ?',
    whereArgs: [id],
  );
  if (result.isNotEmpty) return result.first['full_name'] as String;
  return null;
}


 Future<void> deleteAllExpenses() async {
    final dbpro = await db;
    await dbpro.delete('Expense');
  }

Future<Map<String, double>> calculateDuesForRoommates() async {
  final dbpro = await db;

  final expenseResult = await dbpro.rawQuery('SELECT SUM(amount) as total FROM Expense');
  double totalExpense = (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0;

  final roommates = await dbpro.query('Roommate');
  int roommateCount = roommates.length;

  if (roommateCount == 0) return {};

  double share = totalExpense / roommateCount;

  Map<int, double> paidById = {};
  final expenseRows = await dbpro.query('Expense');
  for (var row in expenseRows) {
    int id = row['roommate_id'] as int;
    double amount = (row['amount'] as num).toDouble();
    paidById[id] = (paidById[id] ?? 0) + amount;
  }

Map<String, double> dues = {};
for (var mate in roommates) {
  int id = mate['id'] as int;
  String name = mate['full_name'] as String? ?? 'Unknown';
  double paid = paidById[id] ?? 0.0;
  dues[name] = (share - paid); 
}


  return dues;
}


  }
