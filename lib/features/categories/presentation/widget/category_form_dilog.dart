import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/core/theme/app_text_styles.dart';
import 'package:billing_software/features/categories/presentation/cubit/category_form_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryFormDialog extends StatelessWidget {
  final bool isEditing;

  const CategoryFormDialog({super.key, required this.isEditing});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoryFormCubit, CategoryFormState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
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
        final cubit = context.read<CategoryFormCubit>();
        final width = MediaQuery.of(context).size.width;
        final isDesktop = width > 900;
        final isTablet = width > 600 && width <= 900;
        final isMobile = width < 600;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: isDesktop ? 520 : 450,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context, isDesktop),
                Padding(
                  padding: EdgeInsets.all(isMobile ? 18 : 24),
                  child: Form(
                    key: cubit.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // _buildSectionHeader(
                        //   icon: CupertinoIcons.tag_fill,
                        //   iconColor: AppColors.primary,
                        //   title: isEditing
                        //       ? "Edit Category"
                        //       : "Create Category",
                        //   isMobile: isMobile,
                        // ),
                        // const SizedBox(height: 20),

                        // CATEGORY NAME
                        _buildTextField(
                          controller: cubit.nameController,
                          label: "Category Name *",
                          hint: "e.g., Electronics",
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please enter category name";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // DEFAULT DISCOUNT
                        _buildTextField(
                          controller: cubit.discountController,
                          label: "Default Discount (%)",
                          hint: "0",
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Required";
                            }
                            final discount = double.tryParse(value);
                            if (discount == null) {
                              return "Invalid number";
                            }
                            if (discount < 0 || discount > 100) {
                              return "Must be between 0 and 100";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                _buildActions(context, state, cubit),
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------- HEADER --------------------

  Widget _buildHeader(BuildContext context, bool isLarge) {
    return Container(
      padding: EdgeInsets.all(isLarge ? 20 : 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderGrey)),
        color: AppColors.secondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
              CupertinoIcons.tag_fill,
              color: AppColors.primary,
              size: isLarge ? 22 : 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isEditing ? "Edit Category" : "Create Category",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: isLarge ? 18 : 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              CupertinoIcons.xmark_circle_fill,
              color: AppColors.textSecondary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // -------------------- SECTION HEADER --------------------

  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool isMobile,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
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

  // -------------------- TEXT FIELD --------------------

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            filled: true,
            fillColor: AppColors.containerGreyColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.8,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderGrey),
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

  // -------------------- ACTION BUTTONS --------------------

  Widget _buildActions(
    BuildContext context,
    CategoryFormState state,
    CategoryFormCubit cubit,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderGrey)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: state.isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.borderGrey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Cancel",
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: state.isLoading
                  ? null
                  : () {
                      isEditing
                          ? cubit.updateCategory()
                          : cubit.createCategory();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.secondary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: state.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isEditing ? "Update Category" : "Create Category",
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
