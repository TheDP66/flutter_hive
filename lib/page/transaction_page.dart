import 'package:flutter/material.dart';
import 'package:flutter_hive/boxes.dart';
import 'package:flutter_hive/model/transaction.dart';
import 'package:flutter_hive/page/widget/transaction_dialog.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final List<Transaction> transactions = [];

  @override
  void dispose() {
    // ? don't forget to close if not used
    Hive.close(); // to close all
    Hive.box('transactions').close(); // to close one
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hive Expense Tracker"),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<Box<Transaction>>(
        valueListenable: Boxes.getTransactions().listenable(),
        builder: (context, box, _) {
          final transactions = box.values.toList().cast<Transaction>();

          return buildContent(transactions);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => TransactionDialog(
            onClickedDone: addTransaction,
          ),
        ),
      ),
    );
  }

  Widget buildContent(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text(
          'No expenses yet!',
          style: TextStyle(fontSize: 24),
        ),
      );
    } else {
      final netExpense = transactions.fold<double>(
        0,
        (previousValue, transaction) => transaction.isExpense
            ? previousValue - transaction.amount
            : previousValue + transaction.amount,
      );
      final newExpenseString = '\$${netExpense.toStringAsFixed(2)}';
      final color = netExpense > 0 ? Colors.green : Colors.red;

      return Column(
        children: [
          const SizedBox(height: 24),
          Text(
            'Net Expense: $newExpenseString',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: transactions.length,
              itemBuilder: (BuildContext context, int index) {
                final transaction = transactions[index];

                return buildTransaction(context, transaction);
              },
            ),
          ),
        ],
      );
    }
  }

  Widget buildTransaction(
    BuildContext context,
    Transaction transaction,
  ) {
    final color = transaction.isExpense ? Colors.red : Colors.green;
    final date = DateFormat.yMMMd().format(transaction.createdDate);
    final amount = '\$${transaction.amount.toStringAsFixed(2)}';

    return Card(
      color: Colors.white,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        title: Text(
          transaction.name,
          maxLines: 2,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(date),
        trailing: Text(
          amount,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        children: [
          buildButtons(context, transaction),
        ],
      ),
    );
  }

  Widget buildButtons(BuildContext context, Transaction transaction) => Row(
        children: [
          Expanded(
            child: TextButton.icon(
              label: const Text('Edit'),
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TransactionDialog(
                    transaction: transaction,
                    onClickedDone: (name, amount, isExpense) =>
                        editTransaction(transaction, name, amount, isExpense),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: TextButton.icon(
              label: const Text('Delete'),
              icon: const Icon(Icons.delete),
              onPressed: () => deleteTransaction(transaction),
            ),
          )
        ],
      );

  Future addTransaction(String name, double amount, bool isExpense) async {
    final transaction = Transaction()
      ..name = name
      ..createdDate = DateTime.now()
      ..amount = amount
      ..isExpense = isExpense;

    final box = Boxes.getTransactions();
    box.add(transaction);
    //box.put('mykey', transaction);

    // final mybox = Boxes.getTransactions();
    // final myTransaction = mybox.get('key');
    // mybox.values;
    // mybox.keys;
  }

  void editTransaction(
    Transaction transaction,
    String name,
    double amount,
    bool isExpense,
  ) {
    transaction.name = name;
    transaction.amount = amount;
    transaction.isExpense = isExpense;

    // final box = Boxes.getTransactions();
    // box.put(transaction.key, transaction);

    transaction.save();
  }

  void deleteTransaction(Transaction transaction) {
    // final box = Boxes.getTransactions();
    // box.delete(transaction.key);

    transaction.delete();
    //setState(() => transactions.remove(transaction));
  }
}
