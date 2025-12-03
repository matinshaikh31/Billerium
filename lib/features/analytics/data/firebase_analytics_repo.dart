import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/features/analytics/domain/entity/monthly_sales_model.dart';
import 'package:billing_software/features/billing/domain/entity/bill_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAnalyticsRepository {
  final analyticsRef = FBFireStore.analytics; // base collection: analytics/

  String _monthKeyFromTimestamp(Timestamp ts) {
    final date = ts.toDate();
    return "${date.year}-${date.month.toString().padLeft(2, '0')}";
  }

  Future<void> updateAnalyticsOnBillCreate(BillModel bill) async {
    try {
      // Use billDate if available, otherwise use createdAt
      final effectiveDate = bill.billDate ?? bill.createdAt;
      final monthKey = _monthKeyFromTimestamp(effectiveDate);
      final docRef = analyticsRef.doc(monthKey);

      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        final newDoc = MonthlySalesModel(
          id: monthKey,
          totalSales: bill.finalAmount,
          totalPaid: bill.amountPaid,
          totalPending: bill.pendingAmount,
          totalBills: 1,
          totalProductsSold: bill.items.fold(
            0,
            (sum, item) => sum + item.quantity,
          ),
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        );
        await docRef.set(newDoc.toJson());
      } else {
        await docRef.update({
          'totalSales': FieldValue.increment(bill.finalAmount),
          'totalPaid': FieldValue.increment(bill.amountPaid),
          'totalPending': FieldValue.increment(bill.pendingAmount),
          'totalBills': FieldValue.increment(1),
          'totalProductsSold': FieldValue.increment(
            bill.items.fold(0, (sum, item) => sum + item.quantity),
          ),
          'updatedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      print("❌ Failed to update monthly analytics: $e");
    }
  }

  Future<void> updateAnalyticsOnPayment({
    required double paymentAmount,
    required double pendingChange,
    required Timestamp timestamp,
  }) async {
    try {
      final monthKey = _monthKeyFromTimestamp(timestamp);
      final docRef = analyticsRef.doc(monthKey);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        await docRef.update({
          'totalPaid': FieldValue.increment(paymentAmount),
          'totalPending': FieldValue.increment(-pendingChange),
          'updatedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      print("❌ Failed to update monthly payment analytics: $e");
    }
  }

  Future<MonthlySalesModel?> getMonthlyAnalytics(String monthKey) async {
    try {
      final doc = await analyticsRef.doc(monthKey).get();
      if (!doc.exists) return null;
      return MonthlySalesModel.fromJson(doc.data()!, monthKey);
    } catch (e) {
      print("❌ Failed to get monthly analytics: $e");
      return null;
    }
  }

  Stream<List<MonthlySalesModel>> getAllMonthsStream() {
    return analyticsRef
        .orderBy(FieldPath.documentId, descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => MonthlySalesModel.fromJson(d.data(), d.id))
              .toList(),
        );
  }

  // Get all available months as a list (for dropdown)
  Future<List<String>> getAllMonthKeys() async {
    try {
      final snapshot = await analyticsRef
          .orderBy(FieldPath.documentId, descending: true)
          .get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print("❌ Failed to get month keys: $e");
      return [];
    }
  }

  // Get all available years
  Future<List<String>> getAllYears() async {
    try {
      final monthKeys = await getAllMonthKeys();
      final years = monthKeys.map((key) => key.split('-')[0]).toSet().toList()
        ..sort((a, b) => b.compareTo(a)); // Sort descending
      return years;
    } catch (e) {
      print("❌ Failed to get years: $e");
      return [];
    }
  }

  // Get all months for a specific year
  Future<List<MonthlySalesModel>> getYearMonths(String year) async {
    try {
      final snapshot = await analyticsRef
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: '$year-01')
          .where(FieldPath.documentId, isLessThanOrEqualTo: '$year-12')
          .get();

      return snapshot.docs
          .map((d) => MonthlySalesModel.fromJson(d.data(), d.id))
          .toList();
    } catch (e) {
      print("❌ Failed to get year months: $e");
      return [];
    }
  }

  /// Reverse analytics when a bill is deleted
  Future<void> reverseAnalyticsOnBillDelete(BillModel bill) async {
    try {
      // Use billDate if available, otherwise use createdAt
      final effectiveDate = bill.billDate ?? bill.createdAt;
      final monthKey = _monthKeyFromTimestamp(effectiveDate);
      final docRef = analyticsRef.doc(monthKey);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        final totalProductsSold = bill.items.fold(
          0,
          (sum, item) => sum + item.quantity,
        );

        await docRef.update({
          'totalSales': FieldValue.increment(-bill.finalAmount),
          'totalPaid': FieldValue.increment(-bill.amountPaid),
          'totalPending': FieldValue.increment(-bill.pendingAmount),
          'totalBills': FieldValue.increment(-1),
          'totalProductsSold': FieldValue.increment(-totalProductsSold),
          'updatedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      print("❌ Failed to reverse analytics on bill delete: $e");
    }
  }

  /// Update analytics when a bill is edited (reverse old values and add new values)
  Future<void> updateAnalyticsOnBillEdit({
    required BillModel oldBill,
    required BillModel newBill,
  }) async {
    try {
      // Reverse old bill analytics
      await reverseAnalyticsOnBillDelete(oldBill);

      // Add new bill analytics
      await updateAnalyticsOnBillCreate(newBill);
    } catch (e) {
      print("❌ Failed to update analytics on bill edit: $e");
    }
  }

  /// Rebuild all analytics from existing bills
  /// This clears all analytics data and recalculates from bills
  Future<void> rebuildAnalyticsFromBills() async {
    try {
      // Step 1: Delete all existing analytics documents
      final existingDocs = await analyticsRef.get();
      for (final doc in existingDocs.docs) {
        await doc.reference.delete();
      }
      print("✅ Cleared existing analytics data");

      // Step 2: Fetch all bills
      final billsSnapshot = await FBFireStore.bills.get();
      final bills = billsSnapshot.docs.map((doc) {
        return BillModel.fromJson(doc.data(), doc.id);
      }).toList();

      print("📊 Found ${bills.length} bills to process");

      // Step 3: Group bills by month
      final Map<String, List<BillModel>> billsByMonth = {};
      for (final bill in bills) {
        final effectiveDate = bill.billDate ?? bill.createdAt;
        final monthKey = _monthKeyFromTimestamp(effectiveDate);
        billsByMonth.putIfAbsent(monthKey, () => []);
        billsByMonth[monthKey]!.add(bill);
      }

      // Step 4: Calculate analytics for each month
      for (final entry in billsByMonth.entries) {
        final monthKey = entry.key;
        final monthBills = entry.value;

        double totalSales = 0;
        double totalPaid = 0;
        double totalPending = 0;
        int totalBillsCount = monthBills.length;
        int totalProductsSold = 0;

        for (final bill in monthBills) {
          totalSales += bill.finalAmount;
          totalPaid += bill.amountPaid;
          totalPending += bill.pendingAmount;
          totalProductsSold += bill.items.fold(
            0,
            (sum, item) => sum + item.quantity,
          );
        }

        final monthlyData = MonthlySalesModel(
          id: monthKey,
          totalSales: totalSales,
          totalPaid: totalPaid,
          totalPending: totalPending,
          totalBills: totalBillsCount,
          totalProductsSold: totalProductsSold,
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        );

        await analyticsRef.doc(monthKey).set(monthlyData.toJson());
        print("✅ Created analytics for $monthKey: $totalBillsCount bills");
      }

      print("🎉 Analytics rebuild complete!");
    } catch (e) {
      print("❌ Failed to rebuild analytics: $e");
      rethrow;
    }
  }
}
