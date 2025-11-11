import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/features/analytics/data/firebase_analytics_repo.dart';
import 'package:billing_software/features/billing/domain/entity/bill_item_model.dart';
import 'package:billing_software/features/billing/domain/repo/fbill_repository.dart';
import 'package:billing_software/features/billing/domain/entity/bill_model.dart';
import 'package:billing_software/features/billing/domain/entity/payment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseBillRepository extends BillRepository {
  final billsCollectionRef = FBFireStore.bills;
  final analyticsRepo = FirebaseAnalyticsRepository();

  Future<void> _updateProductStockAfterSale(List<BillItemModel> items) async {
    final batch = FirebaseFirestore.instance.batch();

    for (final item in items) {
      final productRef = FBFireStore.products.doc(item.productId);
      final productSnap = await productRef.get();

      if (productSnap.exists) {
        final currentStock = productSnap.data()!['stockQty'] ?? 0;
        final newStock = (currentStock - item.quantity).clamp(
          0,
          double.infinity,
        );

        batch.update(productRef, {'stockQty': newStock});
      }
    }

    await batch.commit();
  }

  @override
  Future<String> createBill(BillModel bill) async {
    try {
      final docRef = billsCollectionRef.doc();
      final now = Timestamp.now();

      final newBill = BillModel(
        id: docRef.id,
        items: bill.items,
        customerName: bill.customerName,
        customerPhone: bill.customerPhone,
        subtotal: bill.subtotal,
        totalDiscount: bill.totalDiscount,
        totalTax: bill.totalTax,
        billDiscountPercent: bill.billDiscountPercent,
        billDiscountAmount: bill.billDiscountAmount,
        finalAmount: bill.finalAmount,
        amountPaid: bill.amountPaid,
        pendingAmount: bill.pendingAmount,
        status: bill.status,
        payments: bill.payments,
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(newBill.toJson());

      // Update stock
      await _updateProductStockAfterSale(newBill.items);

      // Create transaction for each payment
      for (final payment in bill.payments) {
        await _createTransaction(
          billId: docRef.id,
          customerName: bill.customerName ?? 'Walk-in Customer',
          customerPhone: bill.customerPhone,
          amount: payment.amount,
          mode: payment.mode,
          timestamp: payment.paidAt,
        );
      }
      // 🔥 Update analytics instantly
      await analyticsRepo.updateAnalyticsOnBillCreate(newBill);

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create bill: ${e.toString()}');
    }
  }

  // Helper method to create transaction
  Future<void> _createTransaction({
    required String billId,
    required String customerName,
    String? customerPhone,
    required double amount,
    required String mode,
    required Timestamp timestamp,
  }) async {
    try {
      final transactionRef = FBFireStore.transactions.doc();
      await transactionRef.set({
        'billId': billId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'amount': amount,
        'mode': mode,
        'timestamp': timestamp,
      });
    } catch (e) {
      print('Failed to create transaction: ${e.toString()}');
    }
  }

  @override
  Future<void> updateBill(BillModel bill) async {
    try {
      await billsCollectionRef.doc(bill.id).update(bill.toJson());
    } catch (e) {
      throw Exception('Failed to update bill: ${e.toString()}');
    }
  }

  @override
  Future<void> addPayment(String billId, PaymentModel payment) async {
    try {
      final billDoc = await billsCollectionRef.doc(billId).get();
      final bill = BillModel.fromJson(billDoc.data()!, billId);

      final updatedPayments = [...bill.payments, payment];
      final newAmountPaid = bill.amountPaid + payment.amount;
      final newPendingAmount = bill.finalAmount - newAmountPaid;

      String newStatus;
      if (newPendingAmount <= 0) {
        newStatus = 'Paid';
      } else if (newAmountPaid > 0) {
        newStatus = 'PartiallyPaid';
      } else {
        newStatus = 'Unpaid';
      }

      final updatedBill = bill.copyWith(
        payments: updatedPayments,
        amountPaid: newAmountPaid,
        pendingAmount: newPendingAmount,
        status: newStatus,
        updatedAt: Timestamp.now(),
      );

      await updateBill(updatedBill);

      // Create transaction for the payment
      await _createTransaction(
        billId: billId,
        customerName: bill.customerName ?? 'Walk-in Customer',
        customerPhone: bill.customerPhone,
        amount: payment.amount,
        mode: payment.mode,
        timestamp: payment.paidAt,
      );

      await analyticsRepo.updateAnalyticsOnPayment(
        payment.amount,
        newStatus == 'Paid',
        payment.paidAt,
      );
    } catch (e) {
      throw Exception('Failed to add payment: ${e.toString()}');
    }
  }

  @override
  Future<List<BillModel>> searchBills(String query) async {
    try {
      final snapshot = await billsCollectionRef
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => BillModel.fromDocSnap(doc))
          .where(
            (bill) =>
                bill.id.toLowerCase().contains(query.toLowerCase()) ||
                (bill.customerName?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ??
                    false) ||
                (bill.customerPhone?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search bills: ${e.toString()}');
    }
  }
}
