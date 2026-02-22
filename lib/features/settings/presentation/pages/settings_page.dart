import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/core/theme/app_text_styles.dart';
import 'package:billing_software/features/settings/presentation/cubit/setting_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SettingCubit>().fetchSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: BlocListener<SettingCubit, SettingState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            _showSnack(state.successMessage!, AppColors.success);
          }
          if (state.error != null) {
            _showSnack(state.error!, AppColors.error);
          }
        },
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
    context.read<SettingCubit>().clearMessages();
  }

  // ─────────────────────────────────────────────────────────────── HEADER
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        border: Border(bottom: BorderSide(color: AppColors.borderGrey)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.settings_outlined,
            size: 28,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Settings", style: AppTextStyles.headerHeading),
                const SizedBox(height: 4),
                Text(
                  "Configure tax rates and application settings",
                  style: AppTextStyles.headerSubheading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────── BODY
  Widget _buildBody() {
    return BlocBuilder<SettingCubit, SettingState>(
      builder: (context, state) {
        if (state.isLoading && state.settings == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTaxSettingsCard(context, state),
              const SizedBox(height: 20),
              _buildInfoCard(),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────── TAX SETTINGS CARD
  Widget _buildTaxSettingsCard(BuildContext context, SettingState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey),
        // boxShadow: const [
        //   BoxShadow(
        //     color: AppColors.cardShadow,
        //     blurRadius: 8,
        //     offset: Offset(0, 2),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text("GST Configuration", style: AppTextStyles.customContainerTitle),
          const SizedBox(height: 8),
          Text(
            "Set CGST and SGST rates for billing calculations",
            style: AppTextStyles.customContainerSubTitle,
          ),
          const SizedBox(height: 24),

          // CGST Field
          _buildTextField(
            controller: context.read<SettingCubit>().cgstController,
            label: 'CGST (%)',
            hint: 'Enter CGST percentage',
          ),
          const SizedBox(height: 16),

          // SGST Field
          _buildTextField(
            controller: context.read<SettingCubit>().sgstController,
            label: 'SGST (%)',
            hint: 'Enter SGST percentage',
          ),
          const SizedBox(height: 24),

          // Total GST Display
          if (state.settings != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.infoSoft,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total GST:', style: AppTextStyles.textFieldTitle),
                  Text(
                    '${state.settings!.CGST + state.settings!.SGST}%',
                    style: AppTextStyles.statCardValue.copyWith(
                      color: AppColors.info,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Update Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: state.isLoading
                  ? null
                  : () => context.read<SettingCubit>().updateSettings(),
              icon: state.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save, color: Colors.white),
              label: Text(
                state.isLoading ? 'Updating...' : 'Update Settings',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────── TEXT FIELD
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.textFieldTitle),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.containerGreyColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────── INFO CARD
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.warning, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'These tax rates will be applied to all new bills. Changes will not affect existing bills.',
              style: AppTextStyles.customContainerSubTitle.copyWith(
                color: AppColors.warning.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
