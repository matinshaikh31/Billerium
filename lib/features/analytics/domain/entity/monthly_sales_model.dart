import 'package:cloud_firestore/cloud_firestore.dart';

class MonthlySalesModel {
  final String id; // e.g., "2025-10"
  final double totalSales;
  final double totalPaid;
  final double totalPending;
  final int totalBills;
  final int totalProductsSold;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  MonthlySalesModel({
    required this.id,
    required this.totalSales,
    required this.totalPaid,
    required this.totalPending,
    required this.totalBills,
    required this.totalProductsSold,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MonthlySalesModel.initial(String id) {
    final now = Timestamp.now();
    return MonthlySalesModel(
      id: id,
      totalSales: 0,
      totalPaid: 0,
      totalPending: 0,
      totalBills: 0,
      totalProductsSold: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory MonthlySalesModel.fromJson(Map<String, dynamic> json, String id) {
    return MonthlySalesModel(
      id: id,
      totalSales: (json['totalSales'] ?? 0).toDouble(),
      totalPaid: (json['totalPaid'] ?? 0).toDouble(),
      totalPending: (json['totalPending'] ?? 0).toDouble(),
      totalBills: json['totalBills'] ?? 0,
      totalProductsSold: json['totalProductsSold'] ?? 0,
      createdAt: json['createdAt'] ?? Timestamp.now(),
      updatedAt: json['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSales': totalSales,
      'totalPaid': totalPaid,
      'totalPending': totalPending,
      'totalBills': totalBills,
      'totalProductsSold': totalProductsSold,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
