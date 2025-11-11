part of 'bill_cubit.dart';

class BillState extends Equatable {
  final List<BillModel> filteredBills;
  final List<BillModel> searchedBills;
  final DocumentSnapshot? lastFetchedDoc;
  final DocumentSnapshot? firstFetchedDoc;
  final int currentPage;
  final int totalPages;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String? statusFilter;
  final String? dateRangeFilter;
  final Timestamp? startDate;
  final Timestamp? endDate;

  const BillState({
    required this.filteredBills,
    required this.searchedBills,
    this.lastFetchedDoc,
    this.firstFetchedDoc,
    required this.currentPage,
    required this.totalPages,
    required this.isLoading,
    this.error,
    required this.searchQuery,
    this.statusFilter,
    this.dateRangeFilter,
    this.startDate,
    this.endDate,
  });

  factory BillState.initial() {
    return const BillState(
      filteredBills: [],
      searchedBills: [],
      lastFetchedDoc: null,
      firstFetchedDoc: null,
      currentPage: 1,
      totalPages: 1,
      isLoading: false,
      error: null,
      searchQuery: '',
      statusFilter: 'All',
      dateRangeFilter: null,
      startDate: null,
      endDate: null,
    );
  }

  BillState copyWith({
    List<BillModel>? filteredBills,
    List<BillModel>? searchedBills,
    DocumentSnapshot? lastFetchedDoc,
    DocumentSnapshot? firstFetchedDoc,
    int? currentPage,
    int? totalPages,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? statusFilter,
    String? dateRangeFilter,
    Timestamp? startDate,
    Timestamp? endDate,
  }) {
    return BillState(
      filteredBills: filteredBills ?? this.filteredBills,
      searchedBills: searchedBills ?? this.searchedBills,
      lastFetchedDoc: lastFetchedDoc ?? this.lastFetchedDoc,
      firstFetchedDoc: firstFetchedDoc ?? this.firstFetchedDoc,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      dateRangeFilter: dateRangeFilter ?? this.dateRangeFilter,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [
    filteredBills,
    searchedBills,
    lastFetchedDoc,
    firstFetchedDoc,
    currentPage,
    totalPages,
    isLoading,
    error,
    searchQuery,
    statusFilter,
    dateRangeFilter,
    startDate,
    endDate,
  ];
}
