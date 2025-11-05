part of 'transaction_cubit.dart';

class TransactionState {
  final List<List<TransactionModel>> transactions;
  final List<TransactionModel> filteredTransactions;
  final int currentPage;
  final int totalPages;
  final DocumentSnapshot? lastFetchedDoc;
  final DocumentSnapshot? firstFetchedDoc;
  final bool isLoading;
  final String? message;
  final String searchQuery;
  final String? paymentModeFilter; // null = All, 'Cash', 'Card', 'UPI', etc.
  final String? dateRangeFilter; // null = All, 'LastMonth', 'Last3Months', 'Custom'
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  TransactionState({
    required this.transactions,
    required this.filteredTransactions,
    required this.currentPage,
    required this.totalPages,
    this.lastFetchedDoc,
    this.firstFetchedDoc,
    required this.isLoading,
    this.message,
    required this.searchQuery,
    this.paymentModeFilter,
    this.dateRangeFilter,
    this.customStartDate,
    this.customEndDate,
  });

  factory TransactionState.initial() {
    return TransactionState(
      transactions: [],
      filteredTransactions: [],
      currentPage: 1,
      totalPages: 1,
      lastFetchedDoc: null,
      firstFetchedDoc: null,
      isLoading: false,
      message: null,
      searchQuery: '',
      paymentModeFilter: null,
      dateRangeFilter: null,
      customStartDate: null,
      customEndDate: null,
    );
  }

  TransactionState copyWith({
    List<List<TransactionModel>>? transactions,
    List<TransactionModel>? filteredTransactions,
    int? currentPage,
    int? totalPages,
    DocumentSnapshot? lastFetchedDoc,
    DocumentSnapshot? firstFetchedDoc,
    bool? isLoading,
    String? message,
    String? searchQuery,
    String? paymentModeFilter,
    String? dateRangeFilter,
    DateTime? customStartDate,
    DateTime? customEndDate,
    bool clearPaymentModeFilter = false,
    bool clearDateRangeFilter = false,
    bool clearCustomDates = false,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      lastFetchedDoc: lastFetchedDoc ?? this.lastFetchedDoc,
      firstFetchedDoc: firstFetchedDoc ?? this.firstFetchedDoc,
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      searchQuery: searchQuery ?? this.searchQuery,
      paymentModeFilter: clearPaymentModeFilter ? null : (paymentModeFilter ?? this.paymentModeFilter),
      dateRangeFilter: clearDateRangeFilter ? null : (dateRangeFilter ?? this.dateRangeFilter),
      customStartDate: clearCustomDates ? null : (customStartDate ?? this.customStartDate),
      customEndDate: clearCustomDates ? null : (customEndDate ?? this.customEndDate),
    );
  }
}

