import 'dart:async';
import 'package:billing_software/features/billing2/data/firebase_bill_repository.dart';
import 'package:billing_software/features/billing2/domain/entity/bill_model.dart';
import 'package:billing_software/features/billing2/domain/entity/payment_model.dart';
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

  // Fetch bills page
  // Future<void> fetchBillsPage() async {
  //   try {
  //     int pageZeroIndex = state.currentPage - 1;

  //     if (pageZeroIndex < state.bills.length && state.bills[pageZeroIndex].isNotEmpty) {
  //       return;
  //     }

  //     Query query = FBFireStore.bills.orderBy('createdAt', descending: true).limit(_pageSize);

  //     if (state.statusFilter != null) {
  //       query = FBFireStore.bills
  //           .where('status', isEqualTo: state.statusFilter)
  //           .orderBy('createdAt', descending: true)
  //           .limit(_pageSize);
  //     }

  //     if (state.lastFetchedDoc != null) {
  //       query = query.startAfterDocument(state.lastFetchedDoc!);
  //     }

  //     final snap = await query.get();

  //     if (snap.docs.isNotEmpty) {
  //       final bills = snap.docs.map((doc) => BillModel.fromDocSnap(doc as QueryDocumentSnapshot<Map<String, dynamic>>)).toList();

  //       final newLastFetchedDoc = snap.docs.last;
  //       final updatedBills = List<List<BillModel>>.from(state.bills);

  //       while (updatedBills.length <= pageZeroIndex) {
  //         updatedBills.add([]);
  //       }
  //       updatedBills[pageZeroIndex] = bills;

  //       int newTotalPages = state.totalPages;
  //       if (snap.docs.length == _pageSize) {
  //         newTotalPages = state.currentPage + 1;
  //       } else {
  //         newTotalPages = state.currentPage;
  //       }

  //       emit(state.copyWith(
  //         filteredBills: bills,
  //         lastFetchedDoc: newLastFetchedDoc,
  //         firstFetchedDoc: newFirstFetchedDoc,
  //         totalPages: newTotalPages,
  //         isLoading: false,
  //       ));
  //     }
  //   } else {
  //     // Previous page logic
  //     Query query = FBFireStore.bills.orderBy('createdAt', descending: false).limit(_pageSize);

  //     if (state.statusFilter != null) {
  //       query = FBFireStore.bills
  //           .where('status', isEqualTo: state.statusFilter)
  //           .orderBy('createdAt', descending: false)
  //           .limit(_pageSize);
  //     }

  //     if (state.firstFetchedDoc != null) {
  //       query = query.startAfterDocument(state.firstFetchedDoc!);
  //     }

  //     final snap = await query.get();

  //     if (snap.docs.isNotEmpty) {
  //       final bills = snap.docs.map((doc) => BillModel.fromDocSnap(doc as QueryDocumentSnapshot<Map<String, dynamic>>)).toList();
  //       bills.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  //       final newFirstFetchedDoc = snap.docs.last;
  //       final newLastFetchedDoc = snap.docs.first;

  //       emit(state.copyWith(
  //         filteredBills: bills,
  //         firstFetchedDoc: newFirstFetchedDoc,
  //         lastFetchedDoc: newLastFetchedDoc,
  //         isLoading: false,
  //       ));
  //     }
  //   }
  // }

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
    // initializeBillsPagination();
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
