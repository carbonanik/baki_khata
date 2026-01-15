import 'package:sembast/sembast.dart' as sembast;
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/i_transaction_repository.dart';
import '../datasources/database_service.dart';

class TransactionRepository implements ITransactionRepository {
  final _store = sembast.stringMapStoreFactory.store('transactions');

  @override
  Future<List<Transaction>> getTransactions() async {
    final db = await DatabaseService.instance.database;
    final snapshots = await _store.find(db);
    return snapshots.map((s) => Transaction.fromJson(s.value)).toList();
  }

  @override
  Future<List<Transaction>> getTransactionsForCustomer(
    String customerId,
  ) async {
    final db = await DatabaseService.instance.database;
    final finder = sembast.Finder(
      filter: sembast.Filter.equals('customerId', customerId),
    );
    final snapshots = await _store.find(db, finder: finder);
    return snapshots.map((s) => Transaction.fromJson(s.value)).toList();
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    final db = await DatabaseService.instance.database;
    await _store.record(transaction.id).put(db, transaction.toJson());
  }

  @override
  Future<void> deleteTransactionsForCustomer(String customerId) async {
    final db = await DatabaseService.instance.database;
    final finder = sembast.Finder(
      filter: sembast.Filter.equals('customerId', customerId),
    );
    await _store.delete(db, finder: finder);
  }
}
