import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/product_model.dart';
import '../../domain/repositories/product_repository.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository _repository;
  final TextEditingController searchController = TextEditingController();

  ProductCubit(this._repository) : super(ProductState.initial()) {
    searchController.addListener(_onSearchChanged);
  }

  // Expose repository for ProductFormCubit
  ProductRepository get repository => _repository;

  void _onSearchChanged() {
    updateSearchQuery(searchController.text);
  }

  Future<void> loadProducts() async {
    try {
      emit(state.copyWith(isLoading: true));
      final products = await _repository.getAllProducts();
      emit(
        state.copyWith(
          isLoading: false,
          products: products,
          filteredProducts: _applyFilters(products),
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, message: e.toString()));
    }
  }

  void updateSearchQuery(String query) {
    emit(
      state.copyWith(
        searchQuery: query,
        filteredProducts: _applyFilters(state.products),
      ),
    );
  }

  void updateSelectedCategory(String category) {
    emit(
      state.copyWith(
        selectedCategory: category,
        filteredProducts: _applyFilters(state.products),
      ),
    );
  }

  List<ProductModel> _applyFilters(List<ProductModel> products) {
    return products.where((product) {
      final matchesSearch =
          state.searchQuery.isEmpty ||
          product.name.toLowerCase().contains(
            state.searchQuery.toLowerCase(),
          ) ||
          (product.sku?.toLowerCase().contains(
                state.searchQuery.toLowerCase(),
              ) ??
              false);

      final matchesCategory =
          state.selectedCategory == 'All Categories' ||
          product.categoryId == state.selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<String> getCategories() {
    if (state.products.isEmpty) return ['All Categories'];
    return ['All Categories'] +
        state.products.map((p) => p.categoryId).toSet().toList();
  }

  Future<void> searchProducts(String query) async {
    try {
      emit(state.copyWith(isLoading: true));
      final products = await _repository.searchProducts(query);
      emit(
        state.copyWith(
          isLoading: false,
          products: products,
          filteredProducts: _applyFilters(products),
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, message: e.toString()));
    }
  }

  Future<void> createProduct(ProductModel product) async {
    try {
      await _repository.createProduct(product);
      final products = await _repository.getAllProducts();
      emit(
        state.copyWith(
          isLoading: false,
          message: 'Product created successfully',
          products: products,
          filteredProducts: _applyFilters(products),
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, message: e.toString()));
      await loadProducts();
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await _repository.updateProduct(product);
      final products = await _repository.getAllProducts();
      emit(
        state.copyWith(
          isLoading: false,
          message: 'Product updated successfully',
          products: products,
          filteredProducts: _applyFilters(products),
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, message: e.toString()));
      await loadProducts();
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _repository.deleteProduct(id);
      final products = await _repository.getAllProducts();
      emit(
        state.copyWith(
          isLoading: false,
          message: 'Product deleted successfully',
          products: products,
          filteredProducts: _applyFilters(products),
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, message: e.toString()));
      await loadProducts();
    }
  }

  Future<void> loadLowStockProducts() async {
    try {
      emit(state.copyWith(isLoading: true));
      final products = await _repository.getLowStockProducts();
      emit(
        state.copyWith(
          isLoading: false,
          products: products,
          filteredProducts: _applyFilters(products),
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    searchController.dispose();
    return super.close();
  }
}
