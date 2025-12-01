import 'package:billing_software/features/purchase/domain/entity/purchase_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PurchaseState extends Equatable {
  final List<PurchaseModel> purchases;
  final List<PurchaseModel> filteredPurchases;
  final List<PurchaseModel> searchedPurchases;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  // Pagination
  final int currentPage;
  final int totalPages;
  final DocumentSnapshot? lastFetchedDoc;
  final DocumentSnapshot? firstFetchedDoc;

  // Filters
  final String searchQuery;
  final String
  dateFilter; // 'All', 'Today', 'This Week', 'This Month', 'Custom'
  final DateTime? startDate;
  final DateTime? endDate;

  const PurchaseState({
    this.purchases = const [],
    this.filteredPurchases = const [],
    this.searchedPurchases = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.currentPage = 1,
    this.totalPages = 1,
    this.lastFetchedDoc,
    this.firstFetchedDoc,
    this.searchQuery = '',
    this.dateFilter = 'All',
    this.startDate,
    this.endDate,
  });

  PurchaseState copyWith({
    List<PurchaseModel>? purchases,
    List<PurchaseModel>? filteredPurchases,
    List<PurchaseModel>? searchedPurchases,
    bool? isLoading,
    String? error,
    String? successMessage,
    int? currentPage,
    int? totalPages,
    DocumentSnapshot? lastFetchedDoc,
    DocumentSnapshot? firstFetchedDoc,
    String? searchQuery,
    String? dateFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return PurchaseState(
      purchases: purchases ?? this.purchases,
      filteredPurchases: filteredPurchases ?? this.filteredPurchases,
      searchedPurchases: searchedPurchases ?? this.searchedPurchases,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      lastFetchedDoc: lastFetchedDoc,
      firstFetchedDoc: firstFetchedDoc,
      searchQuery: searchQuery ?? this.searchQuery,
      dateFilter: dateFilter ?? this.dateFilter,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [
    purchases,
    filteredPurchases,
    searchedPurchases,
    isLoading,
    error,
    successMessage,
    currentPage,
    totalPages,
    lastFetchedDoc,
    firstFetchedDoc,
    searchQuery,
    dateFilter,
    startDate,
    endDate,
  ];
}
