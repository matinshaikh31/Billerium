part of 'product_cubit.dart';

class ProductState extends Equatable {
  final bool isLoading;
  final String? message;
  final List<ProductModel> products;
  final List<ProductModel> filteredProducts;
  final String searchQuery;
  final String selectedCategory;

  const ProductState({
    required this.isLoading,
    this.message,
    required this.products,
    required this.filteredProducts,
    required this.searchQuery,
    required this.selectedCategory,
  });

  factory ProductState.initial() {
    return const ProductState(
      isLoading: false,
      message: null,
      products: [],
      filteredProducts: [],
      searchQuery: '',
      selectedCategory: 'All Categories',
    );
  }

  factory ProductState.loading() {
    return const ProductState(
      isLoading: true,
      message: null,
      products: [],
      filteredProducts: [],
      searchQuery: '',
      selectedCategory: 'All Categories',
    );
  }

  factory ProductState.loaded(List<ProductModel> products) {
    return ProductState(
      isLoading: false,
      message: null,
      products: products,
      filteredProducts: products,
      searchQuery: '',
      selectedCategory: 'All Categories',
    );
  }

  factory ProductState.error(String message) {
    return ProductState(
      isLoading: false,
      message: message,
      products: const [],
      filteredProducts: const [],
      searchQuery: '',
      selectedCategory: 'All Categories',
    );
  }

  factory ProductState.success(String message, List<ProductModel> products) {
    return ProductState(
      isLoading: false,
      message: message,
      products: products,
      filteredProducts: products,
      searchQuery: '',
      selectedCategory: 'All Categories',
    );
  }

  ProductState copyWith({
    bool? isLoading,
    String? message,
    List<ProductModel>? products,
    List<ProductModel>? filteredProducts,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      message: message,
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    message,
    products,
    filteredProducts,
    searchQuery,
    selectedCategory,
  ];
}
