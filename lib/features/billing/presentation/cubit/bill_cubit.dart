import 'dart:async';
import 'package:billing_software/features/billing/data/firebase_bill_repository.dart';
import 'package:billing_software/features/billing/domain/entity/bill_model.dart';
import 'package:billing_software/features/billing/domain/entity/payment_model.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:billing_software/core/services/firebase.dart';

part 'bill_state.dart';

class BillCubit extends Cubit<BillState> {
  final BillRepository billRepository;
  static const int _pageSize = 10;

  BillCubit({required this.billRepository}) : super(BillState.initial());
  final searchController = TextEditingController();
  Timer? debounce;

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

  // Build query with filters
  Query _buildQuery({bool descending = true}) {
    Query query = FBFireStore.bills.orderBy(
      'createdAt',
      descending: descending,
    );

    // Apply status filter
    if (state.statusFilter != null) {
      query = FBFireStore.bills
          .where('status', isEqualTo: state.statusFilter)
          .orderBy('createdAt', descending: descending);
    }

    // Apply date range filter
    final dateRange = _getDateRange();
    if (dateRange != null) {
      if (state.statusFilter != null) {
        query = FBFireStore.bills
            .where('status', isEqualTo: state.statusFilter)
            .where('createdAt', isGreaterThanOrEqualTo: dateRange['start'])
            .where('createdAt', isLessThanOrEqualTo: dateRange['end'])
            .orderBy('createdAt', descending: descending);
      } else {
        query = FBFireStore.bills
            .where('createdAt', isGreaterThanOrEqualTo: dateRange['start'])
            .where('createdAt', isLessThanOrEqualTo: dateRange['end'])
            .orderBy('createdAt', descending: descending);
      }
    }

    return query.limit(_pageSize);
  }

