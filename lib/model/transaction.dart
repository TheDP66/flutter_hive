import 'package:hive/hive.dart';

part 'transaction.g.dart';

// ? 2. Make HiveObject model
// ? typeId: filled with unique number for every class
@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late DateTime createdDate;

  @HiveField(2)
  late bool isExpense = true;

  @HiveField(3)
  late double amount;
}

// ? 3. Run make build_runner