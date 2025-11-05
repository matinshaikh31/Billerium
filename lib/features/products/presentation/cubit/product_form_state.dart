part of 'product_form_cubit.dart';

class ProductFormState {
  final bool isLoading;
  final String? message;

  ProductFormState({required this.isLoading, this.message});

  factory ProductFormState.initial() {
    return ProductFormState(isLoading: false, message: null);
  }

  ProductFormState copyWith({bool? isLoading, String? message}) {
    return ProductFormState(
      isLoading: isLoading ?? this.isLoading,
      message: message,
    );
  }
}
