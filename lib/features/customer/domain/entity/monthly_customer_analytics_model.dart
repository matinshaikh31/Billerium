import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Monthly analytics for each customer
/// Firestore path: /customerAnalytics/{customerId_year-month}
/// Example: /customerAnalytics/cust123_2024-01
class MonthlyCustomerAnalyticsModel extends Equatable {
  final String id; // Format: "customerId_2024-01", "customerId_2024-02", etc.
  final String customerId;
  final int year;
  final int month;

  // Sales metrics
  final double totalSales; // Total amount of all bills
  final double totalProfit; // Total profit from all bills
  final int orderCount; // Number of bills/orders
  final double averageOrderValue; // totalSales / orderCount

  // Purchase/Payment metrics
  final double totalPurchases; // Same as totalSales (for consistency)
  final double totalPayments; // Total amount paid (excluding balance usage)
  final double balanceUsed; // Amount paid using customer balance
  final double balanceAdded; // Negative balance (debt) added

  final Timestamp createdAt;
  final Timestamp updatedAt;

  const MonthlyCustomerAnalyticsModel({
    required this.id,
    required this.customerId,
    required this.year,
    required this.month,
    required this.totalSales,
    required this.totalProfit,
    required this.orderCount,
    required this.averageOrderValue,
    required this.totalPurchases,
    required this.totalPayments,
    required this.balanceUsed,
    required this.balanceAdded,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MonthlyCustomerAnalyticsModel.fromJson(
    Map<String, dynamic> json,
    String id,
  ) {
    return MonthlyCustomerAnalyticsModel(
      id: id,
      customerId: json['customerId'] as String,
      year: json['year'] as int,
      month: json['month'] as int,
      totalSales: (json['totalSales'] ?? 0).toDouble(),
      totalProfit: (json['totalProfit'] ?? 0).toDouble(),
      orderCount: (json['orderCount'] ?? 0) as int,
      averageOrderValue: (json['averageOrderValue'] ?? 0).toDouble(),
      totalPurchases: (json['totalPurchases'] ?? 0).toDouble(),
      totalPayments: (json['totalPayments'] ?? 0).toDouble(),
      balanceUsed: (json['balanceUsed'] ?? 0).toDouble(),
      balanceAdded: (json['balanceAdded'] ?? 0).toDouble(),
      createdAt: json['createdAt'] as Timestamp,
      updatedAt: json['updatedAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'year': year,
      'month': month,
      'totalSales': totalSales,
      'totalProfit': totalProfit,
      'orderCount': orderCount,
      'averageOrderValue': averageOrderValue,
      'totalPurchases': totalPurchases,
      'totalPayments': totalPayments,
      'balanceUsed': balanceUsed,
      'balanceAdded': balanceAdded,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  MonthlyCustomerAnalyticsModel copyWith({
    String? id,
    String? customerId,
    int? year,
    int? month,
    double? totalSales,
    double? totalProfit,
    int? orderCount,
    double? averageOrderValue,
    double? totalPurchases,
    double? totalPayments,
    double? balanceUsed,
    double? balanceAdded,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return MonthlyCustomerAnalyticsModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      year: year ?? this.year,
      month: month ?? this.month,
      totalSales: totalSales ?? this.totalSales,
      totalProfit: totalProfit ?? this.totalProfit,
      orderCount: orderCount ?? this.orderCount,
      averageOrderValue: averageOrderValue ?? this.averageOrderValue,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalPayments: totalPayments ?? this.totalPayments,
      balanceUsed: balanceUsed ?? this.balanceUsed,
      balanceAdded: balanceAdded ?? this.balanceAdded,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Helper to get month-year ID (e.g., "2024-01")
  static String getMonthId(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  /// Generate composite document ID (e.g., "cust123_2024-01")
  static String generateDocId(String customerId, DateTime date) {
    final monthId = getMonthId(date);
    return '${customerId}_$monthId';
  }

  /// Parse customerId from composite document ID
  static String getCustomerIdFromDocId(String docId) {
    return docId.split('_')[0];
  }

  /// Parse monthId from composite document ID
  static String getMonthIdFromDocId(String docId) {
    return docId.split('_')[1];
  }

  @override
  List<Object?> get props => [
    id,
    customerId,
    year,
    month,
    totalSales,
    totalProfit,
    orderCount,
    averageOrderValue,
    totalPurchases,
    totalPayments,
    balanceUsed,
    balanceAdded,
    createdAt,
    updatedAt,
  ];
}
