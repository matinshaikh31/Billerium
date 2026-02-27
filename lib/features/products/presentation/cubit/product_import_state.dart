class ProductImportState {
  final bool isImporting;
  final bool isExporting; // NEW
  final bool isSuccess;
  final String? selectedFileName;
  final String? errorMessage;
  final String? successMessage;
  final int addedCount;
  final int updatedCount;
  final int skippedCount;

  ProductImportState({
    required this.isImporting,
    required this.isExporting,
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
      isExporting: false,
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
    bool? isExporting,
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
      isExporting: isExporting ?? this.isExporting,
      isSuccess: isSuccess ?? this.isSuccess,
      selectedFileName: selectedFileName ?? this.selectedFileName,
      // Intentionally not using ?? so callers can explicitly clear these
      errorMessage: errorMessage,
      successMessage: successMessage,
      addedCount: addedCount ?? this.addedCount,
      updatedCount: updatedCount ?? this.updatedCount,
      skippedCount: skippedCount ?? this.skippedCount,
    );
  }
}
