part of 'report_cubit.dart';

class ReportState {
  final bool isLoading;
  final ReportType selectedType;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic>? reportData;
  final String? error;
  final bool hasGenerated;

  const ReportState({
    required this.isLoading,
    required this.selectedType,
    required this.startDate,
    required this.endDate,
    this.reportData,
    this.error,
    required this.hasGenerated,
  });

  factory ReportState.initial() {
    final now = DateTime.now();
    return ReportState(
      isLoading: false,
      selectedType: ReportType.sales,
      startDate: DateTime(now.year, now.month, 1),
      endDate: now,
      reportData: null,
      error: null,
      hasGenerated: false,
    );
  }

  ReportState copyWith({
    bool? isLoading,
    ReportType? selectedType,
    DateTime? startDate,
    DateTime? endDate,
    Map<String, dynamic>? reportData,
    String? error,
    bool? hasGenerated,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      selectedType: selectedType ?? this.selectedType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reportData: reportData ?? this.reportData,
      error: error,
      hasGenerated: hasGenerated ?? this.hasGenerated,
    );
  }
}

