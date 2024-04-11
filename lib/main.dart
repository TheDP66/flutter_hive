import 'package:flutter/material.dart';
import 'package:flutter_hive/model/transaction.dart';
import 'package:flutter_hive/page/transaction_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ? 1. Setup hive
  await Hive.initFlutter();

  // ? 4. Register adapter
  Hive.registerAdapter(TransactionAdapter());

  // ? 5. Register box
  await Hive.openBox<Transaction>('transactions');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static String title = "Hive Expense App";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const TransactionPage(),
    );
  }
}
