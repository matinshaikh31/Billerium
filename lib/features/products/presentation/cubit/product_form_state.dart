part of 'product_form_cubit.dart';

class ProductFormState extends Equatable {
  final bool isEditMode;
  final ProductModel? editingProduct;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  // Form fields
  final String name;
  final String categoryId;
  final String price;
  final String costPrice;
  final String discountPercent;
  final String taxPercent;
  final String sku;
  final String imageUrl;
  final String stockQty;

  const ProductFormState({
    required this.isEditMode,
    this.editingProduct,
    required this.isSubmitting,
    required this.isSuccess,
    this.errorMessage,
    required this.name,
    required this.categoryId,
    required this.price,
    required this.costPrice,
    required this.discountPercent,
    required this.taxPercent,
    required this.sku,
    required this.imageUrl,
    required this.stockQty,
  });

  factory ProductFormState.initial() {
    return const ProductFormState(
      isEditMode: false,
      editingProduct: null,
      isSubmitting: false,
      isSuccess: false,
      errorMessage: null,
      name: '',
      categoryId: '',
      price: '',
      costPrice: '',
      discountPercent: '',
      taxPercent: '0',
      sku: '',
      imageUrl: '',
      stockQty: '0',
    );
  }

  ProductFormState copyWith({
    bool? isEditMode,
    ProductModel? editingProduct,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    String? name,
    String? categoryId,
    String? price,
    String? costPrice,
    String? discountPercent,
    String? taxPercent,
    String? sku,
    String? imageUrl,
    String? stockQty,
  }) {
    return ProductFormState(
      isEditMode: isEditMode ?? this.isEditMode,
      editingProduct: editingProduct ?? this.editingProduct,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      discountPercent: discountPercent ?? this.discountPercent,
      taxPercent: taxPercent ?? this.taxPercent,
      sku: sku ?? this.sku,
      imageUrl: imageUrl ?? this.imageUrl,
      stockQty: stockQty ?? this.stockQty,
    );
  }

  @override
  List<Object?> get props => [
    isEditMode,
    editingProduct,
    isSubmitting,
    isSuccess,
    errorMessage,
    name,
    categoryId,
    price,
    costPrice,
    discountPercent,
    taxPercent,
    sku,
    imageUrl,
    stockQty,
  ];
}
