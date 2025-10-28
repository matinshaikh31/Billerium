import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/product_model.dart';
import '../../domain/repositories/product_repository.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository _repository;

  ProductCubit(this._repository) : super(ProductState.initial());

  Future<void> loadProducts() async {
    try {
      emit(ProductState.loading());
      final products = await _repository.getAllProducts();
      emit(ProductState.loaded(products));
    } catch (e) {
      emit(ProductState.error(e.toString()));
    }
  }

  Future<void> searchProducts(String query) async {
    try {
      emit(ProductState.loading());
      final products = await _repository.searchProducts(query);
      emit(ProductState.loaded(products));
    } catch (e) {
      emit(ProductState.error(e.toString()));
    }
  }

  Future<void> createProduct(ProductModel product) async {
    try {
      await _repository.createProduct(product);
      final products = await _repository.getAllProducts();
      emit(ProductState.success('Product created successfully', products));
    } catch (e) {
      emit(ProductState.error(e.toString()));
      await loadProducts();
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await _repository.updateProduct(product);
      final products = await _repository.getAllProducts();
      emit(ProductState.success('Product updated successfully', products));
    } catch (e) {
      emit(ProductState.error(e.toString()));
      await loadProducts();
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _repository.deleteProduct(id);
      final products = await _repository.getAllProducts();
      emit(ProductState.success('Product deleted successfully', products));
    } catch (e) {
      emit(ProductState.error(e.toString()));
      await loadProducts();
    }
  }

  Future<void> loadLowStockProducts() async {
    try {
      emit(ProductState.loading());
      final products = await _repository.getLowStockProducts();
      emit(ProductState.loaded(products));
    } catch (e) {
      emit(ProductState.error(e.toString()));
    }
  }
}
