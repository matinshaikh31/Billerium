import 'dart:async';
import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/features/products/domain/entity/product_model.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final TextEditingController searchController = TextEditingController();
  final int _pageSize = 2;
  Timer? debounce;

  ProductCubit() : super(ProductState.initial());

  @override
  Future<void> close() {
    debounce?.cancel();
    searchController.dispose();
    return super.close();
  }

  // Initialize products pagination
  Future<void> initializeProductsPagination() async {
    searchController.clear();

    emit(
      state.copyWith(
        isLoading: true,
        filteredProducts: [],
        lastFetchedDoc: null,
        firstFetchedDoc: null,
        searchedProducts: [],
        currentPage: 1,
        totalPages: 1,
        error: null,
        searchQuery: '',
      ),
    );

    final totalPages = (await getTotalProductsCount() / _pageSize).ceil();

    try {
      Query query = _buildBaseQuery(null).limit(_pageSize);

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

        emit(
          state.copyWith(
            filteredProducts: products,
            lastFetchedDoc: newLastFetchedDoc,
            firstFetchedDoc: newFirstFetchedDoc,
            totalPages: totalPages,
            isLoading: false,
          ),
        );
      } else {
        emit(
          state.copyWith(totalPages: state.currentPage - 1, isLoading: false),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // Build base query with filters
  Query _buildBaseQuery(bool? isNext) {
    Query query;

    if (isNext == null) {
      query = FBFireStore.products.orderBy('createdAt', descending: true);
    } else if (isNext) {
      query = FBFireStore.products.orderBy('createdAt', descending: true);
    } else {
      query = FBFireStore.products.orderBy('createdAt', descending: false);
    }

    // Apply category filter
    if (state.selectedCategory != 'All') {
      query = query.where('categoryId', isEqualTo: state.selectedCategory);
    }

    return query;
  }

  // Fetch next page
  Future<void> fetchNextProductsPage({required int page}) async {
    try {
      final isNextPage = page > state.currentPage;
      emit(state.copyWith(isLoading: true, currentPage: page));

      if (page == 1) {
        emit(state.copyWith(lastFetchedDoc: null, firstFetchedDoc: null));

        Query query = _buildBaseQuery(null).limit(_pageSize);

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

          emit(
            state.copyWith(
              filteredProducts: products,
              lastFetchedDoc: newLastFetchedDoc,
              firstFetchedDoc: newFirstFetchedDoc,
              isLoading: false,
            ),
          );
        } else {
          emit(
            state.copyWith(totalPages: state.currentPage - 1, isLoading: false),
          );
        }

        return;
      }

      if (isNextPage) {
        Query query = _buildBaseQuery(true).limit(_pageSize);

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

          emit(
            state.copyWith(
              filteredProducts: products,
              lastFetchedDoc: newLastFetchedDoc,
              firstFetchedDoc: newFirstFetchedDoc,
              isLoading: false,
            ),
          );
        } else {
          emit(
            state.copyWith(totalPages: state.currentPage - 1, isLoading: false),
          );
        }
      } else {
        // Previous page
        Query query = _buildBaseQuery(false).limit(_pageSize);

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

          snap.docs.sort(
            (a, b) =>
                ((b.data() as Map<String, dynamic>)['createdAt'] as Timestamp)
                    .compareTo(
                      ((a.data() as Map<String, dynamic>)['createdAt']
                          as Timestamp),
                    ),
          );

          final newFirstFetchedDoc = snap.docs.first;
          final newLastFetchedDoc = snap.docs.last;

          products.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          emit(
            state.copyWith(
              filteredProducts: products,
              firstFetchedDoc: newFirstFetchedDoc,
              lastFetchedDoc: newLastFetchedDoc,
              isLoading: false,
            ),
          );
        } else {
          emit(
            state.copyWith(totalPages: state.currentPage - 1, isLoading: false),
          );
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // Search products
  void searchProducts(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();

    emit(state.copyWith(searchQuery: query, isLoading: true));

    if (query.trim().isEmpty) {
      emit(
        state.copyWith(searchedProducts: [], searchQuery: '', isLoading: false),
      );
      return;
    }

    debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        emit(state.copyWith(isLoading: true));

        Query searchQuery;

        final hasActiveFilter = state.selectedCategory != 'All';

        if (hasActiveFilter) {
          searchQuery = _buildBaseQuery(null);
        } else {
          searchQuery = FBFireStore.products.orderBy(
            'createdAt',
            descending: true,
          );
        }

        final snapshot = await searchQuery.limit(20).get();

        final allProducts = snapshot.docs
            .map(
              (doc) => ProductModel.fromDocSnap(
                doc as QueryDocumentSnapshot<Map<String, dynamic>>,
              ),
            )
            .toList();

        final searchLower = query.toLowerCase();
        final results = allProducts
            .where((product) {
              return product.name.toLowerCase().contains(searchLower) ||
                  (product.sku?.toLowerCase().contains(searchLower) ?? false);
            })
            .take(20)
            .toList();

        emit(state.copyWith(searchedProducts: results, isLoading: false));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: 'Search failed: $e'));
      }
    });
  }

  // Filter by category
  Future<void> filterByCategory(String category) async {
    emit(state.copyWith(selectedCategory: category, searchQuery: ''));
    searchController.clear();
    await initializeProductsPagination();
  }

  Future<int> getTotalProductsCount() async {
    try {
      final query = _buildBaseQuery(null);
      final countSnapshot = await query.count().get();
      return countSnapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Refresh current page data
  Future<void> refreshCurrentPage() async {
    if (state.currentPage == 1) {
      // If on page 1, do full refresh
      await initializeProductsPagination();
    } else {
      // If on other pages, refresh that specific page
      await fetchNextProductsPage(page: state.currentPage);
    }
  }

  // Update product in current list (for updates on current page)
  void updateProductInList(ProductModel updatedProduct) {
    final currentProducts = List<ProductModel>.from(state.filteredProducts);
    final index = currentProducts.indexWhere((p) => p.id == updatedProduct.id);

    if (index != -1) {
      currentProducts[index] = updatedProduct;
      emit(state.copyWith(filteredProducts: currentProducts));
    }
  }

  // Remove product from current list (for deletes on current page)
  Future<void> removeProductFromList(String productId) async {
    final currentProducts = List<ProductModel>.from(state.filteredProducts);
    currentProducts.removeWhere((p) => p.id == productId);

    // If page becomes empty and we're not on page 1, go back
    if (currentProducts.isEmpty && state.currentPage > 1) {
      await fetchNextProductsPage(page: state.currentPage - 1);
    } else {
      // Otherwise just update the list and refresh to fill the gap
      emit(state.copyWith(filteredProducts: currentProducts));
      await refreshCurrentPage();
    }
  }

  Future<void> handleDeleteProduct(
    BuildContext context,
    ProductModel product,
  ) async {
    try {
      final productCubit = context.read<ProductCubit>();

      // Delete the product from Firebase
      await FBFireStore.products.doc(product.id).delete();

      // Smart refresh based on current page
      if (productCubit.state.currentPage == 1) {
        // If on page 1, refresh to get latest data
        await productCubit.initializeProductsPagination();
      } else {
        // If on other pages, remove from list and refresh current page
        await productCubit.removeProductFromList(product.id);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product "${product.name}" deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Fetch product statistics
  Future<void> fetchProductStats() async {
    try {
      final snapshot = await FBFireStore.products.get();

      final allProducts = snapshot.docs
          .map((doc) => ProductModel.fromDocSnap(doc))
          .toList();

      final totalProducts = allProducts.length;
      final inStockProducts = allProducts.where((p) => p.stockQty > 0).length;
      final outOfStockProducts = allProducts
          .where((p) => p.stockQty == 0)
          .length;
      final lowStockProducts = allProducts
          .where((p) => p.stockQty > 0 && p.stockQty <= 10)
          .length;

      // Products with discount
      final discountedProducts = allProducts
          .where((p) => p.discountPercent != null && p.discountPercent! > 0)
          .length;

      // Total inventory value
      final totalInventoryValue = allProducts.fold<double>(
        0,
        (sum, product) => sum + (product.price * product.stockQty),
      );

      // Average product price
      final averagePrice = totalProducts > 0
          ? allProducts.fold<double>(0, (sum, product) => sum + product.price) /
                totalProducts
          : 0.0;

      // Count by category (you'll need to fetch categories separately)
      final categoryCount = <String, int>{};
      for (var product in allProducts) {
        categoryCount[product.categoryId] =
            (categoryCount[product.categoryId] ?? 0) + 1;
      }

      emit(
        state.copyWith(
          productStats: {
            'totalProducts': totalProducts,
            'inStockProducts': inStockProducts,
            'outOfStockProducts': outOfStockProducts,
            'lowStockProducts': lowStockProducts,
            'discountedProducts': discountedProducts,
            'totalInventoryValue': totalInventoryValue,
            'averagePrice': averagePrice,
            'categoryCount': categoryCount,
          },
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          productStats: {
            'totalProducts': 0,
            'inStockProducts': 0,
            'outOfStockProducts': 0,
            'lowStockProducts': 0,
            'discountedProducts': 0,
            'totalInventoryValue': 0.0,
            'averagePrice': 0.0,
            'categoryCount': <String, int>{},
          },
        ),
      );
    }
  }

  // Refresh
  Future<void> refresh() async {
    await initializeProductsPagination();
  }
}
