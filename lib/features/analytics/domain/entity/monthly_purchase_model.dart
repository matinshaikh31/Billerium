import 'package:cloud_firestore/cloud_firestore.dart';

class MonthlyPurchaseModel {
  final String id; // e.g., "2025-10"
  final double totalPurchaseAmount;
  final int totalItemsPurchased;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  MonthlyPurchaseModel({
    required this.id,
    required this.totalPurchaseAmount,
    required this.totalItemsPurchased,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MonthlyPurchaseModel.initial(String id) {
    final now = Timestamp.now();
    return MonthlyPurchaseModel(
      id: id,
      totalPurchaseAmount: 0,
      totalItemsPurchased: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory MonthlyPurchaseModel.fromJson(Map<String, dynamic> json, String id) {
    return MonthlyPurchaseModel(
      id: id,
      totalPurchaseAmount: (json['totalPurchaseAmount'] ?? 0).toDouble(),
      totalItemsPurchased: json['totalItemsPurchased'] ?? 0,
      createdAt: json['createdAt'] ?? Timestamp.now(),
      updatedAt: json['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPurchaseAmount': totalPurchaseAmount,
      'totalItemsPurchased': totalItemsPurchased,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

