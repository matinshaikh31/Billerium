import 'dart:async';
import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/features/customer/domain/entity/customer_model.dart';
import 'package:billing_software/features/customer/domain/repo/customer_repository.dart';
import 'package:billing_software/features/customer/presentation/cubit/customer_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerRepository customerRepository;
  final TextEditingController searchController = TextEditingController();
  final int _pageSize = 10;
  Timer? debounce;

  CustomerCubit({required this.customerRepository})
    : super(CustomerState.initial());

  @override
  Future<void> close() {
    debounce?.cancel();
    searchController.dispose();
    return super.close();
  }

  /// Initialize customers pagination - load first page
  Future<void> initializePagination() async {
    searchController.clear();

    emit(
      state.copyWith(
        isLoading: true,
        customers: [],
        lastFetchedDoc: null,
        firstFetchedDoc: null,
        searchedCustomers: [],
        currentPage: 1,
        totalPages: 1,
        error: null,
        searchQuery: '',
      ),
    );

    final totalPages = (await getTotalCustomersCount() / _pageSize).ceil();

    try {
      Query query = _buildBaseQuery(null).limit(_pageSize);

      final snap = await query.get();
      if (snap.docs.isNotEmpty) {
        final customers = snap.docs
            .map(
              (doc) => CustomerModel.fromDocSnap(
                doc as QueryDocumentSnapshot<Map<String, dynamic>>,
              ),
            )
            .toList();

        final newLastFetchedDoc = snap.docs.last;
        final newFirstFetchedDoc = snap.docs.first;

        emit(
          state.copyWith(
            customers: customers,
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

  /// Build base query with filters
  Query _buildBaseQuery(bool? isNext) {
    Query query;

    if (isNext == null) {
      query = FBFireStore.customers.orderBy('createdAt', descending: true);
    } else if (isNext) {
      query = FBFireStore.customers.orderBy('createdAt', descending: true);
    } else {
      query = FBFireStore.customers.orderBy('createdAt', descending: false);
    }

    return query;
  }

  /// Get total customers count
  Future<int> getTotalCustomersCount() async {
    try {
      final snapshot = await FBFireStore.customers.get();
      return snapshot.size;
    } catch (e) {
      return 0;
    }
  }

  /// Navigate to a specific page
  Future<void> goToPage(int page, {bool isNextPage = true}) async {
    if (state.isLoading || page < 1 || page > state.totalPages) return;

    emit(state.copyWith(isLoading: true, currentPage: page));

    try {
      if (page == 1) {
        emit(state.copyWith(lastFetchedDoc: null, firstFetchedDoc: null));

        Query query = _buildBaseQuery(null).limit(_pageSize);

        final snap = await query.get();
        if (snap.docs.isNotEmpty) {
          final customers = snap.docs
              .map(
                (doc) => CustomerModel.fromDocSnap(
                  doc as QueryDocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList();

          final newLastFetchedDoc = snap.docs.last;
          final newFirstFetchedDoc = snap.docs.first;

          emit(
            state.copyWith(
              customers: customers,
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
          final customers = snap.docs
              .map(
                (doc) => CustomerModel.fromDocSnap(
                  doc as QueryDocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList();

          final newLastFetchedDoc = snap.docs.last;
          final newFirstFetchedDoc = snap.docs.first;

          emit(
            state.copyWith(
              customers: customers,
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
        Query query = _buildBaseQuery(
          false,
        ).limit(_pageSize).endBeforeDocument(state.firstFetchedDoc!);

        final snap = await query.get();

        if (snap.docs.isNotEmpty) {
          final customers = snap.docs
              .map(
                (doc) => CustomerModel.fromDocSnap(
                  doc as QueryDocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList();

          // Reverse the cursor documents for previous page
          final newFirstFetchedDoc = snap.docs.last;
          final newLastFetchedDoc = snap.docs.first;

          // Sort customers in descending order (newest first)
          customers.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          emit(
            state.copyWith(
              customers: customers,
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
      emit(state.copyWith(isLoading: false, error: 'Failed to navigate: $e'));
    }
  }

  /// Search customers by name or phone
  void searchCustomers(String query) {
    debounce?.cancel();

    if (query.isEmpty) {
      emit(state.copyWith(searchQuery: '', searchedCustomers: []));
      return;
    }

    debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        emit(state.copyWith(isLoading: true, searchQuery: query));

        final customers = await customerRepository.searchCustomers(query);

        emit(state.copyWith(searchedCustomers: customers, isLoading: false));
      } catch (e) {
        emit(
          state.copyWith(
            isLoading: false,
            error: 'Failed to search customers: ${e.toString()}',
          ),
        );
      }
    });
  }

  /// Get displayed customers (search results or current page)
  List<CustomerModel> get displayedCustomers {
    return state.searchQuery.isEmpty
        ? state.customers
        : state.searchedCustomers;
  }

  /// Create a new customer
  Future<void> createCustomer(CustomerModel customer) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await customerRepository.createCustomer(customer);

      emit(
        state.copyWith(
          isLoading: false,
          successMessage: 'Customer created successfully',
        ),
      );

      // Refresh the list
      await initializePagination();
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to create customer: ${e.toString()}',
        ),
      );
    }
  }

  /// Update an existing customer
  Future<void> updateCustomer(CustomerModel customer) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await customerRepository.updateCustomer(customer);

      emit(
        state.copyWith(
          isLoading: false,
          successMessage: 'Customer updated successfully',
        ),
      );

      // Refresh the list
      if (state.searchQuery.isNotEmpty) {
        searchCustomers(state.searchQuery);
      } else {
        await initializePagination();
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to update customer: ${e.toString()}',
        ),
      );
    }
  }

  /// Delete a customer
  Future<void> deleteCustomer(String id) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await customerRepository.deleteCustomer(id);

      emit(
        state.copyWith(
          isLoading: false,
          successMessage: 'Customer deleted successfully',
        ),
      );

      // Refresh the list
      if (state.searchQuery.isNotEmpty) {
        searchCustomers(state.searchQuery);
      } else {
        await initializePagination();
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to delete customer: ${e.toString()}',
        ),
      );
    }
  }

  /// Update customer balance
  Future<void> updateCustomerBalance(String customerId, double amount) async {
    try {
      await customerRepository.updateBalance(customerId, amount);

      // Refresh the list to show updated balance
      if (state.searchQuery.isNotEmpty) {
        searchCustomers(state.searchQuery);
      } else {
        await initializePagination();
      }
    } catch (e) {
      emit(state.copyWith(error: 'Failed to update balance: ${e.toString()}'));
    }
  }

  /// Clear success/error messages
  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }
}
