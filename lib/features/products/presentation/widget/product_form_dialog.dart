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
                  ? Colors.green
                  : Colors.red,
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
        final isDesktop = MediaQuery.of(context).size.width > 900;
        final isTablet =
            MediaQuery.of(context).size.width > 600 &&
            MediaQuery.of(context).size.width <= 900;

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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              CupertinoIcons.cube_box_fill,
              color: const Color(0xFF3B82F6),
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
                color: const Color(0xFF111827),
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(CupertinoIcons.xmark_circle_fill),
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

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
          iconColor: Colors.blue,
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
              items: categoryState.categories.map((cat) {
                return DropdownMenuItem(value: cat.id, child: Text(cat.name));
              }).toList(),
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
          iconColor: Colors.orange,
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
            validator: (value) {
              if (value?.trim().isEmpty ?? true) return 'Required';
              if (double.tryParse(value!) == null) return 'Invalid price';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: cubit.discountController,
            label: "Discount %",
            hint: "0",
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.trim().isNotEmpty ?? false) {
                final discount = double.tryParse(value!);
                if (discount == null || discount < 0 || discount > 100) {
                  return 'Invalid discount';
                }
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
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) return 'Required';
                    if (double.tryParse(value!) == null) return 'Invalid price';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: cubit.discountController,
                  label: "Discount %",
                  hint: "0",
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.trim().isNotEmpty ?? false) {
                      final discount = double.tryParse(value!);
                      if (discount == null || discount < 0 || discount > 100) {
                        return 'Invalid discount';
                      }
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
          iconColor: Colors.green,
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
            validator: (value) {
              if (value?.trim().isEmpty ?? true) return 'Required';
              if (int.tryParse(value!) == null) return 'Invalid quantity';
              return null;
            },
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
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) return 'Required';
                    if (int.tryParse(value!) == null) return 'Invalid quantity';
                    return null;
                  },
                ),
              ),
            ],
          ),
      ],
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
          child: Icon(icon, size: 16, color: iconColor.withOpacity(0.8)),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
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
            color: const Color(0xFF374151),
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
            hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
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
            color: const Color(0xFF374151),
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
            hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
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
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
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
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF6B7280),
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
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
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
}
