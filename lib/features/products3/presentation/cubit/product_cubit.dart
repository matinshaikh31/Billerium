import 'dart:async';
import 'package:billing_software/features/products3/domain/entity/product_model.dart';
import 'package:billing_software/features/products3/domain/repositories/product_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:billing_software/core/services/firebase.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository productRepository;
  static const int _pageSize = 4;

  ProductCubit({required this.productRepository})
    : super(ProductState.initial());
  final searchController = TextEditingController();
  Timer? debounce;

  // Fetch products page
  Future<void> fetchProductsPage() async {
    try {
      int pageZeroIndex = state.currentPage - 1;

      // Check if we already have this page
      if (pageZeroIndex < state.products.length &&
          state.products[pageZeroIndex].isNotEmpty) {
        return;
      }

      Query query = FBFireStore.products
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);

      // Apply category filter if selected
      if (state.selectedCategoryFilter != null) {
        query = FBFireStore.products
            .where('categoryId', isEqualTo: state.selectedCategoryFilter)
            .orderBy('createdAt', descending: true)
            .limit(_pageSize);
      }

      if (state.lastFetchedDoc != null) {
        query = query.startAfterDocument(state.lastFetchedDoc!);
      }

      final snap = await query.get();

      if (snap.docs.isNotEmpty) {
        final products = snap.docs
            .map(
              (doc) => ProductModel.fromDocSnap(
                doc as QueryDocumentSnapshot<Map<String, dynamic>>,
              ),
            )
            .toList();

        final newLastFetchedDoc = snap.docs.last;
        final updatedProducts = List<List<ProductModel>>.from(state.products);

        while (updatedProducts.length <= pageZeroIndex) {
          updatedProducts.add([]);
        }
        updatedProducts[pageZeroIndex] = products;

        int newTotalPages = state.totalPages;
        if (snap.docs.length == _pageSize) {
          newTotalPages = state.currentPage + 1;
        } else {
          newTotalPages = state.currentPage;
        }

        emit(
          state.copyWith(
            products: updatedProducts,
            lastFetchedDoc: newLastFetchedDoc,
            totalPages: newTotalPages,
          ),
        );
      } else {
        emit(state.copyWith(totalPages: state.currentPage - 1));
      }
    } catch (e) {
      print('Error fetching products page: $e');
    }
  }

  // Initialize products pagination
  Future<void> initializeProductsPagination() async {
    searchController.clear();

    if (state.products.isNotEmpty) {
      final currentPageIndex = state.currentPage - 1;
      if (currentPageIndex < state.products.length) {
        emit(
          state.copyWith(
            filteredProducts: state.products[currentPageIndex],
            isLoading: false,
            searchQuery: '',
          ),
        );
      }
      return;
    }

    emit(
      state.copyWith(
        isLoading: true,
        products: [],
        filteredProducts: [],
        lastFetchedDoc: null,
        currentPage: 1,
        totalPages: 1,
        message: null,
      ),
    );

    try {
      await fetchProductsPage();
      emit(
        state.copyWith(
          isLoading: false,
          filteredProducts: state.products.isNotEmpty ? state.products[0] : [],
          searchQuery: '',
        ),
      );
    } catch (e) {
      print('Error initializing products: $e');
      emit(state.copyWith(isLoading: false, message: e.toString()));
    }
  }

  // Fetch next products page
  Future<void> fetchNextProductsPage({required int page}) async {
    final isNextPage = page > state.currentPage;
    emit(state.copyWith(isLoading: true, currentPage: page));

    if (isNextPage) {
      Query query = FBFireStore.products
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);

      if (state.selectedCategoryFilter != null) {
        query = FBFireStore.products
            .where('categoryId', isEqualTo: state.selectedCategoryFilter)
            .orderBy('createdAt', descending: true)
            .limit(_pageSize);
      }

      if (state.lastFetchedDoc != null) {
        query = query.startAfterDocument(state.lastFetchedDoc!);
      }

      final snap = await query.get();

      if (snap.docs.isNotEmpty) {
        final products = snap.docs
            .map(
              (doc) => ProductModel.fromDocSnap(
                doc as QueryDocumentSnapshot<Map<String, dynamic>>,
              ),
            )
            .toList();

        final newLastFetchedDoc = snap.docs.last;
        final newFirstFetchedDoc = snap.docs.first;

        int newTotalPages = state.totalPages;
        if (snap.docs.length == _pageSize) {
          newTotalPages = state.currentPage + 1;
        } else {
          newTotalPages = state.currentPage;
        }

        emit(
          state.copyWith(
            filteredProducts: products,
            lastFetchedDoc: newLastFetchedDoc,
            firstFetchedDoc: newFirstFetchedDoc,
            totalPages: newTotalPages,
          ),
        );
      } else {
        emit(state.copyWith(totalPages: state.currentPage - 1));
      }
    } else {
      // Previous page logic
      Query query = FBFireStore.products
          .orderBy('createdAt', descending: false)
          .limit(_pageSize);

      if (state.selectedCategoryFilter != null) {
        query = FBFireStore.products
            .where('categoryId', isEqualTo: state.selectedCategoryFilter)
            .orderBy('createdAt', descending: false)
            .limit(_pageSize);
      }

      if (state.firstFetchedDoc != null) {
        query = query.startAfterDocument(state.firstFetchedDoc!);
      }

      final snap = await query.get();

      if (snap.docs.isNotEmpty) {
        final products = snap.docs
            .map(
              (doc) => ProductModel.fromDocSnap(
                doc as QueryDocumentSnapshot<Map<String, dynamic>>,
              ),
            )
            .toList();

        // snap.docs.sort(
        //   (a, b) => ((b.data())!['createdAt'] as Timestamp).compareTo(
        //     (a.data())['createdAt'] as Timestamp,
        //   ),
        // );

        final newFirstFetchedDoc = snap.docs.last;
        final newLastFetchedDoc = snap.docs.first;

        products.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        emit(
          state.copyWith(
            filteredProducts: products,
            firstFetchedDoc: newFirstFetchedDoc,
            lastFetchedDoc: newLastFetchedDoc,
          ),
        );
      }
    }
  }

  // Search products
  void searchProducts(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    emit(state.copyWith(searchQuery: query));

    if (query.trim().isEmpty) {
      _resetSearchToCurrentPage();
      return;
    }

    debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        emit(state.copyWith(isLoading: true));

        final searchResults = await productRepository.searchProducts(
          query.trim().toLowerCase(),
        );

        // Apply category filter if selected
        final filteredResults = state.selectedCategoryFilter != null
            ? searchResults
                  .where((p) => p.categoryId == state.selectedCategoryFilter)
                  .toList()
            : searchResults;

        emit(
          state.copyWith(filteredProducts: filteredResults, isLoading: false),
        );
      } catch (e) {
        print('Error searching products: $e');
        emit(state.copyWith(isLoading: false, message: 'Search failed: $e'));
        _resetSearchToCurrentPage();
      }
    });
  }

  // Filter by category
  void filterByCategory(String? categoryId) {
    emit(
      state.copyWith(
        selectedCategoryFilter: categoryId,
        clearCategoryFilter: categoryId == null,
        products: [],
        currentPage: 1,
        lastFetchedDoc: null,
        firstFetchedDoc: null,
      ),
    );
    initializeProductsPagination();
  }

  // Reset search to current page
  void _resetSearchToCurrentPage() {
    if (state.products.isNotEmpty) {
      final currentPageIndex = state.currentPage - 1;
      if (currentPageIndex < state.products.length) {
        emit(
          state.copyWith(filteredProducts: state.products[currentPageIndex]),
        );
      }
    }
  }

  // Update product in list
  void updateProductInList(ProductModel updatedProduct) {
    final updatedProducts = List<List<ProductModel>>.from(state.products);
    for (int i = 0; i < updatedProducts.length; i++) {
      final pageProducts = List<ProductModel>.from(updatedProducts[i]);
      final index = pageProducts.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) {
        pageProducts[index] = updatedProduct;
        updatedProducts[i] = pageProducts;
        break;
      }
    }

    final currentPageIndex = state.currentPage - 1;
    final updatedFiltered = currentPageIndex < updatedProducts.length
        ? updatedProducts[currentPageIndex]
        : state.filteredProducts;

    emit(
      state.copyWith(
        products: updatedProducts,
        filteredProducts: updatedFiltered,
      ),
    );
  }

  // Add product to list
  void addProductToList(ProductModel newProduct) {
    final updatedProducts = List<List<ProductModel>>.from(state.products);
    if (updatedProducts.isNotEmpty) {
      updatedProducts[0] = [newProduct, ...updatedProducts[0]];

      final updatedFiltered = state.currentPage == 1
          ? updatedProducts[0]
          : state.filteredProducts;

      emit(
        state.copyWith(
          products: updatedProducts,
          filteredProducts: updatedFiltered,
        ),
      );
    }
  }

  // Remove product from list
  void removeProductFromList(String productId) {
    final updatedProducts = List<List<ProductModel>>.from(state.products);
    for (int i = 0; i < updatedProducts.length; i++) {
      final pageProducts = List<ProductModel>.from(updatedProducts[i]);
      pageProducts.removeWhere((p) => p.id == productId);
      updatedProducts[i] = pageProducts;
    }

    emit(
      state.copyWith(
        filteredProducts: state.filteredProducts
            .where((p) => p.id != productId)
            .toList(),
        products: updatedProducts,
      ),
    );
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    emit(state.copyWith(isLoading: true, message: null));
    try {
      await productRepository.deleteProduct(productId);
      removeProductFromList(productId);
      emit(state.copyWith(isLoading: false, message: "Product Deleted"));
    } catch (e) {
      emit(state.copyWith(isLoading: false, message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    searchController.dispose();
    debounce?.cancel();
    return super.close();
  }
}
