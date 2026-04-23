import 'package:billing_software/features/customer/domain/entity/customer_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CustomerState extends Equatable {
  final List<CustomerModel> customers;
  final List<CustomerModel> searchedCustomers;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final DocumentSnapshot? lastFetchedDoc;
  final DocumentSnapshot? firstFetchedDoc;
  final String? error;
  final String? successMessage;
  final String searchQuery;

  const CustomerState({
    this.customers = const [],
    this.searchedCustomers = const [],
    this.isLoading = false,
    this.currentPage = 1,
    this.totalPages = 1,
    this.lastFetchedDoc,
    this.firstFetchedDoc,
    this.error,
    this.successMessage,
    this.searchQuery = '',
  });

  factory CustomerState.initial() {
    return const CustomerState();
  }

  CustomerState copyWith({
    List<CustomerModel>? customers,
    List<CustomerModel>? searchedCustomers,
    bool? isLoading,
    int? currentPage,
    int? totalPages,
    DocumentSnapshot? lastFetchedDoc,
    DocumentSnapshot? firstFetchedDoc,
    String? error,
    String? successMessage,
    String? searchQuery,
    bool clearMessages = false,
  }) {
    return CustomerState(
      customers: customers ?? this.customers,
      searchedCustomers: searchedCustomers ?? this.searchedCustomers,
      isLoading: isLoading ?? this.isLoading,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      lastFetchedDoc: lastFetchedDoc ?? this.lastFetchedDoc,
      firstFetchedDoc: firstFetchedDoc ?? this.firstFetchedDoc,
      error: clearMessages ? null : error,
      successMessage: clearMessages ? null : successMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    customers,
    searchedCustomers,
    isLoading,
    currentPage,
    totalPages,
    lastFetchedDoc,
    firstFetchedDoc,
    error,
    successMessage,
    searchQuery,
  ];
}
