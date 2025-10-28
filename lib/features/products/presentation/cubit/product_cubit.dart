import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/product_model.dart';
import '../../domain/repositories/product_repository.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository _repository;

  ProductCubit(this._repository) : super(ProductInitial());

  Future<void> loadProducts() async {
    try {
      emit(ProductLoading());
      final products = await _repository.getAllProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> searchProducts(String query) async {
    try {
      emit(ProductLoading());
      final products = await _repository.searchProducts(query);
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> createProduct(ProductModel product) async {
    try {
      await _repository.createProduct(product);
      emit(ProductOperationSuccess('Product created successfully'));
      await loadProducts();
    } catch (e) {
      emit(ProductError(e.toString()));
      await loadProducts();
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await _repository.updateProduct(product);
      emit(ProductOperationSuccess('Product updated successfully'));
      await loadProducts();
    } catch (e) {
      emit(ProductError(e.toString()));
      await loadProducts();
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _repository.deleteProduct(id);
      emit(ProductOperationSuccess('Product deleted successfully'));
      await loadProducts();
    } catch (e) {
      emit(ProductError(e.toString()));
      await loadProducts();
    }
  }

  Future<void> loadLowStockProducts() async {
    try {
      emit(ProductLoading());
      final products = await _repository.getLowStockProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}

