import 'package:billing_software/features/analytics/data/firebase_analytics_repo.dart';
import 'package:billing_software/features/analytics/domain/entity/monthly_sales_model.dart';
import 'package:billing_software/features/categories/domain/repositories/category_repository.dart';
import 'package:billing_software/features/products/data/firebase_product_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final FirebaseAnalyticsRepository _analyticsRepo;
  final FirebaseProductRepository _productRepo;
  final CategoryRepository _categoryRepo;

  AnalyticsCubit({
    required FirebaseAnalyticsRepository analyticsRepo,
    required FirebaseProductRepository productRepo,
    required CategoryRepository categoryRepo,
  }) : _analyticsRepo = analyticsRepo,
       _productRepo = productRepo,
       _categoryRepo = categoryRepo,
       super(AnalyticsState.initial());

  // Initialize and load current month data
  Future<void> initialize() async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      // Fetch available months and years
      final allMonths = await _analyticsRepo.getAllMonthsStream().first;
      final months = allMonths.map((m) => m.id).toList();
      final years = months.map((m) => m.split('-')[0]).toSet().toList()
        ..sort((a, b) => b.compareTo(a));

      // Fetch total products and categories count
      final productCount = await _productRepo.getProductCount();
      final categoryCount = await _categoryRepo.getCategoryCount();

      // Load current month data
      final now = DateTime.now();
      final currentMonth =
          "${now.year}-${now.month.toString().padLeft(2, '0')}";
      final salesData = await _analyticsRepo.getMonthlyAnalytics(currentMonth);

      emit(
        state.copyWith(
          isLoading: false,
          salesData: salesData ?? MonthlySalesModel.initial(currentMonth),
          totalProducts: productCount,
          totalCategories: categoryCount,
          availableMonths: months,
          availableYears: years,
          selectedPeriod: currentMonth,
        ),
      );
    } catch (e) {
      print(e.toString());
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: "Failed to load analytics: $e",
        ),
      );
    }
  }

  // Switch between monthly and yearly view
  Future<void> changeFilter(AnalyticsFilter filter) async {
    emit(state.copyWith(currentFilter: filter, isLoading: true));

    if (filter == AnalyticsFilter.monthly) {
      final now = DateTime.now();
      final currentMonth =
          "${now.year}-${now.month.toString().padLeft(2, '0')}";
      await loadMonthlyData(currentMonth);
    } else {
      final currentYear = DateTime.now().year.toString();
      await loadYearlyData(currentYear);
    }
  }

  // Load specific month data
  Future<void> loadMonthlyData(String monthKey) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      final salesData = await _analyticsRepo.getMonthlyAnalytics(monthKey);

      emit(
        state.copyWith(
          isLoading: false,
          salesData: salesData ?? MonthlySalesModel.initial(monthKey),
          selectedPeriod: monthKey,
          currentFilter: AnalyticsFilter.monthly,
        ),
      );
    } catch (e) {
      print(e.toString());

      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: "Failed to load month data: $e",
        ),
      );
    }
  }

  // Load yearly aggregated data
  Future<void> loadYearlyData(String year) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      final allMonths = await _analyticsRepo.getAllMonthsStream().first;
      final yearMonths = allMonths.where((m) => m.id.startsWith(year)).toList();

      if (yearMonths.isEmpty) {
        emit(
          state.copyWith(
            isLoading: false,
            salesData: MonthlySalesModel.initial(year),
            selectedPeriod: year,
            currentFilter: AnalyticsFilter.yearly,
          ),
        );
        return;
      }

      // Aggregate yearly data
      double totalSales = 0;
      double totalPaid = 0;
      double totalPending = 0;
      int totalBills = 0;
      int totalProductsSold = 0;

      for (var month in yearMonths) {
        totalSales += month.totalSales;
        totalPaid += month.totalPaid;
        totalPending += month.totalPending;
        totalBills += month.totalBills;
        totalProductsSold += month.totalProductsSold;
      }

      final yearData = MonthlySalesModel(
        id: year,
        totalSales: totalSales,
        totalPaid: totalPaid,
        totalPending: totalPending,
        totalBills: totalBills,
        totalProductsSold: totalProductsSold,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      emit(
        state.copyWith(
          isLoading: false,
          salesData: yearData,
          selectedPeriod: year,
          currentFilter: AnalyticsFilter.yearly,
        ),
      );
    } catch (e) {
      print(e.toString());

      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: "Failed to load year data: $e",
        ),
      );
    }
  }

  // Refresh current view
  Future<void> refresh() async {
    if (state.currentFilter == AnalyticsFilter.monthly) {
      await loadMonthlyData(state.selectedPeriod);
    } else {
      await loadYearlyData(state.selectedPeriod);
    }

    // Refresh products and categories count
    try {
      final productCount = await _productRepo.getProductCount();
      final categoryCount = await _categoryRepo.getCategoryCount();
      emit(
        state.copyWith(
          totalProducts: productCount,
          totalCategories: categoryCount,
        ),
      );
    } catch (e) {
      print(e.toString());

      // Silently fail for counts refresh
    }
  }
}
