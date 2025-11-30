import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/features/products/domain/entity/product_model.dart';
import 'package:billing_software/features/products/domain/repositories/product_repository.dart';
import 'package:billing_software/features/products/presentation/cubit/product_import_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as excel;
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductImportCubit extends Cubit<ProductImportState> {
  final ProductRepository productRepository;

  ProductImportCubit({required this.productRepository})
    : super(ProductImportState.initial());

  PlatformFile? selectedFile;

  // Select Excel file
  Future<void> selectExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        selectedFile = result.files.first;
        emit(
          state.copyWith(
            selectedFileName: selectedFile!.name,
            errorMessage: null,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(errorMessage: 'Error selecting file: ${e.toString()}'),
      );
    }
  }

  // Import products from Excel
  Future<void> importProductsFromExcel(BuildContext context) async {
    if (selectedFile == null) {
      emit(state.copyWith(errorMessage: 'Please select an Excel file first'));
      return;
    }

    emit(state.copyWith(isImporting: true, errorMessage: null));

    try {
      List<ProductModel> productsToImport = [];
      final bytes = selectedFile!.bytes;

      if (bytes == null) {
        throw Exception('Failed to read file bytes');
      }

      final excelFile = excel.Excel.decodeBytes(bytes);

      int addedCount = 0;
      int updatedCount = 0;
      int skippedCount = 0;
      List<String> errors = [];

      for (var sheet in excelFile.tables.keys) {
        final table = excelFile.tables[sheet]!;

        // Skip header row (row 0), start from row 1
        for (var rowIndex = 1; rowIndex < table.maxRows; rowIndex++) {
          final row = table.rows[rowIndex];

          // Skip empty rows
          if (row.isEmpty || row[0]?.value == null) {
            skippedCount++;
            continue;
          }

          try {
            // Parse Excel row data
            // Headers: sku, product name, cat id, price, qty, discount, stock
            final sku = row[0]?.value?.toString().trim().toLowerCase();
            final productName = row[1]?.value?.toString().trim().toLowerCase();
            final categoryId = row[2]?.value?.toString().trim();
            final price =
                double.tryParse(row[3]?.value?.toString() ?? '0') ?? 0;
            final qty = int.tryParse(row[4]?.value?.toString() ?? '0') ?? 0;
            final discount = row[5]?.value != null
                ? double.tryParse(row[5]!.value.toString())
                : null;
            final stock = int.tryParse(row[6]?.value?.toString() ?? '0') ?? 0;

            // Validate required fields
            if (productName == null || productName.isEmpty) {
              errors.add('Row ${rowIndex + 1}: Product name is required');
              skippedCount++;
              continue;
            }

            if (categoryId == null || categoryId.isEmpty) {
              errors.add('Row ${rowIndex + 1}: Category ID is required');
              skippedCount++;
              continue;
            }

            if (price <= 0) {
              errors.add('Row ${rowIndex + 1}: Invalid price');
              skippedCount++;
              continue;
            }

            // Check if product with SKU exists
            ProductModel? existingProduct;

            if (sku != null && sku.isNotEmpty) {
              // Query by SKU
              final querySnapshot = await FBFireStore.products
                  .where('sku', isEqualTo: sku)
                  .limit(1)
                  .get();

              if (querySnapshot.docs.isNotEmpty) {
                existingProduct = ProductModel.fromJson(
                  querySnapshot.docs.first.data(),
                  querySnapshot.docs.first.id,
                );
              }
            }

            // If no SKU or product not found by SKU, check by name + categoryId
            if (existingProduct == null) {
              final queryByName = await FBFireStore.products
                  .where('name', isEqualTo: productName)
                  .where('categoryId', isEqualTo: categoryId)
                  .limit(1)
                  .get();

              if (queryByName.docs.isNotEmpty) {
                existingProduct = ProductModel.fromJson(
                  queryByName.docs.first.data(),
                  queryByName.docs.first.id,
                );
              }
            }

            if (existingProduct != null) {
              // UPDATE existing product
              final updatedProduct = ProductModel(
                id: existingProduct.id,
                name: productName,
                categoryId: categoryId,
                price: price,
                discountPercent: discount,
                sku: sku,
                stockQty: stock,
                qty: qty,
                createdAt: existingProduct.createdAt,
                updatedAt: Timestamp.now(),
              );

              await productRepository.updateProduct(updatedProduct);
              updatedCount++;
            } else {
              // CREATE new product
              final newProduct = ProductModel(
                id: '',
                name: productName,
                categoryId: categoryId,
                price: price,
                discountPercent: discount,
                sku: sku,
                stockQty: stock,
                qty: qty,
                createdAt: Timestamp.now(),
                updatedAt: Timestamp.now(),
              );

              await productRepository.createProduct(newProduct);
              addedCount++;
            }
          } catch (e) {
            errors.add('Row ${rowIndex + 1}: ${e.toString()}');
            skippedCount++;
          }
        }
      }

      // Build success message
      String resultMessage = 'Import completed!\n';
      resultMessage += 'Added: $addedCount\n';
      resultMessage += 'Updated: $updatedCount\n';
      if (skippedCount > 0) {
        resultMessage += 'Skipped: $skippedCount\n';
      }

      if (errors.isNotEmpty && errors.length <= 5) {
        resultMessage += '\nErrors:\n${errors.join('\n')}';
      } else if (errors.length > 5) {
        resultMessage += '\nErrors: ${errors.length} rows had errors';
      }

      emit(
        state.copyWith(
          isImporting: false,
          isSuccess: true,
          successMessage: resultMessage,
          addedCount: addedCount,
          updatedCount: updatedCount,
          skippedCount: skippedCount,
        ),
      );

      // Navigate back or refresh
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      emit(
        state.copyWith(
          isImporting: false,
          errorMessage: 'Failed to import products: ${e.toString()}',
        ),
      );
    }
  }

  void clearFile() {
    selectedFile = null;
    emit(ProductImportState.initial());
  }
}
