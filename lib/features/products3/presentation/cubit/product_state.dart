part of 'product_cubit.dart';



class ProductState {
  // Products pagination
  final List<List<ProductModel>> products;
  final List<ProductModel> filteredProducts;
  final int currentPage;
  final int totalPages;
  final DocumentSnapshot? lastFetchedDoc;
  final DocumentSnapshot? firstFetchedDoc;

  // Common state
  final bool isLoading;
  final String? message;
  final String searchQuery;
  final String? selectedCategoryFilter; // null means "All Categories"

  ProductState({
    required this.products,
    required this.filteredProducts,
    required this.currentPage,
    required this.totalPages,
    this.lastFetchedDoc,
    this.firstFetchedDoc,
    required this.isLoading,
    this.message,
    required this.searchQuery,
    this.selectedCategoryFilter,
  });

  factory ProductState.initial() {
    return ProductState(
      products: [],
      filteredProducts: [],
      currentPage: 1,
      totalPages: 1,
      lastFetchedDoc: null,
      firstFetchedDoc: null,
      isLoading: false,
      message: null,
      searchQuery: '',
      selectedCategoryFilter: null,
    );
  }

  ProductState copyWith({
    List<List<ProductModel>>? products,
    List<ProductModel>? filteredProducts,
    int? currentPage,
    int? totalPages,
    DocumentSnapshot? lastFetchedDoc,
    DocumentSnapshot? firstFetchedDoc,
    bool? isLoading,
    String? message,
    String? searchQuery,
    String? selectedCategoryFilter,
    bool clearCategoryFilter = false,
  }) {
    return ProductState(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      lastFetchedDoc: lastFetchedDoc ?? this.lastFetchedDoc,
      firstFetchedDoc: firstFetchedDoc ?? this.firstFetchedDoc,
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryFilter: clearCategoryFilter ? null : (selectedCategoryFilter ?? this.selectedCategoryFilter),
    );
  }
}
