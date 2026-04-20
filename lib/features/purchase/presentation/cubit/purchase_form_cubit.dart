import 'package:billing_software/features/purchase/domain/entity/purchase_item_model.dart';
import 'package:billing_software/features/purchase/domain/entity/purchase_model.dart';
import 'package:billing_software/features/purchase/domain/repo/purchase_repo.dart';
import 'package:billing_software/features/purchase/presentation/cubit/purchase_form_state.dart';
import 'package:billing_software/features/products/domain/repositories/product_repository.dart';
import 'package:billing_software/features/settings/domain/entity/setting_model.dart';
import 'package:billing_software/core/services/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PurchaseFormCubit extends Cubit<PurchaseFormState> {
  final PurchaseRepo purchaseRepo;
  final ProductRepository productRepository;

  // Tax rates from settings (default 0 - will be set from Firebase settings)
  int cgstRate = 0;
  int sgstRate = 0;

  PurchaseFormCubit({
    required this.purchaseRepo,
    required this.productRepository,
  }) : super(const PurchaseFormState());

  // Set tax rates from settings
  void setTaxRates(SettingModel settings) {
    cgstRate = settings.CGST;
    sgstRate = settings.SGST;
    // Recalculate with new tax rates
    _recalculateTotals(state.items, otherExpense: state.otherExpense);
  }

  void setSupplierName(String name) {
    emit(state.copyWith(supplierName: name));
  }

  void setSupplierPhone(String phone) {
    emit(state.copyWith(supplierPhone: phone));
  }

  void setSupplierGstNumber(String gstNumber) {
    emit(state.copyWith(supplierGstNumber: gstNumber));
  }

  void setOtherExpense(double expense) {
    final updatedItems = state.items;
    _recalculateTotals(updatedItems, otherExpense: expense);
  }

  void addItem(PurchaseItemModel item) {
    final updatedItems = List<PurchaseItemModel>.from(state.items)..add(item);
    _recalculateTotals(updatedItems);
  }

  void updateItem(int index, PurchaseItemModel item) {
    final updatedItems = List<PurchaseItemModel>.from(state.items);
    updatedItems[index] = item;
    _recalculateTotals(updatedItems);
  }

  void removeItem(int index) {
    final updatedItems = List<PurchaseItemModel>.from(state.items)
      ..removeAt(index);
    _recalculateTotals(updatedItems);
  }

  void _recalculateTotals(
    List<PurchaseItemModel> items, {
    double? otherExpense,
  }) {
    final totalBeforeTax = items.fold<double>(
      0,
      (total, item) => total + item.total,
    );

    // Calculate CGST and SGST based on rates from settings
    final cgstAmount = totalBeforeTax * (cgstRate / 100);
    final sgstAmount = totalBeforeTax * (sgstRate / 100);
    final totalTax = cgstAmount + sgstAmount;

    final expense = otherExpense ?? state.otherExpense;
    final finalAmount = totalBeforeTax + totalTax + expense;

    emit(
      state.copyWith(
        items: items,
        totalBeforeTax: totalBeforeTax,
        cgst: cgstAmount,
        sgst: sgstAmount,
        totalTax: totalTax,
        otherExpense: expense,
        finalAmount: finalAmount,
      ),
    );
  }

  Future<void> submitPurchase() async {
    if (state.items.isEmpty) {
      emit(state.copyWith(error: 'Please add at least one item'));
      return;
    }

    try {
      emit(state.copyWith(isLoading: true, error: null));

      final purchaseNo = 'PUR-${DateTime.now().millisecondsSinceEpoch}';
      final now = Timestamp.now();

      final purchase = PurchaseModel(
        id: '',
        purchaseNo: purchaseNo,
        supplierName: state.supplierName,
        supplierPhone: state.supplierPhone,
        supplierGstNumber: state.supplierGstNumber,
        items: state.items,
        totalBeforeTax: state.totalBeforeTax,
        cgst: state.cgst,
        sgst: state.sgst,
        totalTax: state.totalTax,
        otherExpense: state.otherExpense,
        finalAmount: state.finalAmount,
        createdAt: now,
        updatedAt: now,
      );

      // Create purchase
      await purchaseRepo.createPurchase(purchase);

      // Update stock for all purchased items
      await _updateProductStock(state.items);

      emit(const PurchaseFormState()); // Reset form
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to create purchase: ${e.toString()}',
        ),
      );
    }
  }

  /// Update stock quantity for all purchased products
  Future<void> _updateProductStock(List<PurchaseItemModel> items) async {
    try {
      for (final item in items) {
        // Get current product data
        final productDoc = await FBFireStore.products.doc(item.productId).get();

        if (productDoc.exists) {
          final currentQty = (productDoc.data()?['qty'] ?? 0) as int;
          final newQty = currentQty + item.quantity;

          // Update product quantity
          await FBFireStore.products.doc(item.productId).update({
            'qty': newQty,
            'updatedAt': Timestamp.now(),
          });
        }
      }
    } catch (e) {
      // Log error but don't throw - purchase is already created
      print('Error updating product stock: ${e.toString()}');
    }
  }

  void reset() {
    emit(const PurchaseFormState());
  }
}
