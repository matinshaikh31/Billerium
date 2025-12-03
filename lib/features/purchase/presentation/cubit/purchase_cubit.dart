import 'dart:async';
import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/features/purchase/domain/entity/purchase_model.dart';
import 'package:billing_software/features/purchase/domain/repo/purchase_repo.dart';
import 'package:billing_software/features/purchase/presentation/cubit/purchase_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PurchaseCubit extends Cubit<PurchaseState> {
  final PurchaseRepo purchaseRepo;
  final TextEditingController searchController = TextEditingController();
  final int _pageSize = 10;
  Timer? debounce;

  PurchaseCubit({required this.purchaseRepo}) : super(const PurchaseState());

  @override
  Future<void> close() {
    debounce?.cancel();
    searchController.dispose();
    return super.close();
  }

  // Initialize purchases pagination
  Future<void> initializePurchasesPagination() async {
    searchController.clear();

    emit(
      state.copyWith(
        isLoading: true,
        filteredPurchases: [],
        lastFetchedDoc: null,
        firstFetchedDoc: null,
        searchedPurchases: [],
        currentPage: 1,
        totalPages: 1,
        error: null,
        searchQuery: '',
      ),
    );

    final totalPages = (await getTotalPurchasesCount() / _pageSize).ceil();

    try {
      Query query = _buildBaseQuery(null).limit(_pageSize);

      final snap = await query.get();
      if (snap.docs.isNotEmpty) {
        final purchases = snap.docs
            .map(
              (doc) => PurchaseModel.fromDocSnap(
                doc as QueryDocumentSnapshot<Map<String, dynamic>>,
              ),
            )
            .toList();

        final newLastFetchedDoc = snap.docs.last;
        final newFirstFetchedDoc = snap.docs.first;

        emit(
          state.copyWith(
            filteredPurchases: purchases,
            lastFetchedDoc: newLastFetchedDoc,
            firstFetchedDoc: newFirstFetchedDoc,
            totalPages: totalPages > 0 ? totalPages : 1,
            isLoading: false,
          ),
        );
      } else {
        emit(state.copyWith(totalPages: 1, isLoading: false));
      }
    } catch (e) {
      debugPrint(e.toString());
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // Build base query with filters
  Query _buildBaseQuery(bool? isNext) {
    Query query;

    if (isNext == null) {
      query = FBFireStore.purchases.orderBy('createdAt', descending: true);
    } else if (isNext) {
      query = FBFireStore.purchases.orderBy('createdAt', descending: true);
    } else {
      query = FBFireStore.purchases.orderBy('createdAt', descending: false);
    }

    // Apply date range filter
    if (state.startDate != null && state.endDate != null) {
      query = query
          .where('createdAt', isGreaterThanOrEqualTo: state.startDate)
          .where('createdAt', isLessThanOrEqualTo: state.endDate);
    }

    return query;
  }

  // Fetch next page
  Future<void> fetchNextPurchasesPage({required int page}) async {
    try {
      final isNextPage = page > state.currentPage;
      emit(state.copyWith(isLoading: true, currentPage: page));

      if (page == 1) {
        emit(state.copyWith(lastFetchedDoc: null, firstFetchedDoc: null));

        Query query = _buildBaseQuery(null).limit(_pageSize);

        final snap = await query.get();
        if (snap.docs.isNotEmpty) {
          final purchases = snap.docs
              .map(
                (doc) => PurchaseModel.fromDocSnap(
                  doc as QueryDocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList();

          final newLastFetchedDoc = snap.docs.last;
          final newFirstFetchedDoc = snap.docs.first;

          emit(
            state.copyWith(
              filteredPurchases: purchases,
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
          final purchases = snap.docs
              .map(
                (doc) => PurchaseModel.fromDocSnap(
                  doc as QueryDocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList();

          final newLastFetchedDoc = snap.docs.last;
          final newFirstFetchedDoc = snap.docs.first;

          emit(
            state.copyWith(
              filteredPurchases: purchases,
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
          final purchases = snap.docs
              .map(
                (doc) => PurchaseModel.fromDocSnap(
                  doc as QueryDocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList();

          // IMPORTANT: For previous page, reverse the cursor documents
          final newFirstFetchedDoc = snap.docs.last;
          final newLastFetchedDoc = snap.docs.first;

          // Sort purchases in descending order (newest first)
          purchases.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          emit(
            state.copyWith(
              filteredPurchases: purchases,
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

  // Search purchases
  void searchPurchases(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();

    emit(state.copyWith(searchQuery: query, isLoading: true));

    if (query.trim().isEmpty) {
      emit(
        state.copyWith(
          searchedPurchases: [],
          searchQuery: '',
          isLoading: false,
        ),
      );
      return;
    }

    debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        emit(state.copyWith(isLoading: true));

        Query searchQuery;

        final hasActiveFilter = state.startDate != null;

        if (hasActiveFilter) {
          searchQuery = _buildBaseQuery(null);
        } else {
          searchQuery = FBFireStore.purchases.orderBy(
            'createdAt',
            descending: true,
          );
        }

        final snapshot = await searchQuery.limit(50).get();

        final allPurchases = snapshot.docs
            .map(
              (doc) => PurchaseModel.fromDocSnap(
                doc as QueryDocumentSnapshot<Map<String, dynamic>>,
              ),
            )
            .toList();

        final searchLower = query.toLowerCase();
        final results = allPurchases
            .where((purchase) {
              return (purchase.supplierName?.toLowerCase().contains(
                        searchLower,
                      ) ??
                      false) ||
                  (purchase.id.toLowerCase().contains(searchLower)) ||
                  (purchase.purchaseNo.toLowerCase().contains(searchLower));
            })
            .take(20)
            .toList();

        emit(state.copyWith(searchedPurchases: results, isLoading: false));
      } catch (e) {
        debugPrint('Error searching purchases: $e');
        emit(state.copyWith(isLoading: false, error: 'Search failed: $e'));
      }
    });
  }

  // Filter by date range
  Future<void> filterByDateRange(
    String? range, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    DateTime? start;
    DateTime? end;

    if (range == null) {
      // Clear filter
      start = null;
      end = null;
    } else if (range == 'LastWeek') {
      end = DateTime.now();
      start = end.subtract(const Duration(days: 7));
    } else if (range == 'LastMonth') {
      end = DateTime.now();
      start = DateTime(end.year, end.month - 1, end.day);
    } else if (range == 'Last3Months') {
      end = DateTime.now();
      start = DateTime(end.year, end.month - 3, end.day);
    } else if (range == 'Custom' && startDate != null && endDate != null) {
      start = startDate;
      end = endDate;
    }

    emit(
      state.copyWith(
        dateRangeFilter: range,
        startDate: start != null ? Timestamp.fromDate(start) : null,
        endDate: end != null ? Timestamp.fromDate(end) : null,
        searchQuery: '',
      ),
    );
    searchController.clear();
    await initializePurchasesPagination();
  }

  Future<int> getTotalPurchasesCount() async {
    try {
      final query = _buildBaseQuery(null);
      final countSnapshot = await query.count().get();
      return countSnapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Legacy methods for backward compatibility
  Future<void> fetchPurchases() async {
    await initializePurchasesPagination();
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
      await initializePurchasesPagination();
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to create purchase: ${e.toString()}',
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
      await initializePurchasesPagination();
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to delete purchase: ${e.toString()}',
        ),
      );
    }
  }

  // Refresh
  Future<void> refresh() async {
    await initializePurchasesPagination();
  }

  void clearMessages() {
    emit(state.copyWith(error: null, successMessage: null));
  }
}
