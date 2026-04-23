import 'package:billing_software/features/customer/domain/entity/customer_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class CustomerRepository {
  // CRUD operations
  Future<String> createCustomer(CustomerModel customer);
  Future<void> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String id);
  Future<CustomerModel?> getCustomer(String id);

  // Pagination
  Future<List<CustomerModel>> getCustomers({
    required int limit,
    DocumentSnapshot? startAfter,
  });

  // Search
  Future<List<CustomerModel>> searchCustomers(String query);

  // Balance management
  Future<void> updateBalance(String customerId, double amount);
  Future<void> updateAnalytics({
    required String customerId,
    required double purchaseAmount,
    required double profit,
  });

  // Count
  Future<int> getCustomerCount();
}
