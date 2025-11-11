part of 'transaction_cubit.dart';

class TransactionState extends Equatable {
  final List<TransactionModel> filteredTransactions;
  final List<TransactionModel> searchedTransactions;
  final DocumentSnapshot? lastFetchedDoc;
  final DocumentSnapshot? firstFetchedDoc;
  final int currentPage;
  final int totalPages;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String? dateRangeFilter;
  final Timestamp? startDate;
  final Timestamp? endDate;

  const TransactionState({
    required this.filteredTransactions,
    required this.searchedTransactions,
    this.lastFetchedDoc,
    this.firstFetchedDoc,
    required this.currentPage,
    required this.totalPages,
    required this.isLoading,
    this.error,
    required this.searchQuery,
    this.dateRangeFilter,
    this.startDate,
    this.endDate,
  });

  factory TransactionState.initial() {
    return const TransactionState(
      filteredTransactions: [],
      searchedTransactions: [],
      lastFetchedDoc: null,
      firstFetchedDoc: null,
      currentPage: 1,
      totalPages: 1,
      isLoading: false,
      error: null,
      searchQuery: '',
      dateRangeFilter: null,
      startDate: null,
      endDate: null,
    );
  }

  TransactionState copyWith({
    List<TransactionModel>? filteredTransactions,
    List<TransactionModel>? searchedTransactions,
    DocumentSnapshot? lastFetchedDoc,
    DocumentSnapshot? firstFetchedDoc,
    int? currentPage,
    int? totalPages,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? dateRangeFilter,
    Timestamp? startDate,
    Timestamp? endDate,
  }) {
    return TransactionState(
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      searchedTransactions: searchedTransactions ?? this.searchedTransactions,
      lastFetchedDoc: lastFetchedDoc ?? this.lastFetchedDoc,
      firstFetchedDoc: firstFetchedDoc ?? this.firstFetchedDoc,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      dateRangeFilter: dateRangeFilter ?? this.dateRangeFilter,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [
    filteredTransactions,
    searchedTransactions,
    lastFetchedDoc,
    firstFetchedDoc,
    currentPage,
    totalPages,
    isLoading,
    error,
    searchQuery,
    dateRangeFilter,
    startDate,
    endDate,
  ];
}
