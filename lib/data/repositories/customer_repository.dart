import 'package:sembast/sembast.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/i_customer_repository.dart';
import '../datasources/database_service.dart';

class CustomerRepository implements ICustomerRepository {
  final _store = stringMapStoreFactory.store('customers');

  @override
  Future<List<Customer>> getCustomers(String shopId) async {
    final db = await DatabaseService.instance.database;
    final finder = Finder(filter: Filter.equals('shopId', shopId));
    final snapshots = await _store.find(db, finder: finder);
    return snapshots.map((s) => Customer.fromJson(s.value)).toList();
  }

  @override
  Future<void> addCustomer(Customer customer) async {
    final db = await DatabaseService.instance.database;
    await _store.record(customer.id).put(db, customer.toJson());
  }

  @override
  Future<void> deleteCustomer(String id) async {
    final db = await DatabaseService.instance.database;
    await _store.record(id).delete(db);
  }
}
