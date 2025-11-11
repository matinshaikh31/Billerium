import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsModel {
  final double totalSales;
  final int totalBills;
  final int totalProducts;
  final double totalPaidAmount;
  final double totalUnpaidAmount;
  final Map<String, double>
  monthlySales; // { "2025-01": 12000, "2025-02": 8500 }
  final List<Map<String, dynamic>>
  topSellingProducts; // [{productId: "P1", name: "Shampoo", qty: 50}]

  final Timestamp lastUpdated;

  AnalyticsModel({
    required this.totalSales,
    required this.totalBills,
    required this.totalProducts,
    required this.totalPaidAmount,
    required this.totalUnpaidAmount,
    required this.monthlySales,
    required this.topSellingProducts,
    required this.lastUpdated,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      totalSales: (json['totalSales'] ?? 0).toDouble(),
      totalBills: json['totalBills'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      totalPaidAmount: (json['totalPaidAmount'] ?? 0).toDouble(),
      totalUnpaidAmount: (json['totalUnpaidAmount'] ?? 0).toDouble(),
      monthlySales: Map<String, double>.from(json['monthlySales'] ?? {}),
      topSellingProducts: List<Map<String, dynamic>>.from(
        json['topSellingProducts'] ?? [],
      ),
      lastUpdated: json['lastUpdated'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSales': totalSales,
      'totalBills': totalBills,
      'totalProducts': totalProducts,
      'totalPaidAmount': totalPaidAmount,
      'totalUnpaidAmount': totalUnpaidAmount,
      'monthlySales': monthlySales,
      'topSellingProducts': topSellingProducts,
      'lastUpdated': lastUpdated,
    };
  }
}
