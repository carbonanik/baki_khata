import '../entities/expense.dart';

abstract class IExpenseRepository {
  Future<List<Expense>> getExpenses(String shopId);
  Future<void> addExpense(Expense expense);
  Future<void> deleteExpense(String id);
}
