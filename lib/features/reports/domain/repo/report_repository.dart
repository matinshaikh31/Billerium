import 'package:billing_software/features/reports/domain/entity/report_model.dart';

abstract class ReportRepository {
  Future<SalesReportData> generateSalesReport({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Map<String, dynamic>> generatePurchaseReport({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Map<String, dynamic>> generateProfitReport({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Map<String, dynamic>> generateInventoryReport();

  Future<Map<String, dynamic>> generateTransactionReport({
    required DateTime startDate,
    required DateTime endDate,
  });
}

