import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/features/billing/data/firebase_bill_repository.dart';
import 'package:billing_software/features/billing/domain/entity/bill_model.dart';
import 'package:billing_software/features/billing/domain/entity/payment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseBillRepository extends BillRepository {
  final billsCollectionRef = FBFireStore.bills;

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

      // Create transaction for each payment
      for (final payment in bill.payments) {
        await _createTransaction(
          billId: docRef.id,
          customerName: bill.customerName ?? 'Guest',
          amount: payment.amount,
          mode: payment.mode,
        );
      }

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create bill: ${e.toString()}');
    }
  }

  // Helper method to create transaction
  Future<void> _createTransaction({
    required String billId,
    required String customerName,
    required double amount,
    required String mode,
  }) async {
    try {
      final transactionRef = FBFireStore.transactions.doc();
      await transactionRef.set({
        'id': transactionRef.id,
        'billId': billId,
        'customerName': customerName,
        'amount': amount,
        'mode': mode,
        'timestamp': Timestamp.now(),
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
        customerName: bill.customerName ?? 'Guest',
        amount: payment.amount,
        mode: payment.mode,
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
                    false),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search bills: ${e.toString()}');
    }
  }
}
