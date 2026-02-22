import 'package:billing_software/features/purchase/domain/entity/purchase_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PurchaseModel extends Equatable {
  final String id;
  final String purchaseNo;
  final String? supplierName;
  final String? supplierPhone;
  final String? supplierGstNumber;
  final List<PurchaseItemModel> items;
  final double totalBeforeTax; // Renamed from subtotal for clarity
  final double cgst;
  final double sgst;
  final double totalTax; // CGST + SGST
  final double otherExpense;
  final double finalAmount; // totalBeforeTax + totalTax + otherExpense
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const PurchaseModel({
    required this.id,
    required this.purchaseNo,
    this.supplierName,
    this.supplierPhone,
    this.supplierGstNumber,
    required this.items,
    required this.totalBeforeTax,
    this.cgst = 0,
    this.sgst = 0,
    required this.totalTax,
    this.otherExpense = 0,
    required this.finalAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json, String id) {
    // Support both old 'subtotal' and new 'totalBeforeTax' for backward compatibility
    final totalBeforeTax =
        (json['totalBeforeTax'] as num?)?.toDouble() ??
        (json['subtotal'] as num?)?.toDouble() ??
        0;

    return PurchaseModel(
      id: id,
      purchaseNo: json['purchaseNo'] as String,
      supplierName: json['supplierName'] as String?,
      supplierPhone: json['supplierPhone'] as String?,
      supplierGstNumber: json['supplierGstNumber'] as String?,
      items: (json['items'] as List)
          .map((item) => PurchaseItemModel.fromJson(item))
          .toList(),
      totalBeforeTax: totalBeforeTax,
      cgst: (json['cgst'] as num?)?.toDouble() ?? 0,
      sgst: (json['sgst'] as num?)?.toDouble() ?? 0,
      totalTax: (json['totalTax'] as num?)?.toDouble() ?? 0,
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
      'supplierGstNumber': supplierGstNumber,
      'items': items.map((item) => item.toJson()).toList(),
      'totalBeforeTax': totalBeforeTax,
      'cgst': cgst,
      'sgst': sgst,
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
    String? supplierGstNumber,
    List<PurchaseItemModel>? items,
    double? totalBeforeTax,
    double? cgst,
    double? sgst,
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
      supplierGstNumber: supplierGstNumber ?? this.supplierGstNumber,
      items: items ?? this.items,
      totalBeforeTax: totalBeforeTax ?? this.totalBeforeTax,
      cgst: cgst ?? this.cgst,
      sgst: sgst ?? this.sgst,
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
    supplierGstNumber,
    items,
    totalBeforeTax,
    cgst,
    sgst,
    totalTax,
    otherExpense,
    finalAmount,
    createdAt,
    updatedAt,
  ];
}
