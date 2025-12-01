import 'package:billing_software/features/purchase/domain/entity/purchase_item_model.dart';
import 'package:billing_software/features/purchase/domain/entity/purchase_model.dart';
import 'package:billing_software/features/purchase/domain/repo/purchase_repo.dart';
import 'package:billing_software/features/purchase/presentation/cubit/purchase_form_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PurchaseFormCubit extends Cubit<PurchaseFormState> {
  final PurchaseRepo purchaseRepo;

  PurchaseFormCubit({required this.purchaseRepo})
      : super(const PurchaseFormState());

  void setSupplierName(String name) {
    emit(state.copyWith(supplierName: name));
  }

  void setSupplierPhone(String phone) {
    emit(state.copyWith(supplierPhone: phone));
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

  void _recalculateTotals(List<PurchaseItemModel> items) {
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.total);
    final totalTax = subtotal * 0.0; // Adjust tax rate as needed
    final finalAmount = subtotal + totalTax;

    emit(state.copyWith(
      items: items,
      subtotal: subtotal,
      totalTax: totalTax,
      finalAmount: finalAmount,
    ));
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
        items: state.items,
        subtotal: state.subtotal,
        totalTax: state.totalTax,
        finalAmount: state.finalAmount,
        createdAt: now,
        updatedAt: now,
      );

      await purchaseRepo.createPurchase(purchase);

      emit(const PurchaseFormState()); // Reset form
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to create purchase: ${e.toString()}',
      ));
    }
  }

  void reset() {
    emit(const PurchaseFormState());
  }
}

