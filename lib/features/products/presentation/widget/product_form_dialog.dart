import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/features/categories/presentation/cubit/category_cubit.dart';
import 'package:billing_software/features/products/domain/entity/product_model.dart';
import 'package:billing_software/features/products/presentation/cubit/product_form_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductFormDialog extends StatelessWidget {
  final ProductModel? product;

  const ProductFormDialog({super.key, this.product});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductFormCubit, ProductFormState>(
      listener: (context, state) {
        if (state.message != null && (state.message?.isNotEmpty ?? false)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: state.message!.contains('success')
                  ? AppColors.success
                  : AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<ProductFormCubit>();
        final width = MediaQuery.of(context).size.width;
        final isDesktop = width > 900;
        final isTablet = width > 600 && width <= 900;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 700 : (isTablet ? 650 : 500),
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderGrey),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(context, isDesktop || isTablet),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(
                      isDesktop ? 28 : (isTablet ? 24 : 20),
                    ),
                    child: Form(
                      key: cubit.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBasicInfoSection(
                            cubit,
                            context,
                            isDesktop,
                            isTablet,
                          ),
                          SizedBox(
                            height: isDesktop ? 28 : (isTablet ? 24 : 20),
                          ),
                          _buildPricingSection(cubit, isDesktop, isTablet),
                          SizedBox(
                            height: isDesktop ? 28 : (isTablet ? 24 : 20),
                          ),
                          _buildInventorySection(cubit, isDesktop, isTablet),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildActionButtons(context, cubit, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        border: Border(bottom: BorderSide(color: AppColors.borderGrey)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              CupertinoIcons.cube_box_fill,
              color: AppColors.primary,
              size: isLargeScreen ? 24 : 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              product == null ? 'Create New Product' : 'Edit Product',
              style: GoogleFonts.inter(
                fontSize: isLargeScreen ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(CupertinoIcons.xmark_circle_fill),
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
    bool isMobile = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? prefix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            hintStyle: GoogleFonts.inter(
              color: AppColors.textSecondary.withOpacity(0.4),
              fontSize: 14,
            ),
            filled: true,
            fillColor: AppColors.containerGreyColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.borderGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.borderGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.error),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: AppColors.textSecondary.withOpacity(0.4),
              fontSize: 14,
            ),
            filled: true,
            fillColor: AppColors.containerGreyColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.borderGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.borderGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ProductFormCubit cubit,
    ProductFormState state,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        border: Border(top: BorderSide(color: AppColors.borderGrey)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: state.isLoading
                    ? null
                    : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.borderGrey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () => cubit.submitForm(product, context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textLight,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        product == null ? 'Create Product' : 'Update Product',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sections (unchanged layout, themed content)
  Widget _buildBasicInfoSection(
    ProductFormCubit cubit,
    BuildContext context,
    bool isDesktop,
    bool isTablet,
  ) {
    final isMobile = !isDesktop && !isTablet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: CupertinoIcons.info_circle_fill,
          iconColor: AppColors.primary,
          title: "Basic Information",
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 16 : 20),
        _buildTextField(
          controller: cubit.nameController,
          label: "Product Name *",
          hint: "e.g., Laptop Stand",
          validator: (value) => value?.trim().isEmpty ?? true
              ? 'Please enter product name'
              : null,
        ),
        const SizedBox(height: 16),
        BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, categoryState) {
            return _buildDropdownField(
              value: cubit.selectedCategoryId,
              label: "Category *",
              hint: "Select category",
              items: categoryState.categories
                  .map(
                    (cat) =>
                        DropdownMenuItem(value: cat.id, child: Text(cat.name)),
                  )
                  .toList(),
              onChanged: (value) => cubit.setSelectedCategory(value),
              validator: (value) =>
                  value == null ? 'Please select category' : null,
            );
          },
        ),
      ],
    );
  }

  Widget _buildPricingSection(
    ProductFormCubit cubit,
    bool isDesktop,
    bool isTablet,
  ) {
    final isMobile = !isDesktop && !isTablet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: CupertinoIcons.money_dollar_circle_fill,
          iconColor: AppColors.billBtn,
          title: "Pricing",
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 16 : 20),
        if (isMobile) ...[
          _buildTextField(
            controller: cubit.priceController,
            label: "Price *",
            hint: "0.00",
            prefix: "₹",
            keyboardType: TextInputType.number,
            validator: (v) => (v?.trim().isEmpty ?? true)
                ? 'Required'
                : double.tryParse(v!) == null
                ? 'Invalid price'
                : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: cubit.discountController,
            label: "Discount %",
            hint: "0",
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v?.trim().isNotEmpty ?? false) {
                final d = double.tryParse(v!);
                if (d == null || d < 0 || d > 100) return 'Invalid discount';
              }
              return null;
            },
          ),
        ] else
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: cubit.priceController,
                  label: "Price *",
                  hint: "0.00",
                  prefix: "₹",
                  keyboardType: TextInputType.number,
                  validator: (v) => (v?.trim().isEmpty ?? true)
                      ? 'Required'
                      : double.tryParse(v!) == null
                      ? 'Invalid price'
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: cubit.discountController,
                  label: "Discount %",
                  hint: "0",
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v?.trim().isNotEmpty ?? false) {
                      final d = double.tryParse(v!);
                      if (d == null || d < 0 || d > 100)
                        return 'Invalid discount';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildInventorySection(
    ProductFormCubit cubit,
    bool isDesktop,
    bool isTablet,
  ) {
    final isMobile = !isDesktop && !isTablet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: CupertinoIcons.cube_box,
          iconColor: AppColors.documentBtn,
          title: "Inventory",
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 16 : 20),
        if (isMobile) ...[
          _buildTextField(
            controller: cubit.skuController,
            label: "SKU",
            hint: "e.g., PROD-001",
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: cubit.stockController,
            label: "Stock Quantity *",
            hint: "0",
            keyboardType: TextInputType.number,
            validator: (v) => (v?.trim().isEmpty ?? true)
                ? 'Required'
                : int.tryParse(v!) == null
                ? 'Invalid quantity'
                : null,
          ),
        ] else
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: cubit.skuController,
                  label: "SKU",
                  hint: "e.g., PROD-001",
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: cubit.stockController,
                  label: "Stock Quantity *",
                  hint: "0",
                  keyboardType: TextInputType.number,
                  validator: (v) => (v?.trim().isEmpty ?? true)
                      ? 'Required'
                      : int.tryParse(v!) == null
                      ? 'Invalid quantity'
                      : null,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
