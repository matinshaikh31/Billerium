part of 'product_cubit.dart';

class ProductState extends Equatable {
  final bool isLoading;
  final String? message;
  final List<ProductModel> products;

  const ProductState({
    required this.isLoading,
    this.message,
    required this.products,
  });

  factory ProductState.initial() {
    return const ProductState(isLoading: false, message: null, products: []);
  }

  factory ProductState.loading() {
    return const ProductState(isLoading: true, message: null, products: []);
  }

  factory ProductState.loaded(List<ProductModel> products) {
    return ProductState(isLoading: false, message: null, products: products);
  }

  factory ProductState.error(String message) {
    return ProductState(isLoading: false, message: message, products: const []);
  }

  factory ProductState.success(String message, List<ProductModel> products) {
    return ProductState(isLoading: false, message: message, products: products);
  }

  ProductState copyWith({
    bool? isLoading,
    String? message,
    List<ProductModel>? products,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      products: products ?? this.products,
    );
  }

  @override
  List<Object?> get props => [isLoading, message, products];
}