  // Initialize bills pagination
  Future<void> initializeBillsPagination() async {
    searchController.clear();

    if (state.bills.isNotEmpty) {
      final currentPageIndex = state.currentPage - 1;
      if (currentPageIndex < state.bills.length) {
        emit(
          state.copyWith(
            filteredBills: state.bills[currentPageIndex],
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
        bills: [],
        filteredBills: [],
        lastFetchedDoc: null,
        currentPage: 1,
        totalPages: 1,
        message: null,
      ),
    );

    try {
      await fetchBillsPage();
      emit(
        state.copyWith(
          isLoading: false,
          filteredBills: state.bills.isNotEmpty ? state.bills[0] : [],
          searchQuery: '',
        ),
      );
    } catch (e) {
      print('Error initializing bills: $e');
      emit(state.copyWith(isLoading: false, message: e.toString()));
    }
  }

  // Fetch bills page
  Future<void> fetchBillsPage() async {
    try {
      int pageZeroIndex = state.currentPage - 1;

      if (pageZeroIndex < state.bills.length &&
          state.bills[pageZeroIndex].isNotEmpty) {
        return;
      }

      Query query = _buildQuery();

      if (state.lastFetchedDoc != null) {
        query = query.startAfterDocument(state.lastFetchedDoc!);
      }

      final snap = await query.get();

      if (snap.docs.isNotEmpty) {
        final bills = snap.docs
            .map(
              (doc) => BillModel.fromDocSnap(
                doc as QueryDocumentSnapshot<Map<String, dynamic>>,
              ),
            )
            .toList();

        final newLastFetchedDoc = snap.docs.last;
        final updatedBills = List<List<BillModel>>.from(state.bills);

        while (updatedBills.length <= pageZeroIndex) {
          updatedBills.add([]);
        }
        updatedBills[pageZeroIndex] = bills;

        int newTotalPages = state.totalPages;
        if (snap.docs.length == _pageSize) {
          newTotalPages = state.currentPage + 1;
        } else {
          newTotalPages = state.currentPage;
        }

        emit(
          state.copyWith(
            bills: updatedBills,
            lastFetchedDoc: newLastFetchedDoc,
            totalPages: newTotalPages,
          ),
        );
      } else {
        emit(state.copyWith(totalPages: state.currentPage - 1));
      }
    } catch (e) {
      print('Error fetching bills page: $e');
    }
  }

  // Fetch next bills page
  Future<void> fetchNextBillsPage({required int page}) async {
    final isNextPage = page > state.currentPage;
    emit(state.copyWith(isLoading: true, currentPage: page));

    if (isNextPage) {
      Query query = _buildQuery();

      if (state.lastFetchedDoc != null) {
        query = query.startAfterDocument(state.lastFetchedDoc!);
      }

      final snap = await query.get();

      if (snap.docs.isNotEmpty) {
        final bills = snap.docs
            .map(
              (doc) => BillModel.fromDocSnap(
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
            filteredBills: bills,
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
      Query query = _buildQuery(descending: false);

      if (state.firstFetchedDoc != null) {
        query = query.startAfterDocument(state.firstFetchedDoc!);
      }

      final snap = await query.get();

      if (snap.docs.isNotEmpty) {
        final bills = snap.docs
            .map(
              (doc) => BillModel.fromDocSnap(
                doc as QueryDocumentSnapshot<Map<String, dynamic>>,
              ),
            )
            .toList();
        bills.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final newFirstFetchedDoc = snap.docs.last;
        final newLastFetchedDoc = snap.docs.first;

        emit(
          state.copyWith(
            filteredBills: bills,
            firstFetchedDoc: newFirstFetchedDoc,
            lastFetchedDoc: newLastFetchedDoc,
          ),
        );
      }
    }

    emit(state.copyWith(isLoading: false));
  }

  // Search bills
  void searchBills(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    emit(state.copyWith(searchQuery: query));

    if (query.trim().isEmpty) {
      _resetSearchToCurrentPage();
      return;
    }

    debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        emit(state.copyWith(isLoading: true));

        final searchResults = await billRepository.searchBills(query.trim());

        final filteredResults = state.statusFilter != null
            ? searchResults
                  .where((b) => b.status == state.statusFilter)
                  .toList()
            : searchResults;

        emit(state.copyWith(filteredBills: filteredResults, isLoading: false));
      } catch (e) {
        print('Error searching bills: $e');
        emit(state.copyWith(isLoading: false, message: 'Search failed: $e'));
        _resetSearchToCurrentPage();
      }
    });
  }

  // Filter by status
  void filterByStatus(String? status) {
    emit(
      state.copyWith(
        statusFilter: status,
        clearStatusFilter: status == null,
        bills: [],
        currentPage: 1,
        lastFetchedDoc: null,
        firstFetchedDoc: null,
      ),
    );
    initializeBillsPagination();
  }

  // Filter by date range
  void filterByDateRange(
    String? dateRange, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    emit(
      state.copyWith(
        dateRangeFilter: dateRange,
        clearDateRangeFilter: dateRange == null,
        customStartDate: startDate,
        customEndDate: endDate,
        clearCustomDates: dateRange != 'Custom',
        bills: [],
        currentPage: 1,
        lastFetchedDoc: null,
        firstFetchedDoc: null,
      ),
    );
    initializeBillsPagination();
  }

  void _resetSearchToCurrentPage() {
    if (state.bills.isNotEmpty) {
      final currentPageIndex = state.currentPage - 1;
      if (currentPageIndex < state.bills.length) {
        emit(state.copyWith(filteredBills: state.bills[currentPageIndex]));
      }
    }
  }

  // Update bill in list
  void updateBillInList(BillModel updatedBill) {
    final updatedBills = List<List<BillModel>>.from(state.bills);
    for (int i = 0; i < updatedBills.length; i++) {
      final pageBills = List<BillModel>.from(updatedBills[i]);
      final index = pageBills.indexWhere((b) => b.id == updatedBill.id);
      if (index != -1) {
        pageBills[index] = updatedBill;
        updatedBills[i] = pageBills;
        break;
      }
    }

    final currentPageIndex = state.currentPage - 1;
    final updatedFiltered = currentPageIndex < updatedBills.length
        ? updatedBills[currentPageIndex]
        : state.filteredBills;

    emit(state.copyWith(bills: updatedBills, filteredBills: updatedFiltered));
  }

  // Add payment to bill
  Future<void> addPaymentToBill(
    String billId,
    double amount,
    String mode,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final payment = PaymentModel(
        id: "",
        amount: amount,
        mode: mode,
        paidAt: Timestamp.now(),
      );

      await billRepository.addPayment(billId, payment);

      // Fetch updated bill
      final billDoc = await FBFireStore.bills.doc(billId).get();
      final updatedBill = BillModel.fromJson(billDoc.data()!, billId);

      updateBillInList(updatedBill);

      emit(
        state.copyWith(isLoading: false, message: 'Payment added successfully'),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, message: 'Error: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    searchController.dispose();
    debounce?.cancel();
    return super.close();
  }
}
