// State class
class ProductImportState {
  final bool isImporting;
  final bool isSuccess;
  final String? selectedFileName;
  final String? errorMessage;
  final String? successMessage;
  final int addedCount;
  final int updatedCount;
  final int skippedCount;

  ProductImportState({
    required this.isImporting,
    required this.isSuccess,
    this.selectedFileName,
    this.errorMessage,
    this.successMessage,
    this.addedCount = 0,
    this.updatedCount = 0,
    this.skippedCount = 0,
  });

  factory ProductImportState.initial() {
    return ProductImportState(
      isImporting: false,
      isSuccess: false,
      selectedFileName: null,
      errorMessage: null,
      successMessage: null,
      addedCount: 0,
      updatedCount: 0,
      skippedCount: 0,
    );
  }

  ProductImportState copyWith({
    bool? isImporting,
    bool? isSuccess,
    String? selectedFileName,
    String? errorMessage,
    String? successMessage,
    int? addedCount,
    int? updatedCount,
    int? skippedCount,
  }) {
    return ProductImportState(
      isImporting: isImporting ?? this.isImporting,
      isSuccess: isSuccess ?? this.isSuccess,
      selectedFileName: selectedFileName ?? this.selectedFileName,
      errorMessage: errorMessage,
      successMessage: successMessage,
      addedCount: addedCount ?? this.addedCount,
      updatedCount: updatedCount ?? this.updatedCount,
      skippedCount: skippedCount ?? this.skippedCount,
    );
  }
}
