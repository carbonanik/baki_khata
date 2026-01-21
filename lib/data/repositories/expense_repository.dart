import 'package:sembast/sembast.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/i_expense_repository.dart';
import '../datasources/database_service.dart';

class ExpenseRepository implements IExpenseRepository {
  final _store = stringMapStoreFactory.store('expenses');

  @override
  Future<List<Expense>> getExpenses(String shopId) async {
    final db = await DatabaseService.instance.database;
    final finder = Finder(filter: Filter.equals('shopId', shopId));
    final snapshots = await _store.find(db, finder: finder);
    return snapshots.map((s) => Expense.fromJson(s.value)).toList();
  }

  @override
  Future<void> addExpense(Expense expense) async {
    final db = await DatabaseService.instance.database;
    await _store.record(expense.id).put(db, expense.toJson());
  }

  @override
  Future<void> deleteExpense(String id) async {
    final db = await DatabaseService.instance.database;
    await _store.record(id).delete(db);
  }
}
