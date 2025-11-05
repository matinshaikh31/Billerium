import 'dart:async';
import 'package:billing_software/features/transactions/domain/models/transaction_model.dart';
import 'package:billing_software/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:billing_software/core/services/firebase.dart';

part 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository transactionRepository;
  static const int _pageSize = 10;

  TransactionCubit({required this.transactionRepository})
      : super(TransactionState.initial());
  final searchController = TextEditingController();
  Timer? debounce;

  // Build query with filters
  Query _buildQuery({bool descending = true}) {
    Query query = FBFireStore.transactions.orderBy('timestamp', descending: descending);

    // Apply payment mode filter
    if (state.paymentModeFilter != null) {
      query = FBFireStore.transactions
          .where('mode', isEqualTo: state.paymentModeFilter)
          .orderBy('timestamp', descending: descending);
    }

    // Apply date range filter
    final dateRange = _getDateRange();
    if (dateRange != null) {
      if (state.paymentModeFilter != null) {
        query = FBFireStore.transactions
            .where('mode', isEqualTo: state.paymentModeFilter)
            .where('timestamp', isGreaterThanOrEqualTo: dateRange['start'])
            .where('timestamp', isLessThanOrEqualTo: dateRange['end'])
            .orderBy('timestamp', descending: descending);
      } else {
        query = FBFireStore.transactions
            .where('timestamp', isGreaterThanOrEqualTo: dateRange['start'])
            .where('timestamp', isLessThanOrEqualTo: dateRange['end'])
            .orderBy('timestamp', descending: descending);
      }
    }

    return query.limit(_pageSize);
  }

  // Get date range based on filter
  Map<String, Timestamp>? _getDateRange() {
    if (state.dateRangeFilter == null) return null;

    final now = DateTime.now();
    DateTime? startDate;

    switch (state.dateRangeFilter) {
      case 'LastMonth':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'Last3Months':
        startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      case 'Custom':
        if (state.customStartDate != null && state.customEndDate != null) {
          return {
            'start': Timestamp.fromDate(state.customStartDate!),
            'end': Timestamp.fromDate(state.customEndDate!),
          };
        }
        return null;
      default:
        return null;
    }

    return {
      'start': Timestamp.fromDate(startDate),
      'end': Timestamp.fromDate(now),
    };
  }

  // Initialize transactions pagination
  Future<void> initializeTransactionsPagination() async {
    searchController.clear();

    if (state.transactions.isNotEmpty) {
      final currentPageIndex = state.currentPage - 1;
      if (currentPageIndex < state.transactions.length) {
        emit(state.copyWith(
          filteredTransactions: state.transactions[currentPageIndex],
          isLoading: false,
          searchQuery: '',
        ));
      }
      return;
    }

    emit(state.copyWith(
      isLoading: true,
      transactions: [],
      filteredTransactions: [],
      lastFetchedDoc: null,
      currentPage: 1,
      totalPages: 1,
      message: null,
    ));

    try {
      await fetchTransactionsPage();
      emit(state.copyWith(
        isLoading: false,
        filteredTransactions: state.transactions.isNotEmpty ? state.transactions[0] : [],
        searchQuery: '',
      ));
    } catch (e) {
      print('Error initializing transactions: $e');
      emit(state.copyWith(isLoading: false, message: e.toString()));
    }
  }

  // Fetch transactions page
  Future<void> fetchTransactionsPage() async {
    try {
      int pageZeroIndex = state.currentPage - 1;

      if (pageZeroIndex < state.transactions.length &&
          state.transactions[pageZeroIndex].isNotEmpty) {
        return;
      }

      Query query = _buildQuery();

      if (state.lastFetchedDoc != null) {
        query = query.startAfterDocument(state.lastFetchedDoc!);
      }

      final snap = await query.get();

      if (snap.docs.isNotEmpty) {
        final transactions = snap.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return TransactionModel(
            id: doc.id,
            billId: data['billId'] as String,
            customerName: data['customerName'] as String,
            amount: (data['amount'] as num).toDouble(),
            mode: data['mode'] as String,
            timestamp: (data['timestamp'] as Timestamp).toDate(),
          );
        }).toList();

        final newLastFetchedDoc = snap.docs.last;
        final updatedTransactions = List<List<TransactionModel>>.from(state.transactions);

        while (updatedTransactions.length <= pageZeroIndex) {
          updatedTransactions.add([]);
        }
        updatedTransactions[pageZeroIndex] = transactions;

        int newTotalPages = state.totalPages;
        if (snap.docs.length == _pageSize) {
          newTotalPages = state.currentPage + 1;
        } else {
          newTotalPages = state.currentPage;
        }

        emit(state.copyWith(
          transactions: updatedTransactions,
          lastFetchedDoc: newLastFetchedDoc,
          totalPages: newTotalPages,
        ));
      } else {
        emit(state.copyWith(totalPages: state.currentPage - 1));
      }
    } catch (e) {
      print('Error fetching transactions page: $e');
    }
  }

  // Fetch next transactions page
  Future<void> fetchNextTransactionsPage({required int page}) async {
    final isNextPage = page > state.currentPage;
    emit(state.copyWith(isLoading: true, currentPage: page));

    if (isNextPage) {
      Query query = _buildQuery();

      if (state.lastFetchedDoc != null) {
        query = query.startAfterDocument(state.lastFetchedDoc!);
      }

      final snap = await query.get();

      if (snap.docs.isNotEmpty) {
        final transactions = snap.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return TransactionModel(
            id: doc.id,
            billId: data['billId'] as String,
            customerName: data['customerName'] as String,
            amount: (data['amount'] as num).toDouble(),
            mode: data['mode'] as String,
            timestamp: (data['timestamp'] as Timestamp).toDate(),
          );
        }).toList();

        final newLastFetchedDoc = snap.docs.last;
        final newFirstFetchedDoc = snap.docs.first;

        int newTotalPages = state.totalPages;
        if (snap.docs.length == _pageSize) {
          newTotalPages = state.currentPage + 1;
        } else {
          newTotalPages = state.currentPage;
        }

        emit(state.copyWith(
          filteredTransactions: transactions,
          lastFetchedDoc: newLastFetchedDoc,
          firstFetchedDoc: newFirstFetchedDoc,
          totalPages: newTotalPages,
        ));
      } else {
        emit(state.copyWith(totalPages: state.currentPage - 1));
      }
    } else {
      // Previous page logic
      Query query = _buildQuery(descending: false);

      if (state.firstFetchedDoc != null) {
        query = query.startAfterDocument(state.firstFetchedDoc!);
      }

      final snap = await query.get();

      if (snap.docs.isNotEmpty) {
        final transactions = snap.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return TransactionModel(
            id: doc.id,
            billId: data['billId'] as String,
            customerName: data['customerName'] as String,
            amount: (data['amount'] as num).toDouble(),
            mode: data['mode'] as String,
            timestamp: (data['timestamp'] as Timestamp).toDate(),
          );
        }).toList();
        transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        final newFirstFetchedDoc = snap.docs.last;
        final newLastFetchedDoc = snap.docs.first;

        emit(state.copyWith(
          filteredTransactions: transactions,
          firstFetchedDoc: newFirstFetchedDoc,
          lastFetchedDoc: newLastFetchedDoc,
        ));
      }
    }

    emit(state.copyWith(isLoading: false));
  }

  // Search transactions
  void searchTransactions(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    emit(state.copyWith(searchQuery: query));

    if (query.trim().isEmpty) {
      _resetSearchToCurrentPage();
      return;
    }

    debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        emit(state.copyWith(isLoading: true));

        final searchResults = await transactionRepository.searchTransactions(query.trim());

        final filteredResults = state.paymentModeFilter != null
            ? searchResults.where((t) => t.mode == state.paymentModeFilter).toList()
            : searchResults;

        emit(state.copyWith(filteredTransactions: filteredResults, isLoading: false));
      } catch (e) {
        print('Error searching transactions: $e');
        emit(state.copyWith(isLoading: false, message: 'Search failed: $e'));
        _resetSearchToCurrentPage();
      }
    });
  }

  // Filter by payment mode
  void filterByPaymentMode(String? mode) {
    emit(state.copyWith(
      paymentModeFilter: mode,
      clearPaymentModeFilter: mode == null,
      transactions: [],
      currentPage: 1,
      lastFetchedDoc: null,
      firstFetchedDoc: null,
    ));
    initializeTransactionsPagination();
  }

  // Filter by date range
  void filterByDateRange(String? dateRange, {DateTime? startDate, DateTime? endDate}) {
    emit(state.copyWith(
      dateRangeFilter: dateRange,
      clearDateRangeFilter: dateRange == null,
      customStartDate: startDate,
      customEndDate: endDate,
      clearCustomDates: dateRange != 'Custom',
      transactions: [],
      currentPage: 1,
      lastFetchedDoc: null,
      firstFetchedDoc: null,
    ));
    initializeTransactionsPagination();
  }

  void _resetSearchToCurrentPage() {
    if (state.transactions.isNotEmpty) {
      final currentPageIndex = state.currentPage - 1;
      if (currentPageIndex < state.transactions.length) {
        emit(state.copyWith(filteredTransactions: state.transactions[currentPageIndex]));
      }
    }
  }

  @override
  Future<void> close() {
    searchController.dispose();
    debounce?.cancel();
    return super.close();
  }
}

