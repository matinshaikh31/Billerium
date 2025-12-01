import 'package:billing_software/features/purchase/domain/entity/purchase_model.dart';

abstract class PurchaseRepo {
  Future<void> createPurchase(PurchaseModel purchase);
  Future<List<PurchaseModel>> getAllPurchases();
  Future<List<PurchaseModel>> getPurchasesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<PurchaseModel?> getPurchaseById(String id);
  Future<void> deletePurchase(String id);
  Stream<List<PurchaseModel>> watchPurchases();
}

