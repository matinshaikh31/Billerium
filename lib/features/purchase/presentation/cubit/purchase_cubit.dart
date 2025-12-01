import 'package:billing_software/features/purchase/domain/entity/purchase_model.dart';
import 'package:billing_software/features/purchase/domain/repo/purchase_repo.dart';
import 'package:billing_software/features/purchase/presentation/cubit/purchase_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PurchaseCubit extends Cubit<PurchaseState> {
  final PurchaseRepo purchaseRepo;

  PurchaseCubit({required this.purchaseRepo}) : super(const PurchaseState());

  Future<void> fetchPurchases() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      final purchases = await purchaseRepo.getAllPurchases();
      emit(state.copyWith(purchases: purchases, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to fetch purchases: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> createPurchase(PurchaseModel purchase) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      await purchaseRepo.createPurchase(purchase);
      emit(
        state.copyWith(
          isLoading: false,
          successMessage: 'Purchase created successfully',
        ),
      );
      await fetchPurchases();
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to create purchase: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> fetchPurchasesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      final purchases = await purchaseRepo.getPurchasesByDateRange(
        startDate,
        endDate,
      );
      emit(state.copyWith(purchases: purchases, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to fetch purchases: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> deletePurchase(String id) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      await purchaseRepo.deletePurchase(id);
      emit(
        state.copyWith(
          isLoading: false,
          successMessage: 'Purchase deleted successfully',
        ),
      );
      await fetchPurchases();
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to delete purchase: ${e.toString()}',
        ),
      );
    }
  }

  void clearMessages() {
    emit(state.copyWith(error: null, successMessage: null));
  }
}
