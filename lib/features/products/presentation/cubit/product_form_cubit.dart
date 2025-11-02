import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/product_model.dart';
import '../../domain/repositories/product_repository.dart';

part 'product_form_state.dart';

class ProductFormCubit extends Cubit<ProductFormState> {
  final ProductRepository _repository;

  ProductFormCubit(this._repository) : super(ProductFormState.initial());

  void setEditMode(ProductModel product) {
    emit(
      state.copyWith(
        isEditMode: true,
        editingProduct: product,
        name: product.name,
        categoryId: product.categoryId,
        price: product.price.toString(),
        costPrice: product.costPrice.toString(),
        discountPercent: product.discountPercent?.toString() ?? '',
        taxPercent: product.taxPercent.toString(),
        sku: product.sku ?? '',
        imageUrl: product.imageUrl ?? '',
        stockQty: product.stockQty.toString(),
      ),
    );
  }

  void resetForm() {
    emit(ProductFormState.initial());
  }

  void updateName(String value) {
    emit(state.copyWith(name: value));
  }

  void updateCategoryId(String value) {
    emit(state.copyWith(categoryId: value));
  }

  void updatePrice(String value) {
    emit(state.copyWith(price: value));
  }

  void updateCostPrice(String value) {
    emit(state.copyWith(costPrice: value));
  }

  void updateDiscountPercent(String value) {
    emit(state.copyWith(discountPercent: value));
  }

  void updateTaxPercent(String value) {
    emit(state.copyWith(taxPercent: value));
  }

  void updateSku(String value) {
    emit(state.copyWith(sku: value));
  }

  void updateImageUrl(String value) {
    emit(state.copyWith(imageUrl: value));
  }

  void updateStockQty(String value) {
    emit(state.copyWith(stockQty: value));
  }

  Future<bool> submitForm() async {
    if (!_validateForm()) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Please fill all required fields',
        ),
      );
      return false;
    }

    try {
      emit(state.copyWith(isSubmitting: true, errorMessage: null));

      final product = ProductModel(
        id: state.isEditMode ? state.editingProduct!.id : '',
        name: state.name,
        categoryId: state.categoryId,
        price: double.parse(state.price),
        costPrice: double.parse(state.costPrice),
        discountPercent: state.discountPercent.isNotEmpty
            ? double.parse(state.discountPercent)
            : null,
        taxPercent: double.parse(state.taxPercent),
        sku: state.sku.isNotEmpty ? state.sku : null,
        imageUrl: state.imageUrl.isNotEmpty ? state.imageUrl : null,
        stockQty: int.parse(state.stockQty),
        createdAt: state.isEditMode
            ? state.editingProduct!.createdAt
            : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (state.isEditMode) {
        await _repository.updateProduct(product);
      } else {
        await _repository.createProduct(product);
      }

      emit(
        state.copyWith(
          isSubmitting: false,
          isSuccess: true,
          errorMessage: null,
        ),
      );
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
      return false;
    }
  }

  bool _validateForm() {
    return state.name.isNotEmpty &&
        state.categoryId.isNotEmpty &&
        state.price.isNotEmpty &&
        state.costPrice.isNotEmpty &&
        state.taxPercent.isNotEmpty &&
        state.stockQty.isNotEmpty &&
        _isValidNumber(state.price) &&
        _isValidNumber(state.costPrice) &&
        _isValidNumber(state.taxPercent) &&
        _isValidInteger(state.stockQty) &&
        (state.discountPercent.isEmpty ||
            _isValidNumber(state.discountPercent));
  }

  bool _isValidNumber(String value) {
    return double.tryParse(value) != null;
  }

  bool _isValidInteger(String value) {
    return int.tryParse(value) != null;
  }
}
