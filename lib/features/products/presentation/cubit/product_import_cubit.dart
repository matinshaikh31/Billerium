import 'dart:typed_data';

import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/features/categories/domain/antity/category_model.dart';
import 'package:billing_software/features/products/domain/entity/product_model.dart';
import 'package:billing_software/features/products/domain/repositories/product_repository.dart';
import 'package:billing_software/features/products/presentation/cubit/product_import_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as excel;
import 'package:flutter_bloc/flutter_bloc.dart';

/// Batch size for Firestore writes — keep ≤ 500 (Firestore hard limit)
const int _kBatchSize = 400;

class ProductImportExportCubit extends Cubit<ProductImportState> {
  final ProductRepository productRepository;

  ProductImportExportCubit({required this.productRepository})
    : super(ProductImportState.initial());

  PlatformFile? selectedFile;

  // ─────────────────────────────────────────────────────────────────────────
  // CATEGORY HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  /// Fetches all categories from Firestore.
  Future<List<CategoryModel>> _fetchAllCategories() async {
    final snap = await FBFireStore.categories.get();
    return snap.docs
        .map(
          (d) => CategoryModel.fromJson(d.data() as Map<String, dynamic>, d.id),
        )
        .toList();
  }

  /// Returns the category ID for [categoryName].
  ///
  /// Lookup is case-insensitive.  If no matching category exists, a new one
  /// is created and its ID is returned.  [categoryCache] is updated in-place
  /// so we don't hit Firestore for the same name twice.
  Future<String> _resolveCategoryId(
    String categoryName,
    Map<String, String> categoryCache, // key = lowercased name, value = id
  ) async {
    final key = categoryName.trim().toLowerCase();

    if (categoryCache.containsKey(key)) {
      return categoryCache[key]!;
    }

    // Not in cache — create a new category
    final now = Timestamp.now();
    final newCat = CategoryModel(
      id: '',
      name: categoryName.trim(),
      defaultDiscountPercent: 0,
      createdAt: now,
      updatedAt: now,
    );

    final docRef = FBFireStore.categories.doc();
    await docRef.set({...newCat.toJson(), 'createdAt': now, 'updatedAt': now});

    categoryCache[key] = docRef.id;
    return docRef.id;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SELECT FILE
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> selectExcelFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
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

  // ─────────────────────────────────────────────────────────────────────────
  // IMPORT  (batch writes + category-name resolution)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> importProductsFromExcel(BuildContext context) async {
    if (selectedFile == null) {
      emit(state.copyWith(errorMessage: 'Please select an Excel file first'));
      return;
    }

    emit(state.copyWith(isImporting: true, errorMessage: null));

    try {
      final bytes = selectedFile!.bytes;
      if (bytes == null) throw Exception('Failed to read file bytes');

      // Pre-load all categories and build a name→id cache
      final existingCategories = await _fetchAllCategories();
      final Map<String, String> categoryCache = {
        for (final c in existingCategories) c.name.trim().toLowerCase(): c.id,
      };

      final excelFile = excel.Excel.decodeBytes(bytes);

      int addedCount = 0;
      int updatedCount = 0;
      int skippedCount = 0;
      final List<String> errors = [];

      // We collect create/update operations and flush in batches
      // For updates we need the doc ID, so we store them separately.
      WriteBatch createBatch = FBFireStore.fb.batch();
      int createBatchCount = 0;

      // Updates must be done via batch too
      WriteBatch updateBatch = FBFireStore.fb.batch();
      int updateBatchCount = 0;

      Future<void> flushCreateBatch() async {
        if (createBatchCount > 0) {
          await createBatch.commit();
          createBatch = FBFireStore.fb.batch();
          createBatchCount = 0;
        }
      }

      Future<void> flushUpdateBatch() async {
        if (updateBatchCount > 0) {
          await updateBatch.commit();
          updateBatch = FBFireStore.fb.batch();
          updateBatchCount = 0;
        }
      }

      for (final sheetName in excelFile.tables.keys) {
        final table = excelFile.tables[sheetName]!;

        for (var rowIndex = 1; rowIndex < table.maxRows; rowIndex++) {
          final row = table.rows[rowIndex];

          if (row.isEmpty || row[0]?.value == null) {
            skippedCount++;
            continue;
          }

          try {
            // ── Parse columns ──────────────────────────────────────────────
            // Expected headers (col 0-6):
            // sku | product name | category name | price | qty | discount | stock
            final sku = row[0]?.value?.toString().trim().toLowerCase();
            final productName = row[1]?.value?.toString().trim().toLowerCase();
            final categoryName = row[2]?.value?.toString().trim();
            final price =
                double.tryParse(row[3]?.value?.toString() ?? '0') ?? 0;
            final qty = int.tryParse(row[4]?.value?.toString() ?? '0') ?? 0;
            final discount = row[5]?.value != null
                ? double.tryParse(row[5]!.value.toString())
                : null;
            final stock = int.tryParse(row[6]?.value?.toString() ?? '0') ?? 0;

            // ── Validate ───────────────────────────────────────────────────
            if (productName == null || productName.isEmpty) {
              errors.add('Row ${rowIndex + 1}: Product name is required');
              skippedCount++;
              continue;
            }
            if (categoryName == null || categoryName.isEmpty) {
              errors.add('Row ${rowIndex + 1}: Category name is required');
              skippedCount++;
              continue;
            }
            if (price <= 0) {
              errors.add('Row ${rowIndex + 1}: Invalid price');
              skippedCount++;
              continue;
            }

            // ── Resolve category ID ────────────────────────────────────────
            final categoryId = await _resolveCategoryId(
              categoryName,
              categoryCache,
            );

            // ── Check if product already exists (by SKU) ───────────────────
            ProductModel? existingProduct;
            if (sku != null && sku.isNotEmpty) {
              final snap = await FBFireStore.products
                  .where('sku', isEqualTo: sku)
                  .limit(1)
                  .get();
              if (snap.docs.isNotEmpty) {
                existingProduct = ProductModel.fromJson(
                  snap.docs.first.data(),
                  snap.docs.first.id,
                );
              }
            }

            final now = Timestamp.now();

            if (existingProduct != null) {
              // ── UPDATE ────────────────────────────────────────────────────
              final updated = ProductModel(
                id: existingProduct.id,
                name: productName,
                categoryId: categoryId,
                price: price,
                discountPercent: discount,
                sku: sku,
                stockQty: stock,
                qty: qty,
                createdAt: existingProduct.createdAt,
                updatedAt: now,
              );
              updateBatch.update(
                FBFireStore.products.doc(existingProduct.id),
                updated.toJson(),
              );
              updateBatchCount++;
              updatedCount++;

              if (updateBatchCount >= _kBatchSize) await flushUpdateBatch();
            } else {
              // ── CREATE ────────────────────────────────────────────────────
              final newDocRef = FBFireStore.products.doc();
              final newProduct = ProductModel(
                id: newDocRef.id,
                name: productName,
                categoryId: categoryId,
                price: price,
                discountPercent: discount,
                sku: sku,
                stockQty: stock,
                qty: qty,
                createdAt: now,
                updatedAt: now,
              );
              createBatch.set(newDocRef, newProduct.toJson());
              createBatchCount++;
              addedCount++;

              if (createBatchCount >= _kBatchSize) await flushCreateBatch();
            }
          } catch (e) {
            errors.add('Row ${rowIndex + 1}: ${e.toString()}');
            skippedCount++;
          }
        }
      }

      // Flush any remaining items
      await flushCreateBatch();
      await flushUpdateBatch();

      // ── Build result message ───────────────────────────────────────────────
      String resultMessage =
          'Import completed!\n'
          'Added: $addedCount\n'
          'Updated: $updatedCount\n';
      if (skippedCount > 0) resultMessage += 'Skipped: $skippedCount\n';
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

      if (context.mounted) Navigator.of(context).pop(true);
    } catch (e) {
      emit(
        state.copyWith(
          isImporting: false,
          errorMessage: 'Failed to import products: ${e.toString()}',
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // EXPORT  (all products → Excel with category names)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> exportProductsToExcel(BuildContext context) async {
    emit(state.copyWith(isExporting: true, errorMessage: null));

    try {
      // Fetch all products and categories in parallel
      final results = await Future.wait([
        FBFireStore.products.get(),
        _fetchAllCategories(),
      ]);

      final productSnap = results[0] as QuerySnapshot<Map<String, dynamic>>;
      final categories = results[1] as List<CategoryModel>;
      final catMap = {for (final c in categories) c.id: c.name};

      final products = productSnap.docs
          .map((d) => ProductModel.fromJson(d.data(), d.id))
          .toList();

      // Group products by category name, categories sorted A→Z,
      // products within each category sorted A→Z by name
      final Map<String, List<ProductModel>> grouped = {};
      for (final p in products) {
        final catName = catMap[p.categoryId] ?? 'Uncategorized';
        grouped.putIfAbsent(catName, () => []).add(p);
      }
      final sortedCatNames = grouped.keys.toList()..sort();

      // Build Excel
      final excelFile = excel.Excel.createExcel();
      final sheet = excelFile['Products'];

      // Header row
      final headers = [
        'SKU',
        'Product Name',
        'Category Name',
        'Price',
        'Qty',
        'Discount %',
        'Stock',
        'Last Purchase Price',
        'Average Purchase Price',
      ];
      sheet.appendRow(headers.map((h) => excel.TextCellValue(h)).toList());

      // Data rows — one category block at a time
      for (final catName in sortedCatNames) {
        final catProducts = grouped[catName]!
          ..sort((a, b) => a.name.compareTo(b.name));

        for (final p in catProducts) {
          sheet.appendRow([
            excel.TextCellValue(p.sku ?? ''),
            excel.TextCellValue(p.name),
            excel.TextCellValue(catName),
            excel.DoubleCellValue(p.price),
            excel.IntCellValue(p.qty),
            if (p.discountPercent != null)
              excel.DoubleCellValue(p.discountPercent!)
            else
              excel.TextCellValue(''),
            excel.IntCellValue(p.stockQty),
            if (p.lastPurchasePrice != null)
              excel.DoubleCellValue(p.lastPurchasePrice!)
            else
              excel.TextCellValue(''),
            if (p.averagePurchasePrice != null)
              excel.DoubleCellValue(p.averagePurchasePrice!)
            else
              excel.TextCellValue(''),
          ]);
        }
      }

      await _saveAndShareExcel(excelFile, 'products_export.xlsx');

      emit(
        state.copyWith(
          isExporting: false,
          isSuccess: true,
          successMessage: 'Exported ${products.length} products successfully!',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isExporting: false,
          errorMessage: 'Failed to export products: ${e.toString()}',
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DOWNLOAD SAMPLE EXCEL
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> downloadSampleExcel() async {
    emit(state.copyWith(isExporting: true, errorMessage: null));

    try {
      final excelFile = excel.Excel.createExcel();
      final sheet = excelFile['Products'];

      // Header
      final headers = [
        'SKU',
        'Product Name',
        'Category Name',
        'Price',
        'Qty',
        'Discount %',
        'Stock',
      ];
      sheet.appendRow(headers.map((h) => excel.TextCellValue(h)).toList());

      // Sample rows
      final sampleRows = [
        ['SKU001', 'Sample Product 1', 'Electronics', 999.99, 10, 5.0, 50],
        ['SKU002', 'Sample Product 2', 'Clothing', 499.00, 20, '', 100],
        ['SKU003', 'Sample Product 3', 'Electronics', 1499.00, 5, 10.0, 30],
        ['', 'Product Without SKU', 'New Category', 299.00, 0, '', 200],
      ];

      for (final row in sampleRows) {
        sheet.appendRow(
          row.map((cell) {
            if (cell is int) return excel.IntCellValue(cell);
            if (cell is double) return excel.DoubleCellValue(cell);
            return excel.TextCellValue(cell.toString());
          }).toList(),
        );
      }

      await _saveAndShareExcel(excelFile, 'products_sample.xlsx');

      emit(
        state.copyWith(
          isExporting: false,
          isSuccess: true,
          successMessage: 'Sample file downloaded!',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isExporting: false,
          errorMessage: 'Failed to create sample: ${e.toString()}',
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SAVE / SHARE HELPER
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _saveAndShareExcel(
    excel.Excel excelFile,
    String fileName,
  ) async {
    final rawBytes = excelFile.save();
    if (rawBytes == null) throw Exception('Failed to generate Excel bytes');

    // Convert List<int> → Uint8List (required by FilePicker)
    final bytes = Uint8List.fromList(rawBytes);

    await FilePicker.platform.saveFile(
      dialogTitle: 'Save $fileName',
      fileName: fileName,
      bytes: bytes,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MISC
  // ─────────────────────────────────────────────────────────────────────────

  void clearFile() {
    selectedFile = null;
    emit(ProductImportState.initial());
  }
}
