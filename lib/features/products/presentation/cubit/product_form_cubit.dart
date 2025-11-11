import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/features/products/data/firebase_product_repository.dart';
import 'package:billing_software/features/products/domain/entity/product_model.dart';
import 'package:billing_software/features/products/presentation/cubit/product_cubit.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'product_form_state.dart';

class ProductFormCubit extends Cubit<ProductFormState> {
  FirebaseProductRepository productRepository;

  ProductFormCubit({required this.productRepository})
    : super(ProductFormState.initial());

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final discountController = TextEditingController();
  final skuController = TextEditingController();
  final stockController = TextEditingController();
  String? selectedCategoryId;

  void initializeForm(ProductModel? product) {
    if (product != null) {
      nameController.text = product.name;
      priceController.text = product.price.toString();
      discountController.text = product.discountPercent?.toString() ?? '';
      skuController.text = product.sku ?? '';
      stockController.text = product.stockQty.toString();
      selectedCategoryId = product.categoryId;
    } else {
      clearForm();
    }
  }

  void clearForm() {
    nameController.clear();
    priceController.clear();
    discountController.clear();
    skuController.clear();
    stockController.clear();
    selectedCategoryId = null;
  }

  void setSelectedCategory(String? categoryId) {
    selectedCategoryId = categoryId;
    emit(state.copyWith());
  }

  Future<void> submitForm(
    ProductModel? editProduct,
    BuildContext context,
  ) async {
    if (state.isLoading) return;

    if (!(formKey.currentState?.validate() ?? false)) {
      emit(
        state.copyWith(message: 'Please fill all required fields correctly'),
      );
      return;
    }

    if (selectedCategoryId == null) {
      emit(state.copyWith(message: 'Please select a category'));
      return;
    }

    emit(state.copyWith(isLoading: true, message: ''));

    try {
      final product = ProductModel(
        id: editProduct?.id ?? '',
        name: nameController.text.trim().toLowerCase(),
        categoryId: selectedCategoryId!,
        price: double.parse(priceController.text.trim()),
        discountPercent: discountController.text.trim().isNotEmpty
            ? double.parse(discountController.text.trim())
            : null,
        sku: skuController.text.trim().isNotEmpty
            ? skuController.text.trim().toLowerCase()
            : null,
        stockQty: int.parse(stockController.text.trim()),
        createdAt: editProduct?.createdAt ?? Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      final productCubit = context.read<ProductCubit>();

      if (editProduct != null) {
        // UPDATE PRODUCT
        await productRepository.updateProduct(product);

        final updatedProduct = await FBFireStore.products
            .doc(editProduct.id)
            .get();

        final updatedProductModel = ProductModel.fromJson(
          updatedProduct.data()!,
          updatedProduct.id,
        );

        // If on page 1, refresh to get latest data
        if (productCubit.state.currentPage == 1) {
          await productCubit.initializeProductsPagination();
        } else {
          // If on other pages, update the product in current list
          productCubit.updateProductInList(updatedProductModel);
        }

        emit(
          state.copyWith(
            isLoading: false,
            message: 'Product updated successfully',
          ),
        );
      } else {
        // CREATE NEW PRODUCT
        final id = await productRepository.createProduct(product);

        // Only refresh if on page 1 (new products appear on page 1)
        if (productCubit.state.currentPage == 1) {
          await productCubit.initializeProductsPagination();
        }
        // If on other pages, do nothing - they'll see it when they navigate to page 1

        emit(
          state.copyWith(
            isLoading: false,
            message: 'Product created successfully',
          ),
        );
      }

      await Future.delayed(const Duration(milliseconds: 100));

      if (context.mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, message: 'Error: ${e.toString()}'));
    }
  }

  void clearMessage() {
    emit(state.copyWith(message: null));
  }

  @override
  Future<void> close() {
    nameController.dispose();
    priceController.dispose();
    discountController.dispose();
    skuController.dispose();
    stockController.dispose();
    return super.close();
  }
}
