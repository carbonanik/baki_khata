import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/customer.dart';
import '../models/transaction.dart';

// Customer State
class CustomerNotifier extends StateNotifier<List<Customer>> {
  CustomerNotifier() : super([]);

  void addCustomer(Customer customer) {
    state = [...state, customer];
  }

  void deleteCustomer(String id) {
    state = state.where((c) => c.id != id).toList();
  }
}

final customerProvider =
    StateNotifierProvider<CustomerNotifier, List<Customer>>((ref) {
      return CustomerNotifier();
    });

// Transaction State
class TransactionNotifier extends StateNotifier<List<Transaction>> {
  TransactionNotifier() : super([]);

  void addTransaction(Transaction transaction) {
    state = [...state, transaction];
  }

  void deleteTransactionsForCustomer(String customerId) {
    state = state.where((t) => t.customerId != customerId).toList();
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<Transaction>>((ref) {
      return TransactionNotifier();
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
