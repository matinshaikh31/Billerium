import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/features/purchase/domain/entity/purchase_model.dart';
import 'package:billing_software/features/purchase/domain/entity/stock_ledger_model.dart';
import 'package:billing_software/features/purchase/domain/entity/profit_model.dart';
import 'package:billing_software/features/purchase/domain/repo/purchase_repo.dart';
import 'package:billing_software/features/analytics/domain/entity/monthly_purchase_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebasePurchaseRepository implements PurchaseRepo {
  @override
  Future<void> createPurchase(PurchaseModel purchase) async {
    try {
      final docRef = await FBFireStore.purchases.add(purchase.toJson());

      // Update stock and tracking for each item
      for (var item in purchase.items) {
        await _updateProductStock(
          productId: item.productId,
          quantity: item.quantity,
          purchasePrice: item.purchasePrice,
        );

        await _createStockLedgerEntry(
          productId: item.productId,
          qtyChange: item.quantity,
          referenceId: docRef.id,
          type: 'purchase',
        );

        await _updateProfitTracking(
          productId: item.productId,
          purchaseCost: item.total,
          quantity: item.quantity,
        );
      }

      // Update monthly purchase analytics
      await _updateMonthlyPurchase(
        amount: purchase.finalAmount,
        itemCount: purchase.items.fold(0, (sum, item) => sum + item.quantity),
        timestamp: purchase.createdAt,
      );
    } catch (e) {
      throw Exception('Failed to create purchase: ${e.toString()}');
    }
  }

  Future<void> _updateProductStock({
    required String productId,
    required int quantity,
    required double purchasePrice,
  }) async {
    final productDoc = FBFireStore.products.doc(productId);
    final productSnapshot = await productDoc.get();

    if (!productSnapshot.exists) {
      throw Exception('Product not found');
    }

    final currentData = productSnapshot.data()!;
    final currentStock = currentData['stockQty'] as int;
    final newStock = currentStock + quantity;

    // Calculate average purchase price
    final lastPurchasePrice = purchasePrice;
    final currentAvgPrice = currentData['averagePurchasePrice'] as double?;
    final newAvgPrice = currentAvgPrice == null
        ? purchasePrice
        : ((currentAvgPrice * currentStock) + (purchasePrice * quantity)) /
              newStock;

    await productDoc.update({
      'stockQty': newStock,
      'lastPurchasePrice': lastPurchasePrice,
      'averagePurchasePrice': newAvgPrice,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> _createStockLedgerEntry({
    required String productId,
    required int qtyChange,
    required String referenceId,
    required String type,
  }) async {
    final productDoc = await FBFireStore.products.doc(productId).get();
    final finalStock = productDoc.data()?['stockQty'] as int? ?? 0;

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
    required double purchaseCost,
    required int quantity,
  }) async {
    final profitDoc = FBFireStore.profitTracking.doc(productId);
    final profitSnapshot = await profitDoc.get();

    if (profitSnapshot.exists) {
      final currentData = profitSnapshot.data()!;
      final currentPurchaseCost = (currentData['totalPurchaseCost'] ?? 0)
          .toDouble();

      await profitDoc.update({
        'totalPurchaseCost': currentPurchaseCost + purchaseCost,
      });
    } else {
      final profit = ProfitModel(
        productId: productId,
        totalPurchaseCost: purchaseCost,
        totalSalesRevenue: 0,
        totalProfit: -purchaseCost,
        unitsSold: 0,
      );
      await profitDoc.set(profit.toJson());
    }
  }

  Future<void> _updateMonthlyPurchase({
    required double amount,
    required int itemCount,
    required Timestamp timestamp,
  }) async {
    final date = timestamp.toDate();
    final monthId = '${date.year}-${date.month.toString().padLeft(2, '0')}';
    final monthDoc = FBFireStore.monthlyPurchases.doc(monthId);
    final monthSnapshot = await monthDoc.get();

    if (monthSnapshot.exists) {
      final currentData = monthSnapshot.data()!;
      await monthDoc.update({
        'totalPurchaseAmount':
            (currentData['totalPurchaseAmount'] ?? 0) + amount,
        'totalItemsPurchased':
            (currentData['totalItemsPurchased'] ?? 0) + itemCount,
        'updatedAt': Timestamp.now(),
      });
    } else {
      final monthlyPurchase = MonthlyPurchaseModel(
        id: monthId,
        totalPurchaseAmount: amount,
        totalItemsPurchased: itemCount,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );
      await monthDoc.set(monthlyPurchase.toJson());
    }
  }

  @override
  Future<List<PurchaseModel>> getAllPurchases() async {
    try {
      final snapshot = await FBFireStore.purchases
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PurchaseModel.fromDocSnap(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get purchases: ${e.toString()}');
    }
  }

  @override
  Future<List<PurchaseModel>> getPurchasesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await FBFireStore.purchases
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PurchaseModel.fromDocSnap(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get purchases by date range: ${e.toString()}');
    }
  }

  @override
  Future<PurchaseModel?> getPurchaseById(String id) async {
    try {
      final doc = await FBFireStore.purchases.doc(id).get();
      if (!doc.exists) return null;
      return PurchaseModel.fromJson(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to get purchase: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePurchase(String id) async {
    try {
      await FBFireStore.purchases.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete purchase: ${e.toString()}');
    }
  }

  @override
  Stream<List<PurchaseModel>> watchPurchases() {
    return FBFireStore.purchases
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PurchaseModel.fromDocSnap(doc))
              .toList(),
        );
  }
}
