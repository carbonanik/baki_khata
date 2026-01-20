import '../../domain/entities/transaction.dart';

abstract class ITransactionRepository {
  Future<List<Transaction>> getTransactions(String shopId);
  Future<List<Transaction>> getTransactionsForCustomer(String customerId);
  Future<void> addTransaction(Transaction transaction);
  Future<void> deleteTransactionsForCustomer(String customerId);
}
