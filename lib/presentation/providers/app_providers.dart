import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/transaction.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../domain/entities/product.dart';
import '../../data/repositories/product_repository.dart';

// Repository Providers
final customerRepositoryProvider = Provider((ref) => CustomerRepository());
final transactionRepositoryProvider = Provider(
  (ref) => TransactionRepository(),
);
final productRepositoryProvider = Provider((ref) => SembastProductRepository());

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

// Product State
class ProductNotifier extends StateNotifier<List<Product>> {
  final SembastProductRepository _repo;
  ProductNotifier(this._repo) : super([]) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    state = await _repo.getProducts();
    // Also listen to changes if we want real-time updates, but load is fine for now
    // Or prefer watching:
    _repo.watchProducts().listen((products) {
      state = products;
    });
  }

  Future<void> addProduct(Product product) async {
    await _repo.addProduct(product);
  }

  Future<void> updateProduct(Product product) async {
    await _repo.updateProduct(product);
  }

  Future<void> deleteProduct(String id) async {
    await _repo.deleteProduct(id);
  }
}

final productProvider = StateNotifierProvider<ProductNotifier, List<Product>>((
  ref,
) {
  return ProductNotifier(ref.watch(productRepositoryProvider));
});

// Computed Providers
final customerTransactionsProvider = Provider.family<List<Transaction>, String>(
  (ref, customerId) {
    final transactions = ref.watch(transactionProvider);
    final filtered = transactions
        .where((t) => t.customerId == customerId)
        .toList();
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return filtered;
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
