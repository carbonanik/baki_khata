import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/transaction.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../domain/entities/product.dart';
import '../../data/repositories/product_repository.dart';
import '../../domain/entities/expense.dart';
import '../../data/repositories/expense_repository.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/shop.dart';
import '../../data/repositories/shop_repository.dart';
import 'shop_provider.dart';

// Shared Preferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// Repository Providers
final shopRepositoryProvider = Provider((ref) => ShopRepository());
final customerRepositoryProvider = Provider((ref) => CustomerRepository());
final transactionRepositoryProvider = Provider(
  (ref) => TransactionRepository(),
);
final productRepositoryProvider = Provider((ref) => SembastProductRepository());
final expenseRepositoryProvider = Provider((ref) => ExpenseRepository());

// Shop State
final shopProvider = StateNotifierProvider<ShopNotifier, Shop?>((ref) {
  final repo = ref.watch(shopRepositoryProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return ShopNotifier(repo, prefs);
});

// Customer State
class CustomerNotifier extends StateNotifier<List<Customer>> {
  final CustomerRepository _repo;
  final String _shopId;

  CustomerNotifier(this._repo, this._shopId) : super([]) {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    final customers = await _repo.getCustomers(_shopId);
    if (mounted) {
      state = customers;
    }
  }

  Future<void> addCustomer(Customer customer) async {
    // Ensure the customer has the correct shopId
    final customerWithShop = customer.copyWith(shopId: _shopId);
    await _repo.addCustomer(customerWithShop);
    state = [...state, customerWithShop];
  }

  Future<void> deleteCustomer(String id) async {
    await _repo.deleteCustomer(id);
    state = state.where((c) => c.id != id).toList();
  }
}

final customerProvider =
    StateNotifierProvider<CustomerNotifier, List<Customer>>((ref) {
      final shop = ref.watch(shopProvider);
      if (shop == null)
        return CustomerNotifier(ref.watch(customerRepositoryProvider), '');

      return CustomerNotifier(ref.watch(customerRepositoryProvider), shop.id);
    });

// Transaction State
class TransactionNotifier extends StateNotifier<List<Transaction>> {
  final TransactionRepository _repo;
  final String _shopId;

  TransactionNotifier(this._repo, this._shopId) : super([]) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final transactions = await _repo.getTransactions(_shopId);
    if (mounted) {
      state = transactions;
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    final finalTransaction = Transaction(
      id: transaction.id,
      shopId: _shopId,
      customerId: transaction.customerId,
      type: transaction.type,
      items: transaction.items,
      totalAmount: transaction.totalAmount,
      paidAmount: transaction.paidAmount,
      note: transaction.note,
      timestamp: transaction.timestamp,
    );

    await _repo.addTransaction(finalTransaction);
    state = [...state, finalTransaction];
  }

  Future<void> deleteTransactionsForCustomer(String customerId) async {
    await _repo.deleteTransactionsForCustomer(customerId);
    state = state.where((t) => t.customerId != customerId).toList();
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<Transaction>>((ref) {
      final shop = ref.watch(shopProvider);
      if (shop == null)
        return TransactionNotifier(
          ref.watch(transactionRepositoryProvider),
          '',
        );

      return TransactionNotifier(
        ref.watch(transactionRepositoryProvider),
        shop.id,
      );
    });

// Product State
class ProductNotifier extends StateNotifier<List<Product>> {
  final SembastProductRepository _repo;
  final String _shopId;

  ProductNotifier(this._repo, this._shopId) : super([]) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    state = await _repo.getProducts(_shopId);
    _repo.watchProducts(_shopId).listen((products) {
      state = products;
    });
  }

  Future<void> addProduct(Product product) async {
    final productWithShop = Product(
      id: product.id,
      shopId: _shopId,
      name: product.name,
      price: product.price,
    );
    await _repo.addProduct(productWithShop);
  }

  Future<void> updateProduct(Product product) async {
    // Ensure shopId is preserved or enforced
    final productWithShop = Product(
      id: product.id,
      shopId: _shopId,
      name: product.name,
      price: product.price,
    );
    await _repo.updateProduct(productWithShop);
  }

  Future<void> deleteProduct(String id) async {
    await _repo.deleteProduct(id);
  }
}

final productProvider = StateNotifierProvider<ProductNotifier, List<Product>>((
  ref,
) {
  final shop = ref.watch(shopProvider);
  if (shop == null)
    return ProductNotifier(ref.watch(productRepositoryProvider), '');

  return ProductNotifier(ref.watch(productRepositoryProvider), shop.id);
});

// Expense State
class ExpenseNotifier extends StateNotifier<List<Expense>> {
  final ExpenseRepository _repo;
  final String _shopId;

  ExpenseNotifier(this._repo, this._shopId) : super([]) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    final expenses = await _repo.getExpenses(_shopId);
    if (mounted) {
      state = expenses;
    }
  }

  Future<void> addExpense(Expense expense) async {
    final expenseWithShop = expense.copyWith(shopId: _shopId);
    await _repo.addExpense(expenseWithShop);
    state = [...state, expenseWithShop];
  }

  Future<void> deleteExpense(String id) async {
    await _repo.deleteExpense(id);
    state = state.where((e) => e.id != id).toList();
  }
}

final expenseProvider = StateNotifierProvider<ExpenseNotifier, List<Expense>>((
  ref,
) {
  final shop = ref.watch(shopProvider);
  if (shop == null)
    return ExpenseNotifier(ref.watch(expenseRepositoryProvider), '');
  return ExpenseNotifier(ref.watch(expenseRepositoryProvider), shop.id);
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

final totalExpenseProvider = Provider((ref) {
  final expenses = ref.watch(expenseProvider);
  return expenses.fold(0.0, (sum, item) => sum + item.amount);
});
