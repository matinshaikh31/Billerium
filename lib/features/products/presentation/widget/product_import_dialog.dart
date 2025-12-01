import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/core/theme/app_text_styles.dart';
import 'package:billing_software/features/products/presentation/cubit/product_import_cubit.dart';
import 'package:billing_software/features/products/presentation/cubit/product_import_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductImportDialog extends StatelessWidget {
  const ProductImportDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: BlocConsumer<ProductImportCubit, ProductImportState>(
            listener: (context, state) {
              if (state.isSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.successMessage ?? 'Import successful'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.upload_file,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Import Products',
                              style: AppTextStyles.dialogHeading,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Upload Excel file to bulk import products',
                              style: AppTextStyles.dialogSubheading,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Excel Format Instructions',
                              style: AppTextStyles.tableRowPrimary.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your Excel file should have these columns in order:',
                          style: AppTextStyles.tableRowSecondary,
                        ),
                        const SizedBox(height: 8),
                        _buildInstructionRow('1. SKU (e.g HA0001)'),
                        _buildInstructionRow('2. Product Name (Required)'),
                        _buildInstructionRow('3. Category ID (Required)'),
                        _buildInstructionRow('4. Price (Required)'),
                        _buildInstructionRow('5. Qty (Optional, default: 0)'),
                        _buildInstructionRow('6. Discount % (Optional,or 0)'),
                        _buildInstructionRow('7. Stock (Required)'),
                        const SizedBox(height: 12),
                        Text(
                          '💡 Tip: Products with matching SKU  will be updated',
                          style: AppTextStyles.tableRowSecondary.copyWith(
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Download Sample Button
                  OutlinedButton.icon(
                    onPressed: () => _downloadSampleExcel(context),
                    icon: const Icon(Icons.download, size: 18),
                    label: Text(
                      'Download Sample Excel',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // File Selection
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: state.selectedFileName != null
                            ? AppColors.success
                            : AppColors.borderGrey,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.backgroundColor,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          state.selectedFileName != null
                              ? Icons.check_circle
                              : Icons.cloud_upload_outlined,
                          size: 48,
                          color: state.selectedFileName != null
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 12),
                        if (state.selectedFileName != null)
                          Text(
                            state.selectedFileName!,
                            style: AppTextStyles.tableRowPrimary.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          )
                        else
                          Text(
                            'No file selected',
                            style: AppTextStyles.tableRowSecondary,
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: state.isImporting
                              ? null
                              : () => context
                                    .read<ProductImportCubit>()
                                    .selectExcelFile(),
                          icon: const Icon(Icons.folder_open, size: 18),
                          label: Text(
                            'Choose Excel File',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: state.isImporting
                            ? null
                            : () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.tableRowSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed:
                            state.isImporting || state.selectedFileName == null
                            ? null
                            : () => context
                                  .read<ProductImportCubit>()
                                  .importProductsFromExcel(context),
                        icon: state.isImporting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.upload, size: 18),
                        label: Text(
                          state.isImporting
                              ? 'Importing...'
                              : 'Import Products',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(Icons.check_circle, size: 14, color: AppColors.success),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.tableRowSecondary.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _downloadSampleExcel(BuildContext context) {
    // Show info dialog about sample format
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.secondary,
        title: Text('Sample Excel Format', style: AppTextStyles.dialogHeading),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create an Excel file with these columns:',
              style: AppTextStyles.dialogSubheading,
            ),
            const SizedBox(height: 16),
            _buildSampleTable(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '⚠️ First row should be headers, data starts from row 2',
                style: AppTextStyles.tableRowSecondary.copyWith(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Got it', style: AppTextStyles.tableRowPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildSampleTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        border: TableBorder.all(color: AppColors.borderGrey),
        children: [
          TableRow(
            decoration: BoxDecoration(color: AppColors.headerBackground),
            children: [
              _buildTableCell('SKU', isHeader: true),
              _buildTableCell('Name', isHeader: true),
              _buildTableCell('Cat ID', isHeader: true),
              _buildTableCell('Price', isHeader: true),
              _buildTableCell('Qty', isHeader: true),
              _buildTableCell('Disc%', isHeader: true),
              _buildTableCell('Stock', isHeader: true),
            ],
          ),
          TableRow(
            children: [
              _buildTableCell('PRD001'),
              _buildTableCell('Laptop'),
              _buildTableCell('cat123'),
              _buildTableCell('50000'),
              _buildTableCell('1'),
              _buildTableCell('10'),
              _buildTableCell('25'),
            ],
          ),
          TableRow(
            children: [
              _buildTableCell('PRD002'),
              _buildTableCell('Mouse'),
              _buildTableCell('cat456'),
              _buildTableCell('500'),
              _buildTableCell('1'),
              _buildTableCell('5'),
              _buildTableCell('100'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: isHeader
            ? AppTextStyles.tabelHeader.copyWith(fontSize: 11)
            : AppTextStyles.tableRowSecondary.copyWith(fontSize: 10),
        textAlign: TextAlign.center,
      ),
    );
  }
}
