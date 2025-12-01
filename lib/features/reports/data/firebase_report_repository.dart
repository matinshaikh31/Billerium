import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/features/reports/domain/entity/report_model.dart';
import 'package:billing_software/features/reports/domain/repo/report_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseReportRepository implements ReportRepository {
  @override
  Future<SalesReportData> generateSalesReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startTimestamp = Timestamp.fromDate(startDate);
      final endTimestamp = Timestamp.fromDate(
        DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59),
      );

      // Query bills within date range
      final billsSnapshot = await FBFireStore.bills
          .where('createdAt', isGreaterThanOrEqualTo: startTimestamp)
          .where('createdAt', isLessThanOrEqualTo: endTimestamp)
          .get();

      double totalSales = 0;
      double totalPaid = 0;
      double totalPending = 0;
      int totalBills = billsSnapshot.docs.length;
      int totalProductsSold = 0;

      // Map to track daily sales
      Map<String, DailySalesData> dailyMap = {};

      for (var doc in billsSnapshot.docs) {
        final data = doc.data();
        final amount = (data['finalAmount'] ?? 0).toDouble();
        final paid = (data['amountPaid'] ?? 0).toDouble();
        final pending = (data['pendingAmount'] ?? 0).toDouble();
        final items = data['items'] as List<dynamic>? ?? [];

        totalSales += amount;
        totalPaid += paid;
        totalPending += pending;

        for (var item in items) {
          totalProductsSold += (item['quantity'] ?? 0) as int;
        }

        // Track daily breakdown
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        final dateKey =
            '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';

        if (dailyMap.containsKey(dateKey)) {
          final existing = dailyMap[dateKey]!;
          dailyMap[dateKey] = DailySalesData(
            date: existing.date,
            sales: existing.sales + amount,
            bills: existing.bills + 1,
          );
        } else {
          dailyMap[dateKey] = DailySalesData(
            date: createdAt,
            sales: amount,
            bills: 1,
          );
        }
      }

      // Sort daily breakdown by date
      final dailyBreakdown = dailyMap.values.toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      return SalesReportData(
        totalSales: totalSales,
        totalPaid: totalPaid,
        totalPending: totalPending,
        totalBills: totalBills,
        totalProductsSold: totalProductsSold,
        dailyBreakdown: dailyBreakdown,
      );
    } catch (e) {
      throw Exception('Failed to generate sales report: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> generatePurchaseReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startTimestamp = Timestamp.fromDate(startDate);
      final endTimestamp = Timestamp.fromDate(
        DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59),
      );

      final purchasesSnapshot = await FBFireStore.purchases
          .where('purchaseDate', isGreaterThanOrEqualTo: startTimestamp)
          .where('purchaseDate', isLessThanOrEqualTo: endTimestamp)
          .get();

      double totalPurchaseAmount = 0;
      int totalItemsPurchased = 0;
      int totalPurchases = purchasesSnapshot.docs.length;

      for (var doc in purchasesSnapshot.docs) {
        final data = doc.data();
        totalPurchaseAmount += (data['totalAmount'] ?? 0).toDouble();
        totalItemsPurchased += (data['quantity'] ?? 0) as int;
      }

      return {
        'totalPurchaseAmount': totalPurchaseAmount,
        'totalItemsPurchased': totalItemsPurchased,
        'totalPurchases': totalPurchases,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to generate purchase report: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> generateProfitReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final salesReport = await generateSalesReport(
        startDate: startDate,
        endDate: endDate,
      );
      final purchaseReport = await generatePurchaseReport(
        startDate: startDate,
        endDate: endDate,
      );

      final totalSales = salesReport.totalSales;
      final totalPurchases = (purchaseReport['totalPurchaseAmount'] ?? 0)
          .toDouble();
      final grossProfit = totalSales - totalPurchases;
      final profitMargin = totalSales > 0
          ? (grossProfit / totalSales) * 100
          : 0;

      return {
        'totalSales': totalSales,
        'totalPurchases': totalPurchases,
        'grossProfit': grossProfit,
        'profitMargin': profitMargin,
        'totalBills': salesReport.totalBills,
        'totalProductsSold': salesReport.totalProductsSold,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to generate profit report: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> generateInventoryReport() async {
    try {
      final productsSnapshot = await FBFireStore.products.get();

      int totalProducts = productsSnapshot.docs.length;
      int lowStockProducts = 0;
      int outOfStockProducts = 0;
      double totalInventoryValue = 0;

      for (var doc in productsSnapshot.docs) {
        final data = doc.data();
        final stock = (data['stock'] ?? 0) as int;
        final minStock = (data['minStock'] ?? 5) as int;
        final costPrice = (data['costPrice'] ?? 0).toDouble();

        totalInventoryValue += stock * costPrice;

        if (stock == 0) {
          outOfStockProducts++;
        } else if (stock <= minStock) {
          lowStockProducts++;
        }
      }

      return {
        'totalProducts': totalProducts,
        'lowStockProducts': lowStockProducts,
        'outOfStockProducts': outOfStockProducts,
        'totalInventoryValue': totalInventoryValue,
      };
    } catch (e) {
      throw Exception('Failed to generate inventory report: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> generateTransactionReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startTimestamp = Timestamp.fromDate(startDate);
      final endTimestamp = Timestamp.fromDate(
        DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59),
      );

      final transactionsSnapshot = await FBFireStore.transactions
          .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
          .where('timestamp', isLessThanOrEqualTo: endTimestamp)
          .get();

      double totalAmount = 0;
      int totalTransactions = transactionsSnapshot.docs.length;
      Map<String, double> modeBreakdown = {};

      for (var doc in transactionsSnapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] ?? 0).toDouble();
        final mode = data['mode'] ?? 'Cash';

        totalAmount += amount;
        modeBreakdown[mode] = (modeBreakdown[mode] ?? 0) + amount;
      }

      return {
        'totalAmount': totalAmount,
        'totalTransactions': totalTransactions,
        'modeBreakdown': modeBreakdown,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to generate transaction report: $e');
    }
  }
}
