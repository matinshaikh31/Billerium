part of 'product_cubit.dart';

class ProductState extends Equatable {
  final List<ProductModel> filteredProducts;
  final List<ProductModel> searchedProducts;
  final DocumentSnapshot? lastFetchedDoc;
  final DocumentSnapshot? firstFetchedDoc;
  final int currentPage;
  final int totalPages;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String selectedCategory;
  final Map<String, dynamic>? productStats;

  const ProductState({
    required this.filteredProducts,
    required this.searchedProducts,
    this.lastFetchedDoc,
    this.firstFetchedDoc,
    required this.currentPage,
    required this.totalPages,
    required this.isLoading,
    this.error,
    required this.searchQuery,
    required this.selectedCategory,
    this.productStats,
  });

  factory ProductState.initial() {
    return const ProductState(
      filteredProducts: [],
      searchedProducts: [],
      lastFetchedDoc: null,
      firstFetchedDoc: null,
      currentPage: 1,
      totalPages: 1,
      isLoading: false,
      error: null,
      searchQuery: '',
      selectedCategory: 'All',
      productStats: null,
    );
  }

  ProductState copyWith({
    List<ProductModel>? filteredProducts,
    List<ProductModel>? searchedProducts,
    DocumentSnapshot? lastFetchedDoc,
    DocumentSnapshot? firstFetchedDoc,
    int? currentPage,
    int? totalPages,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? selectedCategory,
    Map<String, dynamic>? productStats,
  }) {
    return ProductState(
      filteredProducts: filteredProducts ?? this.filteredProducts,
      searchedProducts: searchedProducts ?? this.searchedProducts,
      lastFetchedDoc: lastFetchedDoc ?? this.lastFetchedDoc,
      firstFetchedDoc: firstFetchedDoc ?? this.firstFetchedDoc,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      productStats: productStats ?? this.productStats,
    );
  }

  @override
  List<Object?> get props => [
    filteredProducts,
    searchedProducts,
    lastFetchedDoc,
    firstFetchedDoc,
    currentPage,
    totalPages,
    isLoading,
    error,
    searchQuery,
    selectedCategory,
    productStats,
  ];
}
