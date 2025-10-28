part of 'category_cubit.dart';

class CategoryState extends Equatable {
  final bool isLoading;
  final String? message;
  final List<CategoryModel> categories;

  const CategoryState({
    required this.isLoading,
    this.message,
    required this.categories,
  });

  factory CategoryState.initial() {
    return const CategoryState(isLoading: false, message: null, categories: []);
  }

  factory CategoryState.loading() {
    return const CategoryState(isLoading: true, message: null, categories: []);
  }

  factory CategoryState.loaded(List<CategoryModel> categories) {
    return CategoryState(
      isLoading: false,
      message: null,
      categories: categories,
    );
  }

  factory CategoryState.error(String message) {
    return CategoryState(
      isLoading: false,
      message: message,
      categories: const [],
    );
  }

  factory CategoryState.success(
    String message,
    List<CategoryModel> categories,
  ) {
    return CategoryState(
      isLoading: false,
      message: message,
      categories: categories,
    );
  }

  CategoryState copyWith({
    bool? isLoading,
    String? message,
    List<CategoryModel>? categories,
  }) {
    return CategoryState(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      categories: categories ?? this.categories,
    );
  }

  @override
  List<Object?> get props => [isLoading, message, categories];
}
