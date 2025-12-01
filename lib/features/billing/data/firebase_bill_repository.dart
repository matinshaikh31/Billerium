import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/features/analytics/data/firebase_analytics_repo.dart';
import 'package:billing_software/features/billing/domain/entity/bill_item_model.dart';
import 'package:billing_software/features/billing/domain/repo/fbill_repository.dart';
import 'package:billing_software/features/billing/domain/entity/bill_model.dart';
import 'package:billing_software/features/billing/domain/entity/payment_model.dart';
import 'package:billing_software/features/transactions/domain/models/transaction_model.dart';
import 'package:billing_software/features/purchase/domain/entity/stock_ledger_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseBillRepository extends BillRepository {
  final billsCollectionRef = FBFireStore.bills;
  final analyticsRepo = FirebaseAnalyticsRepository();

  Future<void> _updateProductStockAfterSale(
    List<BillItemModel> items,
    String billId,
  ) async {
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

        // Create stock ledger entry
        await _createStockLedgerEntry(
          productId: item.productId,
          qtyChange: -item.quantity,
          finalStock: newStock.toInt(),
          referenceId: billId,
          type: 'sale',
        );

        // Update profit tracking
        await _updateProfitTracking(
          productId: item.productId,
          salesRevenue: item.itemTotal,
          quantity: item.quantity,
          productData: productSnap.data()!,
        );
      }
    }

    await batch.commit();
  }

  Future<void> _createStockLedgerEntry({
    required String productId,
    required int qtyChange,
    required int finalStock,
    required String referenceId,
    required String type,
  }) async {
    final ledgerEntry = StockLedgerModel(
      id: '',
      productId: productId,
      type: type,
      qtyChange: qtyChange,
      finalStock: finalStock,
      referenceId: referenceId,
      timestamp: Timestamp.now(),
    );

    await FBFireStore.stockLedger.add(ledgerEntry.toJson());
  }

  Future<void> _updateProfitTracking({
    required String productId,
    required double salesRevenue,
    required int quantity,
    required Map<String, dynamic> productData,
  }) async {
    final profitDoc = FBFireStore.profitTracking.doc(productId);
    final profitSnapshot = await profitDoc.get();

    // Get average purchase price from product
    final avgPurchasePrice =
        (productData['averagePurchasePrice'] as num?)?.toDouble() ?? 0;
    final purchaseCost = avgPurchasePrice * quantity;

    if (profitSnapshot.exists) {
      final currentData = profitSnapshot.data()!;
      final currentSalesRevenue = (currentData['totalSalesRevenue'] ?? 0)
          .toDouble();
      final currentUnitsSold = (currentData['unitsSold'] ?? 0) as int;
      final currentPurchaseCost = (currentData['totalPurchaseCost'] ?? 0)
          .toDouble();

      final newSalesRevenue = currentSalesRevenue + salesRevenue;
      final newUnitsSold = currentUnitsSold + quantity;
      final newProfit = newSalesRevenue - currentPurchaseCost;

      await profitDoc.update({
        'totalSalesRevenue': newSalesRevenue,
        'unitsSold': newUnitsSold,
        'totalProfit': newProfit,
      });
    } else {
      await profitDoc.set({
        'totalPurchaseCost': 0,
        'totalSalesRevenue': salesRevenue,
        'totalProfit': salesRevenue,
        'unitsSold': quantity,
      });
    }
  }

  @override
  Future<String> createBill(BillModel bill) async {
    try {
      final docRef = billsCollectionRef.doc();
      final now = Timestamp.now();

      final newBill = BillModel(
        id: docRef.id,
        billNo: bill.billNo,
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

      // Update stock and create ledger entries
      await _updateProductStockAfterSale(newBill.items, docRef.id);

      // Create transaction for each payment
      // for (final payment in bill.payments) {
      //   await _createTransaction(
      //     billId: docRef.id,
      //     customerName: bill.customerName ?? 'Walk-in Customer',
      //     customerPhone: bill.customerPhone,
      //     amount: payment.amount,
      //     mode: payment.mode,
      //     timestamp: payment.paidAt,
      //   );
      // }
      // 🔥 Update analytics instantly
      await analyticsRepo.updateAnalyticsOnBillCreate(newBill);

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create bill: ${e.toString()}');
    }
  }

  // Update _createTransaction to use TransactionModel
  Future<void> _createTransaction({
    required String billId,
    required String billNo, // ✅ ADDED
    required String customerName,
    String? customerPhone,
    required double amount,
    required String mode,
    required Timestamp timestamp,
  }) async {
    try {
      // ✅ USE TransactionModel
      final transaction = TransactionModel(
        id: '',
        billId: billId,
        billNo: billNo,
        customerName: customerName,
        customerPhone: customerPhone,
        amount: amount,
        mode: mode,
        timestamp: timestamp,
      );

      // ✅ USE toJson()
      await FBFireStore.transactions.add(transaction.toJson());
    } catch (e) {
      print('Failed to create transaction: ${e.toString()}');
    }
  }

  // Update addPayment to pass billNo
  @override
  Future<void> addPayment(String billId, PaymentModel payment) async {
    try {
      final billDoc = await billsCollectionRef.doc(billId).get();
      final bill = BillModel.fromJson(billDoc.data()!, billId);

      final oldPendingAmount = bill.pendingAmount;

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

      await _createTransaction(
        billId: billId,
        billNo: bill.billNo,
        customerName: bill.customerName ?? 'Walk-in Customer',
        customerPhone: bill.customerPhone,
        amount: payment.amount,
        mode: payment.mode,
        timestamp: payment.paidAt,
      );

      // ✅ Calculate actual change in pending amount
      final pendingChange = oldPendingAmount - newPendingAmount;

      await analyticsRepo.updateAnalyticsOnPayment(
        paymentAmount: payment.amount,
        pendingChange: pendingChange,
        timestamp: payment.paidAt,
      );
    } catch (e) {
      throw Exception('Failed to add payment: ${e.toString()}');
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
  Future<BillModel?> getBillById(String billId) async {
    try {
      final doc = await billsCollectionRef.doc(billId).get();
      if (doc.exists && doc.data() != null) {
        return BillModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get bill: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteBill(String billId) async {
    try {
      // Get the bill first to restore stock and reverse analytics
      final bill = await getBillById(billId);
      if (bill == null) {
        throw Exception('Bill not found');
      }

      // Restore stock for all items
      await _restoreProductStockAfterDelete(bill.items, billId);

      // Reverse analytics
      await analyticsRepo.reverseAnalyticsOnBillDelete(bill);

      // Delete associated transactions
      await _deleteTransactionsForBill(billId);

      // Delete the bill
      await billsCollectionRef.doc(billId).delete();
    } catch (e) {
      throw Exception('Failed to delete bill: ${e.toString()}');
    }
  }

  Future<void> _restoreProductStockAfterDelete(
    List<BillItemModel> items,
    String billId,
  ) async {
    final batch = FirebaseFirestore.instance.batch();

    for (final item in items) {
      final productRef = FBFireStore.products.doc(item.productId);
      final productSnap = await productRef.get();

      if (productSnap.exists) {
        final currentStock = productSnap.data()!['stockQty'] ?? 0;
        final newStock = currentStock + item.quantity;

        batch.update(productRef, {'stockQty': newStock});

        // Create stock ledger entry for restoration
        await _createStockLedgerEntry(
          productId: item.productId,
          qtyChange: item.quantity,
          finalStock: newStock.toInt(),
          referenceId: billId,
          type: 'sale_reversal',
        );

        // Reverse profit tracking
        await _reverseProfitTracking(
          productId: item.productId,
          salesRevenue: item.itemTotal,
          quantity: item.quantity,
        );
      }
    }

    await batch.commit();
  }

  Future<void> _reverseProfitTracking({
    required String productId,
    required double salesRevenue,
    required int quantity,
  }) async {
    final profitDoc = FBFireStore.profitTracking.doc(productId);
    final profitSnapshot = await profitDoc.get();

    if (profitSnapshot.exists) {
      final currentData = profitSnapshot.data()!;
      final currentSalesRevenue = (currentData['totalSalesRevenue'] ?? 0)
          .toDouble();
      final currentUnitsSold = (currentData['unitsSold'] ?? 0) as int;
      final currentPurchaseCost = (currentData['totalPurchaseCost'] ?? 0)
          .toDouble();

      final newSalesRevenue = (currentSalesRevenue - salesRevenue).clamp(
        0,
        double.infinity,
      );
      final newUnitsSold = (currentUnitsSold - quantity).clamp(
        0,
        double.maxFinite.toInt(),
      );
      final newProfit = newSalesRevenue - currentPurchaseCost;

      await profitDoc.update({
        'totalSalesRevenue': newSalesRevenue,
        'unitsSold': newUnitsSold,
        'totalProfit': newProfit,
      });
    }
  }

  Future<void> _deleteTransactionsForBill(String billId) async {
    try {
      final transactionsSnapshot = await FBFireStore.transactions
          .where('billId', isEqualTo: billId)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in transactionsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Failed to delete transactions: ${e.toString()}');
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
