import 'package:billing_software/core/theme/app_colors.dart';
import 'package:billing_software/core/theme/app_text_styles.dart';
import 'package:billing_software/features/customer/data/customer_migration_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerMigrationPage extends StatefulWidget {
  const CustomerMigrationPage({super.key});

  @override
  State<CustomerMigrationPage> createState() => _CustomerMigrationPageState();
}

class _CustomerMigrationPageState extends State<CustomerMigrationPage> {
  final CustomerMigrationService _migrationService = CustomerMigrationService();
  bool _isRunning = false;
  Map<String, dynamic>? _result;
  List<String> _logs = [];

  Future<void> _runMigration() async {
    setState(() {
      _isRunning = true;
      _result = null;
      _logs = [];
    });

    try {
      final result = await _migrationService.migrateCustomerData();
      
      setState(() {
        _result = result;
        _isRunning = false;
      });

      if (result['success'] == true) {
        _showSuccessDialog(result);
      } else {
        _showErrorDialog(result['error'].toString());
      }
    } catch (e) {
      setState(() {
        _isRunning = false;
        _result = {'success': false, 'error': e.toString()};
      });
      _showErrorDialog(e.toString());
    }
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 28),
            SizedBox(width: 12),
            Text('Migration Successful!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✅ Customers: ${result['customersCreated']}'),
            Text('✅ Bills Updated: ${result['billsUpdated']}'),
            Text('✅ Transactions Updated: ${result['transactionsUpdated']}'),
            Text('✅ Analytics Updated: ${result['analyticsUpdated']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: AppColors.error, size: 28),
            SizedBox(width: 12),
            Text('Migration Failed'),
          ],
        ),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Customer Data Migration',
          style: AppTextStyles.headerHeading.copyWith(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 32),
            _buildMigrationButton(),
            if (_result != null) ...[
              const SizedBox(height: 32),
              _buildResultCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.borderGrey),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'What this does',
                    style: AppTextStyles.customContainerTitle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoItem('📞 Groups all bills & transactions by phone number'),
            _buildInfoItem('✏️ Takes longest name for each phone number'),
            _buildInfoItem('👥 Creates/updates customer records'),
            _buildInfoItem('🔗 Links customer IDs to bills & transactions'),
            _buildInfoItem('📊 Updates customer analytics (sales, profit, orders)'),
            _buildInfoItem('📅 Creates monthly analytics breakdown'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This may take a few minutes for large datasets',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildMigrationButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _isRunning ? null : _runMigration,
        icon: _isRunning
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.sync, size: 24),
        label: Text(_isRunning ? 'Running Migration...' : 'Run Migration'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final success = _result?['success'] == true;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: success ? AppColors.success : AppColors.error,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: success ? AppColors.success : AppColors.error,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  success ? 'Migration Completed!' : 'Migration Failed',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: success ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
            if (success) ...[
              const SizedBox(height: 20),
              _buildStatRow('Customers Created/Updated', _result!['customersCreated'].toString()),
              _buildStatRow('Bills Updated', _result!['billsUpdated'].toString()),
              _buildStatRow('Transactions Updated', _result!['transactionsUpdated'].toString()),
              _buildStatRow('Analytics Updated', _result!['analyticsUpdated'].toString()),
            ] else ...[
              const SizedBox(height: 12),
              Text(
                _result?['error']?.toString() ?? 'Unknown error',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.tableRowSecondary),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
