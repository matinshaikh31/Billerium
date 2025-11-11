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
      final monthKey = _monthKeyFromTimestamp(bill.createdAt);
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

  Future<void> updateAnalyticsOnPayment(
    double amount,
    bool isFullyPaid,
    Timestamp time,
  ) async {
    try {
      final monthKey = _monthKeyFromTimestamp(time);
      final docRef = analyticsRef.doc(monthKey);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        await docRef.update({
          'totalPaid': FieldValue.increment(amount),
          if (isFullyPaid) 'totalPending': FieldValue.increment(-amount),
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
}
