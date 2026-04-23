import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/features/customer/domain/entity/customer_model.dart';
import 'package:billing_software/features/customer/domain/repo/customer_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseCustomerRepository extends CustomerRepository {
  final customersCollectionRef = FBFireStore.customers;

  @override
  Future<String> createCustomer(CustomerModel customer) async {
    try {
      final docRef = customersCollectionRef.doc();
      final now = Timestamp.now();

      final newCustomer = CustomerModel(
        id: docRef.id,
        name: customer.name,
        phone: customer.phone,
        email: customer.email,
        address: customer.address,
        balance: 0, // Start with zero balance
        totalPurchases: 0,
        totalProfit: 0,
        orderCount: 0,
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(newCustomer.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create customer: ${e.toString()}');
    }
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      final updatedCustomer = CustomerModel(
        id: customer.id,
        name: customer.name,
        phone: customer.phone,
        email: customer.email,
        address: customer.address,
        balance: customer.balance,
        totalPurchases: customer.totalPurchases,
        totalProfit: customer.totalProfit,
        orderCount: customer.orderCount,
        createdAt: customer.createdAt,
        updatedAt: Timestamp.now(),
      );

      await customersCollectionRef.doc(customer.id).update(updatedCustomer.toJson());
    } catch (e) {
      throw Exception('Failed to update customer: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    try {
      await customersCollectionRef.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete customer: ${e.toString()}');
    }
  }

  @override
  Future<CustomerModel?> getCustomer(String id) async {
    try {
      final doc = await customersCollectionRef.doc(id).get();
      if (doc.exists && doc.data() != null) {
        return CustomerModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get customer: ${e.toString()}');
    }
  }

  @override
  Future<List<CustomerModel>> getCustomers({
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = customersCollectionRef
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => CustomerModel.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      throw Exception('Failed to get customers: ${e.toString()}');
    }
  }

  @override
  Future<List<CustomerModel>> searchCustomers(String query) async {
    try {
      final queryLower = query.toLowerCase();
      final snapshot = await customersCollectionRef
          .where('nameLowercase', isGreaterThanOrEqualTo: queryLower)
          .where('nameLowercase', isLessThan: '$queryLower\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs.map((doc) => CustomerModel.fromDocSnap(doc)).toList();
    } catch (e) {
      throw Exception('Failed to search customers: ${e.toString()}');
    }
  }

  @override
  Future<void> updateBalance(String customerId, double amount) async {
    try {
      final customerDoc = await customersCollectionRef.doc(customerId).get();
      if (customerDoc.exists) {
        final currentBalance = (customerDoc.data()?['balance'] ?? 0).toDouble();
        final newBalance = currentBalance + amount;

        await customersCollectionRef.doc(customerId).update({
          'balance': newBalance,
          'updatedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      throw Exception('Failed to update balance: ${e.toString()}');
    }
  }

  @override
  Future<void> updateAnalytics({
    required String customerId,
    required double purchaseAmount,
    required double profit,
  }) async {
    try {
      final customerDoc = await customersCollectionRef.doc(customerId).get();
      if (customerDoc.exists) {
        final data = customerDoc.data()!;
        final currentPurchases = (data['totalPurchases'] ?? 0).toDouble();
        final currentProfit = (data['totalProfit'] ?? 0).toDouble();
        final currentOrders = (data['orderCount'] ?? 0) as int;

        await customersCollectionRef.doc(customerId).update({
          'totalPurchases': currentPurchases + purchaseAmount,
          'totalProfit': currentProfit + profit,
          'orderCount': currentOrders + 1,
          'updatedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      throw Exception('Failed to update analytics: ${e.toString()}');
    }
  }

  @override
  Future<int> getCustomerCount() async {
    final snapshot = await customersCollectionRef.count().get();
    return snapshot.count ?? 0;
  }
}
