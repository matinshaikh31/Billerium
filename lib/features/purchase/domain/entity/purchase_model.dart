import 'package:billing_software/features/purchase/domain/entity/purchase_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PurchaseModel extends Equatable {
  final String id;
  final String purchaseNo;
  final String? supplierName;
  final String? supplierPhone;
  final List<PurchaseItemModel> items;
  final double subtotal;
  final double totalTax;
  final double otherExpense;
  final double finalAmount;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const PurchaseModel({
    required this.id,
    required this.purchaseNo,
    this.supplierName,
    this.supplierPhone,
    required this.items,
    required this.subtotal,
    required this.totalTax,
    this.otherExpense = 0,
    required this.finalAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json, String id) {
    return PurchaseModel(
      id: id,
      purchaseNo: json['purchaseNo'] as String,
      supplierName: json['supplierName'] as String?,
      supplierPhone: json['supplierPhone'] as String?,
      items: (json['items'] as List)
          .map((item) => PurchaseItemModel.fromJson(item))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      totalTax: (json['totalTax'] as num).toDouble(),
      otherExpense: (json['otherExpense'] as num?)?.toDouble() ?? 0,
      finalAmount: (json['finalAmount'] as num).toDouble(),
      createdAt: json['createdAt'] as Timestamp,
      updatedAt: json['updatedAt'] as Timestamp,
    );
  }

  factory PurchaseModel.fromDocSnap(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return PurchaseModel.fromJson(doc.data(), doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'purchaseNo': purchaseNo,
      'supplierName': supplierName,
      'supplierPhone': supplierPhone,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'totalTax': totalTax,
      'otherExpense': otherExpense,
      'finalAmount': finalAmount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  PurchaseModel copyWith({
    String? id,
    String? purchaseNo,
    String? supplierName,
    String? supplierPhone,
    List<PurchaseItemModel>? items,
    double? subtotal,
    double? totalTax,
    double? otherExpense,
    double? finalAmount,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return PurchaseModel(
      id: id ?? this.id,
      purchaseNo: purchaseNo ?? this.purchaseNo,
      supplierName: supplierName ?? this.supplierName,
      supplierPhone: supplierPhone ?? this.supplierPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      totalTax: totalTax ?? this.totalTax,
      otherExpense: otherExpense ?? this.otherExpense,
      finalAmount: finalAmount ?? this.finalAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    purchaseNo,
    supplierName,
    supplierPhone,
    items,
    subtotal,
    totalTax,
    otherExpense,
    finalAmount,
    createdAt,
    updatedAt,
  ];
}
