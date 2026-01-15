import '../../domain/entities/customer.dart';

abstract class ICustomerRepository {
  Future<List<Customer>> getCustomers();
  Future<void> addCustomer(Customer customer);
  Future<void> deleteCustomer(String id);
}
