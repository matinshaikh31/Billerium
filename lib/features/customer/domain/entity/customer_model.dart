import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CustomerModel extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  
  // Balance: Positive = customer has credit/advance, Negative = customer owes (debt)
  final double balance;
  
  // Analytics fields
  final double totalPurchases; // Total amount of all purchases
  final double totalProfit; // Total profit from this customer
  final int orderCount; // Number of orders
  
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    required this.balance,
    required this.totalPurchases,
    required this.totalProfit,
    required this.orderCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json, String id) {
    return CustomerModel(
      id: id,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      address: json['address'] as String?,
      balance: (json['balance'] ?? 0).toDouble(),
      totalPurchases: (json['totalPurchases'] ?? 0).toDouble(),
      totalProfit: (json['totalProfit'] ?? 0).toDouble(),
      orderCount: (json['orderCount'] ?? 0) as int,
      createdAt: json['createdAt'] as Timestamp,
      updatedAt: json['updatedAt'] as Timestamp,
    );
  }

  factory CustomerModel.fromDocSnap(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return CustomerModel.fromJson(doc.data(), doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nameLowercase': name.toLowerCase(), // For case-insensitive search
      'phone': phone,
      'email': email,
      'address': address,
      'balance': balance,
      'totalPurchases': totalPurchases,
      'totalProfit': totalProfit,
      'orderCount': orderCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    double? balance,
    double? totalPurchases,
    double? totalProfit,
    int? orderCount,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      balance: balance ?? this.balance,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalProfit: totalProfit ?? this.totalProfit,
      orderCount: orderCount ?? this.orderCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getters
  double get debt => balance < 0 ? balance.abs() : 0;
  double get credit => balance > 0 ? balance : 0;
  bool get hasDebt => balance < 0;
  bool get hasCredit => balance > 0;

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        email,
        address,
        balance,
        totalPurchases,
        totalProfit,
        orderCount,
        createdAt,
        updatedAt,
      ];
}
