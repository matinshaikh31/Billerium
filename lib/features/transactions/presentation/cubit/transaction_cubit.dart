import 'dart:async';
import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/features/transactions/domain/models/transaction_model.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final TextEditingController searchController = TextEditingController();
  final int _pageSize = 1;
  Timer? debounce;

  TransactionCubit() : super(TransactionState.initial());

  @override
  Future<void> close() {
    debounce?.cancel();
    searchController.dispose();
    return super.close();
  }

  // Initialize transactions pagination
  Future<void> initializeTransactionsPagination() async {
    searchController.clear();

    emit(
      state.copyWith(
        isLoading: true,
        filteredTransactions: [],
        lastFetchedDoc: null,
        firstFetchedDoc: null,
        searchedTransactions: [],
        currentPage: 1,
        totalPages: 1,
        error: null,
        searchQuery: '',
      ),
    );

    final totalPages = (await getTotalTransactionsCount() / _pageSize).ceil();

    try {
      Query query = _buildBaseQuery(null).limit(_pageSize);

      final snap = await query.get();
      if (snap.docs.isNotEmpty) {
        final transactions = snap.docs
            .map(
              (doc) => TransactionModel.fromDocSnap(
                doc as QueryDocumentSnapshot<Map<String, dynamic>>,
              ),
            )
            .toList();

        final newLastFetchedDoc = snap.docs.last;
        final newFirstFetchedDoc = snap.docs.first;

        emit(
          state.copyWith(
            filteredTransactions: transactions,
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
      query = FBFireStore.transactions.orderBy('timestamp', descending: true);
    } else if (isNext) {
      query = FBFireStore.transactions.orderBy('timestamp', descending: true);
    } else {
      query = FBFireStore.transactions.orderBy('timestamp', descending: false);
    }

    // Apply date range filter
    if (state.startDate != null && state.endDate != null) {
      query = query
          .where('timestamp', isGreaterThanOrEqualTo: state.startDate)
          .where('timestamp', isLessThanOrEqualTo: state.endDate);
    }

    return query;
  }

  // Fetch next page
  Future<void> fetchNextTransactionsPage({required int page}) async {
    try {
      final isNextPage = page > state.currentPage;
      emit(state.copyWith(isLoading: true, currentPage: page));

      if (page == 1) {
        emit(state.copyWith(lastFetchedDoc: null, firstFetchedDoc: null));

        Query query = _buildBaseQuery(null).limit(_pageSize);

        final snap = await query.get();
        if (snap.docs.isNotEmpty) {
          final transactions = snap.docs
              .map(
                (doc) => TransactionModel.fromDocSnap(
                  doc as QueryDocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList();

          final newLastFetchedDoc = snap.docs.last;
          final newFirstFetchedDoc = snap.docs.first;

          emit(
            state.copyWith(
              filteredTransactions: transactions,
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
          final transactions = snap.docs
              .map(
                (doc) => TransactionModel.fromDocSnap(
                  doc as QueryDocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList();

          final newLastFetchedDoc = snap.docs.last;
          final newFirstFetchedDoc = snap.docs.first;

          emit(
            state.copyWith(
              filteredTransactions: transactions,
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
          final transactions = snap.docs
              .map(
                (doc) => TransactionModel.fromDocSnap(
                  doc as QueryDocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList();

          snap.docs.sort(
            (a, b) =>
                ((b.data() as Map<String, dynamic>)['timestamp'] as Timestamp)
                    .compareTo(
                      ((a.data() as Map<String, dynamic>)['timestamp']
                          as Timestamp),
                    ),
          );

          final newFirstFetchedDoc = snap.docs.first;
          final newLastFetchedDoc = snap.docs.last;

          transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          emit(
            state.copyWith(
              filteredTransactions: transactions,
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

  // Search transactions
  void searchTransactions(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();

    emit(state.copyWith(searchQuery: query, isLoading: true));

    if (query.trim().isEmpty) {
      emit(
        state.copyWith(
          searchedTransactions: [],
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
          searchQuery = FBFireStore.transactions.orderBy(
            'timestamp',
            descending: true,
          );
        }

        final snapshot = await searchQuery.limit(50).get();

        final allTransactions = snapshot.docs
            .map(
              (doc) => TransactionModel.fromDocSnap(
                doc as QueryDocumentSnapshot<Map<String, dynamic>>,
              ),
            )
            .toList();

        final searchLower = query.toLowerCase();
        final results = allTransactions
            .where((transaction) {
              return (transaction.customerName.toLowerCase().contains(
                    searchLower,
                  )) ||
                  (transaction.id.toLowerCase().contains(searchLower));
            })
            .take(50)
            .toList();

        emit(state.copyWith(searchedTransactions: results, isLoading: false));
      } catch (e) {
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
    await initializeTransactionsPagination();
  }

  Future<int> getTotalTransactionsCount() async {
    try {
      final query = _buildBaseQuery(null);
      final countSnapshot = await query.count().get();
      return countSnapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Refresh current page
  Future<void> refreshCurrentPage() async {
    if (state.currentPage == 1) {
      await initializeTransactionsPagination();
    } else {
      await fetchNextTransactionsPage(page: state.currentPage);
    }
  }

  // Refresh
  Future<void> refresh() async {
    await initializeTransactionsPagination();
  }
}
