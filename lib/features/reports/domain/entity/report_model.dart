import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportType { sales, purchase, profit, inventory, transaction }

enum ReportPeriod { daily, weekly, monthly, yearly, custom }

class ReportModel {
  final String id;
  final ReportType type;
  final ReportPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> data;
  final Timestamp createdAt;

  ReportModel({
    required this.id,
    required this.type,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.data,
    required this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json, String id) {
    return ReportModel(
      id: id,
      type: ReportType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReportType.sales,
      ),
      period: ReportPeriod.values.firstWhere(
        (e) => e.name == json['period'],
        orElse: () => ReportPeriod.monthly,
      ),
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      data: json['data'] ?? {},
      createdAt: json['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'period': period.name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'data': data,
      'createdAt': createdAt,
    };
  }

  String get typeDisplayName {
    switch (type) {
      case ReportType.sales:
        return 'Sales Report';
      case ReportType.purchase:
        return 'Purchase Report';
      case ReportType.profit:
        return 'Profit & Loss Report';
      case ReportType.inventory:
        return 'Inventory Report';
      case ReportType.transaction:
        return 'Transaction Report';
    }
  }

  String get periodDisplayName {
    switch (period) {
      case ReportPeriod.daily:
        return 'Daily';
      case ReportPeriod.weekly:
        return 'Weekly';
      case ReportPeriod.monthly:
        return 'Monthly';
      case ReportPeriod.yearly:
        return 'Yearly';
      case ReportPeriod.custom:
        return 'Custom';
    }
  }
}

// Sales Report Data Model
class SalesReportData {
  final double totalSales;
  final double totalPaid;
  final double totalPending;
  final int totalBills;
  final int totalProductsSold;
  final List<DailySalesData> dailyBreakdown;

  SalesReportData({
    required this.totalSales,
    required this.totalPaid,
    required this.totalPending,
    required this.totalBills,
    required this.totalProductsSold,
    required this.dailyBreakdown,
  });

  factory SalesReportData.fromJson(Map<String, dynamic> json) {
    return SalesReportData(
      totalSales: (json['totalSales'] ?? 0).toDouble(),
      totalPaid: (json['totalPaid'] ?? 0).toDouble(),
      totalPending: (json['totalPending'] ?? 0).toDouble(),
      totalBills: json['totalBills'] ?? 0,
      totalProductsSold: json['totalProductsSold'] ?? 0,
      dailyBreakdown: (json['dailyBreakdown'] as List<dynamic>?)
              ?.map((e) => DailySalesData.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSales': totalSales,
      'totalPaid': totalPaid,
      'totalPending': totalPending,
      'totalBills': totalBills,
      'totalProductsSold': totalProductsSold,
      'dailyBreakdown': dailyBreakdown.map((e) => e.toJson()).toList(),
    };
  }
}

class DailySalesData {
  final DateTime date;
  final double sales;
  final int bills;

  DailySalesData({
    required this.date,
    required this.sales,
    required this.bills,
  });

  factory DailySalesData.fromJson(Map<String, dynamic> json) {
    return DailySalesData(
      date: (json['date'] as Timestamp).toDate(),
      sales: (json['sales'] ?? 0).toDouble(),
      bills: json['bills'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': Timestamp.fromDate(date),
      'sales': sales,
      'bills': bills,
    };
  }
}

