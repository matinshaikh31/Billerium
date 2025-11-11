import 'dart:async';
import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/features/billing/domain/entity/bill_model.dart';
import 'package:billing_software/features/billing/domain/entity/payment_model.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'bill_state.dart';

class BillCubit extends Cubit<BillState> {
  final TextEditingController searchController = TextEditingController();
  final int _pageSize = 1;
  Timer? debounce;

  BillCubit() : super(BillState.initial());

  @override
  Future<void> close() {
    debounce?.cancel();
    searchController.dispose();
    return super.close();
  }

  // Initialize bills pagination
  Future<void> initializeBillsPagination() async {
    searchController.clear();

    emit(
      state.copyWith(
        isLoading: true,
        filteredBills: [],
        lastFetchedDoc: null,
        firstFetchedDoc: null,
        searchedBills: [],
        currentPage: 1,
        totalPages: 1,
        error: null,
        searchQuery: '',
      ),
    );

    final totalPages = (await getTotalBillsCount() / _pageSize).ceil();

    try {
      Query query = _buildBaseQuery(null).limit(_pageSize);

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

        emit(
          state.copyWith(
            filteredBills: bills,
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
      query = FBFireStore.bills.orderBy('createdAt', descending: true);
    } else if (isNext) {
      query = FBFireStore.bills.orderBy('createdAt', descending: true);
    } else {
      query = FBFireStore.bills.orderBy('createdAt', descending: false);
    }

    // Apply status filter
    if (state.statusFilter != null && state.statusFilter != 'All') {
      query = query.where('status', isEqualTo: state.statusFilter);
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
  Future<void> fetchNextBillsPage({required int page}) async {
    try {
      final isNextPage = page > state.currentPage;
      emit(state.copyWith(isLoading: true, currentPage: page));

      if (page == 1) {
        emit(state.copyWith(lastFetchedDoc: null, firstFetchedDoc: null));

        Query query = _buildBaseQuery(null).limit(_pageSize);

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

          emit(
            state.copyWith(
              filteredBills: bills,
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
          final bills = snap.docs
              .map(
                (doc) => BillModel.fromDocSnap(
                  doc as QueryDocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList();

          final newLastFetchedDoc = snap.docs.last;
          final newFirstFetchedDoc = snap.docs.first;

          emit(
            state.copyWith(
              filteredBills: bills,
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
          final bills = snap.docs
              .map(
                (doc) => BillModel.fromDocSnap(
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

          bills.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          emit(
            state.copyWith(
              filteredBills: bills,
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

  // Search bills
  void searchBills(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();

    emit(state.copyWith(searchQuery: query, isLoading: true));

    if (query.trim().isEmpty) {
      emit(
        state.copyWith(searchedBills: [], searchQuery: '', isLoading: false),
      );
      return;
    }

    debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        emit(state.copyWith(isLoading: true));

        Query searchQuery;

        final hasActiveFilter =
            state.statusFilter != null && state.statusFilter != 'All' ||
            state.startDate != null;

        if (hasActiveFilter) {
          searchQuery = _buildBaseQuery(null);
        } else {
          searchQuery = FBFireStore.bills.orderBy(
            'createdAt',
            descending: true,
          );
        }

        final snapshot = await searchQuery.limit(50).get();

        final allBills = snapshot.docs
            .map(
              (doc) => BillModel.fromDocSnap(
                doc as QueryDocumentSnapshot<Map<String, dynamic>>,
              ),
            )
            .toList();

        final searchLower = query.toLowerCase();
        final results = allBills
            .where((bill) {
              return (bill.customerName?.toLowerCase().contains(searchLower) ??
                      false) ||
                  (bill.customerPhone?.toLowerCase().contains(searchLower) ??
                      false);
            })
            .take(50)
            .toList();

        emit(state.copyWith(searchedBills: results, isLoading: false));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: 'Search failed: $e'));
      }
    });
  }

  // Filter by status
  Future<void> filterByStatus(String? status) async {
    emit(state.copyWith(statusFilter: status, searchQuery: ''));
    searchController.clear();
    await initializeBillsPagination();
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
    await initializeBillsPagination();
  }

  Future<int> getTotalBillsCount() async {
    try {
      final query = _buildBaseQuery(null);
      final countSnapshot = await query.count().get();
      return countSnapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // ==================== SMART REFRESH METHODS ====================

  // Refresh current page
  Future<void> refreshCurrentPage() async {
    if (state.currentPage == 1) {
      await initializeBillsPagination();
    } else {
      await fetchNextBillsPage(page: state.currentPage);
    }
  }

  // Update bill in current list
  void updateBillInList(BillModel updatedBill) {
    final currentBills = List<BillModel>.from(state.filteredBills);
    final index = currentBills.indexWhere((b) => b.id == updatedBill.id);

    if (index != -1) {
      currentBills[index] = updatedBill;
      emit(state.copyWith(filteredBills: currentBills));
    }
  }

  // Remove bill from current list
  Future<void> removeBillFromList(String billId) async {
    final currentBills = List<BillModel>.from(state.filteredBills);
    currentBills.removeWhere((b) => b.id == billId);

    if (currentBills.isEmpty && state.currentPage > 1) {
      await fetchNextBillsPage(page: state.currentPage - 1);
    } else {
      emit(state.copyWith(filteredBills: currentBills));
      await refreshCurrentPage();
    }
  }

  // Add payment to bill
  Future<void> addPaymentToBill(
    String billId,
    double amount,
    String mode,
  ) async {
    try {
      final billDoc = await FBFireStore.bills.doc(billId).get();
      if (!billDoc.exists) return;

      final billData = billDoc.data() as Map<String, dynamic>;
      final bill = BillModel.fromJson(billData, billDoc.id);

      final newAmountPaid = bill.amountPaid + amount;
      final newPendingAmount = bill.finalAmount - newAmountPaid;

      String newStatus;
      if (newPendingAmount <= 0) {
        newStatus = 'Paid';
      } else if (newAmountPaid > 0) {
        newStatus = 'PartiallyPaid';
      } else {
        newStatus = 'Unpaid';
      }

      // Create new payment
      final newPayment = PaymentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        mode: mode,
        paidAt: Timestamp.now(),
      );

      // Update payments list
      final updatedPayments = [...bill.payments, newPayment];

      await FBFireStore.bills.doc(billId).update({
        'amountPaid': newAmountPaid,
        'pendingAmount': newPendingAmount,
        'status': newStatus,
        'payments': updatedPayments.map((p) => p.toJson()).toList(),
        'updatedAt': Timestamp.now(),
      });

      // Fetch updated bill
      final updatedBillDoc = await FBFireStore.bills.doc(billId).get();
      final updatedBillData = updatedBillDoc.data() as Map<String, dynamic>;
      final updatedBill = BillModel.fromJson(
        updatedBillData,
        updatedBillDoc.id,
      );

      // Smart refresh
      if (state.currentPage == 1) {
        await initializeBillsPagination();
      } else {
        updateBillInList(updatedBill);
      }
    } catch (e) {
      emit(state.copyWith(error: 'Payment failed: $e'));
    }
  }

  // Refresh
  Future<void> refresh() async {
    await initializeBillsPagination();
  }
}
