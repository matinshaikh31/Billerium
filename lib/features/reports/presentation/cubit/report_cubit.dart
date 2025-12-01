import 'package:billing_software/features/reports/data/firebase_report_repository.dart';
import 'package:billing_software/features/reports/domain/entity/report_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final FirebaseReportRepository _reportRepository;

  ReportCubit({required FirebaseReportRepository reportRepository})
      : _reportRepository = reportRepository,
        super(ReportState.initial());

  // Set report type
  void setReportType(ReportType type) {
    emit(state.copyWith(selectedType: type));
  }

  // Set date range
  void setDateRange(DateTime start, DateTime end) {
    emit(state.copyWith(startDate: start, endDate: end));
  }

  // Generate report based on selected type
  Future<void> generateReport() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      Map<String, dynamic> reportData;

      switch (state.selectedType) {
        case ReportType.sales:
          final salesData = await _reportRepository.generateSalesReport(
            startDate: state.startDate,
            endDate: state.endDate,
          );
          reportData = salesData.toJson();
          break;
        case ReportType.purchase:
          reportData = await _reportRepository.generatePurchaseReport(
            startDate: state.startDate,
            endDate: state.endDate,
          );
          break;
        case ReportType.profit:
          reportData = await _reportRepository.generateProfitReport(
            startDate: state.startDate,
            endDate: state.endDate,
          );
          break;
        case ReportType.inventory:
          reportData = await _reportRepository.generateInventoryReport();
          break;
        case ReportType.transaction:
          reportData = await _reportRepository.generateTransactionReport(
            startDate: state.startDate,
            endDate: state.endDate,
          );
          break;
      }

      emit(state.copyWith(
        isLoading: false,
        reportData: reportData,
        hasGenerated: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to generate report: $e',
      ));
    }
  }

  // Reset report
  void resetReport() {
    emit(ReportState.initial());
  }

  // Quick date range presets
  void setThisMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);
    setDateRange(start, end);
  }

  void setLastMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 1, 1);
    final end = DateTime(now.year, now.month, 0);
    setDateRange(start, end);
  }

  void setThisYear() {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year, 12, 31);
    setDateRange(start, end);
  }

  void setLast7Days() {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));
    setDateRange(start, now);
  }

  void setLast30Days() {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30));
    setDateRange(start, now);
  }
}

