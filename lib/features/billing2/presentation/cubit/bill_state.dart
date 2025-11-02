
part of 'bill_cubit.dart';

class BillState {
  final List<List<BillModel>> bills;
  final List<BillModel> filteredBills;
  final int currentPage;
  final int totalPages;
  final DocumentSnapshot? lastFetchedDoc;
  final DocumentSnapshot? firstFetchedDoc;
  final bool isLoading;
  final String? message;
  final String searchQuery;
  final String? statusFilter; // null = All, 'Paid', 'PartiallyPaid', 'Unpaid'

  BillState({
    required this.bills,
    required this.filteredBills,
    required this.currentPage,
    required this.totalPages,
    this.lastFetchedDoc,
    this.firstFetchedDoc,
    required this.isLoading,
    this.message,
    required this.searchQuery,
    this.statusFilter,
  });

  factory BillState.initial() {
    return BillState(
      bills: [],
      filteredBills: [],
      currentPage: 1,
      totalPages: 1,
      lastFetchedDoc: null,
      firstFetchedDoc: null,
      isLoading: false,
      message: null,
      searchQuery: '',
      statusFilter: null,
    );
  }

  BillState copyWith({
    List<List<BillModel>>? bills,
    List<BillModel>? filteredBills,
    int? currentPage,
    int? totalPages,
    DocumentSnapshot? lastFetchedDoc,
    DocumentSnapshot? firstFetchedDoc,
    bool? isLoading,
    String? message,
    String? searchQuery,
    String? statusFilter,
    bool clearStatusFilter = false,
  }) {
    return BillState(
      bills: bills ?? this.bills,
      filteredBills: filteredBills ?? this.filteredBills,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      lastFetchedDoc: lastFetchedDoc ?? this.lastFetchedDoc,
      firstFetchedDoc: firstFetchedDoc ?? this.firstFetchedDoc,
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
    );
  }
}

