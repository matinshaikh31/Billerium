import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/features/customer/domain/entity/monthly_customer_analytics_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseCustomerAnalyticsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Update monthly analytics for a customer when a bill is created
  /// New structure: /customerAnalytics/{customerId_monthId}
  Future<void> updateMonthlyAnalytics({
    required String customerId,
    required DateTime billDate,
    required double billAmount,
    required double profit,
    required double amountPaid,
    required double balanceUsed,
    bool isNewBill = true, // true for create, false for update/delete
  }) async {
    try {
      final year = billDate.year;
      final month = billDate.month;

      // Generate composite document ID: customerId_monthId (e.g., "cust123_2024-01")
      final docId = MonthlyCustomerAnalyticsModel.generateDocId(
        customerId,
        billDate,
      );

      final docRef = _firestore.collection('customerAnalytics').doc(docId);

      final doc = await docRef.get();
      final now = Timestamp.now();

      if (doc.exists) {
        // Update existing analytics
        final data = doc.data()!;
        final currentTotalSales = (data['totalSales'] ?? 0).toDouble();
        final currentTotalProfit = (data['totalProfit'] ?? 0).toDouble();
        final currentOrderCount = (data['orderCount'] ?? 0) as int;
        final currentTotalPayments = (data['totalPayments'] ?? 0).toDouble();
        final currentBalanceUsed = (data['balanceUsed'] ?? 0).toDouble();

        final newTotalSales =
            currentTotalSales + (isNewBill ? billAmount : -billAmount);
        final newTotalProfit =
            currentTotalProfit + (isNewBill ? profit : -profit);
        final newOrderCount = currentOrderCount + (isNewBill ? 1 : -1);
        final newTotalPayments =
            currentTotalPayments + (isNewBill ? amountPaid : -amountPaid);
        final newBalanceUsed =
            currentBalanceUsed + (isNewBill ? balanceUsed : -balanceUsed);
        final newAvgOrderValue = newOrderCount > 0
            ? newTotalSales / newOrderCount
            : 0.0;

        await docRef.update({
          'totalSales': newTotalSales,
          'totalProfit': newTotalProfit,
          'orderCount': newOrderCount,
          'averageOrderValue': newAvgOrderValue,
          'totalPurchases': newTotalSales,
          'totalPayments': newTotalPayments,
          'balanceUsed': newBalanceUsed,
          'updatedAt': now,
        });
      } else {
        // Create new analytics document
        final analytics = MonthlyCustomerAnalyticsModel(
          id: docId, // Use composite ID
          customerId: customerId,
          year: year,
          month: month,
          totalSales: billAmount,
          totalProfit: profit,
          orderCount: 1,
          averageOrderValue: billAmount,
          totalPurchases: billAmount,
          totalPayments: amountPaid,
          balanceUsed: balanceUsed,
          balanceAdded: 0,
          createdAt: now,
          updatedAt: now,
        );

        await docRef.set(analytics.toJson());
      }
    } catch (e) {
      throw Exception('Failed to update monthly analytics: ${e.toString()}');
    }
  }

  /// Get monthly analytics for a customer
  /// Queries flat collection with customerId filter
  Future<List<MonthlyCustomerAnalyticsModel>> getMonthlyAnalytics(
    String customerId, {
    int? year,
  }) async {
    try {
      Query query = _firestore
          .collection('customerAnalytics')
          .where('customerId', isEqualTo: customerId)
          .orderBy('year', descending: true)
          .orderBy('month', descending: true);

      if (year != null) {
        query = query.where('year', isEqualTo: year);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map(
            (doc) => MonthlyCustomerAnalyticsModel.fromJson(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get monthly analytics: ${e.toString()}');
    }
  }

  /// Get yearly analytics (aggregated from monthly)
  /// Queries flat collection with customerId filter
  Future<Map<int, double>> getYearlyAnalytics(String customerId) async {
    try {
      final snapshot = await _firestore
          .collection('customerAnalytics')
          .where('customerId', isEqualTo: customerId)
          .get();

      final yearlyTotals = <int, double>{};

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final year = data['year'] as int;
        final totalSales = (data['totalSales'] ?? 0).toDouble();

        yearlyTotals[year] = (yearlyTotals[year] ?? 0) + totalSales;
      }

      return yearlyTotals;
    } catch (e) {
      throw Exception('Failed to get yearly analytics: ${e.toString()}');
    }
  }

  /// Delete analytics when bill is deleted
  Future<void> removeBillFromAnalytics({
    required String customerId,
    required DateTime billDate,
    required double billAmount,
    required double profit,
    required double amountPaid,
    required double balanceUsed,
  }) async {
    await updateMonthlyAnalytics(
      customerId: customerId,
      billDate: billDate,
      billAmount: billAmount,
      profit: profit,
      amountPaid: amountPaid,
      balanceUsed: balanceUsed,
      isNewBill: false, // Subtract instead of add
    );
  }
}
