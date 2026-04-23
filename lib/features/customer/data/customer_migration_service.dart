import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/features/billing/domain/entity/bill_model.dart';
import 'package:billing_software/features/customer/data/firebase_customer_analytics_repository.dart';
import 'package:billing_software/features/customer/data/firebase_customer_repository.dart';
import 'package:billing_software/features/customer/domain/entity/customer_model.dart';
import 'package:billing_software/features/transactions/domain/models/transaction_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerMigrationService {
  final FirebaseCustomerRepository _customerRepo = FirebaseCustomerRepository();
  final FirebaseCustomerAnalyticsRepository _analyticsRepo =
      FirebaseCustomerAnalyticsRepository();

  /// Main migration function
  /// Groups bills/transactions by phone number, creates customers, and updates everything
  Future<Map<String, dynamic>> migrateCustomerData() async {
    try {
      print('🚀 Starting customer data migration...');

      // Step 1: Fetch all bills and transactions
      print('📥 Fetching all bills and transactions...');
      final billsSnapshot = await FBFireStore.bills.get();
      final transactionsSnapshot = await FBFireStore.transactions.get();

      final bills = billsSnapshot.docs
          .map((doc) => BillModel.fromJson(doc.data(), doc.id))
          .toList();
      final transactions = transactionsSnapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data(), doc.id))
          .toList();

      print(
        '✅ Fetched ${bills.length} bills and ${transactions.length} transactions',
      );

      // Step 2: Group by phone number and merge data
      print('🔄 Grouping by phone number...');
      final customerData = await _groupByPhoneNumber(bills, transactions);
      print('✅ Found ${customerData.length} unique customers');

      // Step 3: Create or update customers
      print('👥 Creating/updating customers...');
      final customerMap = await _createCustomers(customerData);
      print('✅ Created/updated ${customerMap.length} customers');

      // Step 4: Update bills with customer IDs
      print('📝 Updating bills with customer IDs...');
      final billsUpdated = await _updateBills(bills, customerMap);
      print('✅ Updated $billsUpdated bills');

      // Step 5: Update transactions with customer IDs
      print('💳 Updating transactions with customer IDs...');
      final transactionsUpdated = await _updateTransactions(
        transactions,
        customerMap,
      );
      print('✅ Updated $transactionsUpdated transactions');

      // Step 6: Update customer analytics
      print('📊 Updating customer analytics...');
      final analyticsUpdated = await _updateCustomerAnalytics(
        bills,
        customerMap,
      );
      print('✅ Updated analytics for $analyticsUpdated customers');

      print('🎉 Migration completed successfully!');

      return {
        'success': true,
        'customersCreated': customerMap.length,
        'billsUpdated': billsUpdated,
        'transactionsUpdated': transactionsUpdated,
        'analyticsUpdated': analyticsUpdated,
      };
    } catch (e) {
      print('❌ Migration failed: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Group bills and transactions by phone number
  /// Takes the longest name for each phone number
  Future<Map<String, CustomerData>> _groupByPhoneNumber(
    List<BillModel> bills,
    List<TransactionModel> transactions,
  ) async {
    final Map<String, CustomerData> customerDataMap = {};

    // Process bills
    for (final bill in bills) {
      final phone = _normalizePhone(bill.customerPhone);
      if (phone.isEmpty) continue;

      final name = bill.customerName ?? '';

      if (!customerDataMap.containsKey(phone)) {
        customerDataMap[phone] = CustomerData(
          phone: phone,
          name: name,
          bills: [],
          transactions: [],
        );
      } else {
        // Take the longest name
        if (name.length > customerDataMap[phone]!.name.length) {
          customerDataMap[phone]!.name = name;
        }
      }

      customerDataMap[phone]!.bills.add(bill);
    }

    // Process transactions to find additional names
    for (final transaction in transactions) {
      final phone = _normalizePhone(transaction.customerPhone);
      if (phone.isEmpty) continue;

      final name = transaction.customerName;

      if (!customerDataMap.containsKey(phone)) {
        customerDataMap[phone] = CustomerData(
          phone: phone,
          name: name,
          bills: [],
          transactions: [],
        );
      } else {
        // Take the longest name
        if (name.length > customerDataMap[phone]!.name.length) {
          customerDataMap[phone]!.name = name;
        }
      }

      customerDataMap[phone]!.transactions.add(transaction);
    }

    return customerDataMap;
  }

  /// Create or update customers
  Future<Map<String, String>> _createCustomers(
    Map<String, CustomerData> customerData,
  ) async {
    final Map<String, String> phoneToCustomerId = {};

    for (final entry in customerData.entries) {
      final phone = entry.key;
      final data = entry.value;

      // Check if customer already exists
      final existingCustomers = await _customerRepo.searchCustomers(phone);

      String customerId;
      if (existingCustomers.isNotEmpty) {
        // Update existing customer
        customerId = existingCustomers.first.id;
        final existingCustomer = existingCustomers.first;

        // Only update name if new name is longer
        final updatedName = data.name.length > existingCustomer.name.length
            ? data.name
            : existingCustomer.name;

        final updatedCustomer = existingCustomer.copyWith(
          name: updatedName,
          updatedAt: Timestamp.now(),
        );

        await _customerRepo.updateCustomer(updatedCustomer);
      } else {
        // Create new customer
        final now = Timestamp.now();
        final newCustomer = CustomerModel(
          id: '',
          name: data.name,
          phone: phone,
          email: null,
          address: null,
          balance: 0,
          totalPurchases: 0,
          totalProfit: 0,
          orderCount: 0,
          createdAt: now,
          updatedAt: now,
        );

        customerId = await _customerRepo.createCustomer(newCustomer);
      }

      phoneToCustomerId[phone] = customerId;
    }

    return phoneToCustomerId;
  }

  /// Update bills with customer IDs
  Future<int> _updateBills(
    List<BillModel> bills,
    Map<String, String> phoneToCustomerId,
  ) async {
    int updated = 0;

    for (final bill in bills) {
      final phone = _normalizePhone(bill.customerPhone);
      if (phone.isEmpty) continue;

      final customerId = phoneToCustomerId[phone];
      if (customerId == null) continue;

      // Skip if already has customer ID
      if (bill.customerId == customerId) continue;

      try {
        await FBFireStore.bills.doc(bill.id).update({
          'customerId': customerId,
          'updatedAt': Timestamp.now(),
        });
        updated++;
      } catch (e) {
        print('Error updating bill ${bill.id}: $e');
      }
    }

    return updated;
  }

  /// Update transactions with customer IDs
  Future<int> _updateTransactions(
    List<TransactionModel> transactions,
    Map<String, String> phoneToCustomerId,
  ) async {
    int updated = 0;

    for (final transaction in transactions) {
      final phone = _normalizePhone(transaction.customerPhone);
      if (phone.isEmpty) continue;

      final customerId = phoneToCustomerId[phone];
      if (customerId == null) continue;

      // Skip if already has customer ID
      if (transaction.customerId == customerId) continue;

      try {
        await FBFireStore.transactions.doc(transaction.id).update({
          'customerId': customerId,
          'updatedAt': Timestamp.now(),
        });
        updated++;
      } catch (e) {
        print('Error updating transaction ${transaction.id}: $e');
      }
    }

    return updated;
  }

  /// Update customer analytics based on bills
  Future<int> _updateCustomerAnalytics(
    List<BillModel> bills,
    Map<String, String> phoneToCustomerId,
  ) async {
    final Map<String, CustomerAnalytics> customerAnalytics = {};

    // Group bills by customer ID and calculate analytics
    for (final bill in bills) {
      final phone = _normalizePhone(bill.customerPhone);
      if (phone.isEmpty) continue;

      final customerId = phoneToCustomerId[phone];
      if (customerId == null) continue;

      if (!customerAnalytics.containsKey(customerId)) {
        customerAnalytics[customerId] = CustomerAnalytics(
          customerId: customerId,
          totalPurchases: 0,
          totalProfit: 0,
          orderCount: 0,
        );
      }

      customerAnalytics[customerId]!.totalPurchases += bill.finalAmount;
      customerAnalytics[customerId]!.totalProfit += bill.totalTax;
      customerAnalytics[customerId]!.orderCount++;

      // Update monthly analytics
      try {
        final billDate = bill.billDate?.toDate() ?? DateTime.now();
        await _analyticsRepo.updateMonthlyAnalytics(
          customerId: customerId,
          billDate: billDate,
          billAmount: bill.finalAmount,
          profit: bill.totalTax,
          amountPaid: bill.amountPaid,
          balanceUsed: 0,
        );
      } catch (e) {
        // Error updating monthly analytics - skip
      }
    }

    // Update customer totals
    int updated = 0;
    for (final entry in customerAnalytics.entries) {
      final customerId = entry.key;
      final analytics = entry.value;

      try {
        await _customerRepo.updateAnalytics(
          customerId: customerId,
          purchaseAmount: analytics.totalPurchases,
          profit: analytics.totalProfit,
        );
        updated++;
      } catch (e) {
        print('Error updating analytics: $e');
      }
    }

    return updated;
  }

  /// Normalize phone number
  String _normalizePhone(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }
}

class CustomerData {
  String phone;
  String name;
  List<BillModel> bills;
  List<TransactionModel> transactions;

  CustomerData({
    required this.phone,
    required this.name,
    required this.bills,
    required this.transactions,
  });
}

class CustomerAnalytics {
  final String customerId;
  double totalPurchases;
  double totalProfit;
  int orderCount;

  CustomerAnalytics({
    required this.customerId,
    required this.totalPurchases,
    required this.totalProfit,
    required this.orderCount,
  });
}
