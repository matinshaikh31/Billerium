part of 'analytics_cubit.dart';

enum AnalyticsFilter { monthly, yearly }

class AnalyticsState {
  final bool isLoading;
  final MonthlySalesModel? salesData;
  final int totalProducts;
  final int totalCategories;
  final AnalyticsFilter currentFilter;
  final String selectedPeriod; // e.g., "2025-10" or "2025"
  final String? errorMessage;
  final List<String> availableMonths;
  final List<String> availableYears;

  const AnalyticsState({
    required this.isLoading,
    this.salesData,
    required this.totalProducts,
    required this.totalCategories,
    required this.currentFilter,
    required this.selectedPeriod,
    this.errorMessage,
    required this.availableMonths,
    required this.availableYears,
  });

  // Initial state
  factory AnalyticsState.initial() {
    final now = DateTime.now();
    final currentMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    return AnalyticsState(
      isLoading: true,
      salesData: null,
      totalProducts: 0,
      totalCategories: 0,
      currentFilter: AnalyticsFilter.monthly,
      selectedPeriod: currentMonth,
      errorMessage: null,
      availableMonths: [],
      availableYears: [],
    );
  }

  // Copy with method
  AnalyticsState copyWith({
    bool? isLoading,
    MonthlySalesModel? salesData,
    int? totalProducts,
    int? totalCategories,
    AnalyticsFilter? currentFilter,
    String? selectedPeriod,
    String? errorMessage,
    List<String>? availableMonths,
    List<String>? availableYears,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      salesData: salesData ?? this.salesData,
      totalProducts: totalProducts ?? this.totalProducts,
      totalCategories: totalCategories ?? this.totalCategories,
      currentFilter: currentFilter ?? this.currentFilter,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      errorMessage: errorMessage,
      availableMonths: availableMonths ?? this.availableMonths,
      availableYears: availableYears ?? this.availableYears,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    salesData,
    totalProducts,
    totalCategories,
    currentFilter,
    selectedPeriod,
    errorMessage,
    availableMonths,
    availableYears,
  ];
}
