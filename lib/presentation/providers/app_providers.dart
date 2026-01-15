import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/transaction.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/transaction_repository.dart';

// Repository Providers
final customerRepositoryProvider = Provider((ref) => CustomerRepository());
final transactionRepositoryProvider = Provider(
  (ref) => TransactionRepository(),
);

// Customer State
class CustomerNotifier extends StateNotifier<List<Customer>> {
  final CustomerRepository _repo;
  CustomerNotifier(this._repo) : super([]) {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    state = await _repo.getCustomers();
  }

  Future<void> addCustomer(Customer customer) async {
    await _repo.addCustomer(customer);
    state = [...state, customer];
  }

  Future<void> deleteCustomer(String id) async {
    await _repo.deleteCustomer(id);
    state = state.where((c) => c.id != id).toList();
  }
}

final customerProvider =
    StateNotifierProvider<CustomerNotifier, List<Customer>>((ref) {
      return CustomerNotifier(ref.watch(customerRepositoryProvider));
    });

// Transaction State
class TransactionNotifier extends StateNotifier<List<Transaction>> {
  final TransactionRepository _repo;
  TransactionNotifier(this._repo) : super([]) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = await _repo.getTransactions();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _repo.addTransaction(transaction);
    state = [...state, transaction];
  }

  Future<void> deleteTransactionsForCustomer(String customerId) async {
    await _repo.deleteTransactionsForCustomer(customerId);
    state = state.where((t) => t.customerId != customerId).toList();
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<Transaction>>((ref) {
      return TransactionNotifier(ref.watch(transactionRepositoryProvider));
    });

// Computed Providers
final customerTransactionsProvider = Provider.family<List<Transaction>, String>(
  (ref, customerId) {
    final transactions = ref.watch(transactionProvider);
    return transactions.where((t) => t.customerId == customerId).toList();
  },
);

final customerDueProvider = Provider.family<double, String>((ref, customerId) {
  final transactions = ref.watch(customerTransactionsProvider(customerId));
  double totalDue = 0;
  for (var t in transactions) {
    totalDue += (t.totalAmount - t.paidAmount);
  }
  return totalDue;
});

final totalStatsProvider = Provider((ref) {
  final transactions = ref.watch(transactionProvider);
  double totalSell = 0;
  double totalPaid = 0;

  for (var t in transactions) {
    if (t.type == TransactionType.sell) {
      totalSell += t.totalAmount;
      totalPaid += t.paidAmount;
    } else {
      totalPaid += t.paidAmount;
    }
  }

  return {'sell': totalSell, 'paid': totalPaid, 'due': totalSell - totalPaid};
});
