import 'package:billing_software/features/billing/domain/entity/bill_item_model.dart';
import 'package:billing_software/features/billing/domain/entity/payment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class BillModel extends Equatable {
  final String id;
  final List<BillItemModel> items;
  final String? customerName;
  final String? customerPhone;
  final double subtotal;
  final double totalDiscount;
  final double totalTax;
  final double billDiscountPercent;
  final double billDiscountAmount;
  final double finalAmount;
  final double amountPaid;
  final double pendingAmount;
  final String status; // Paid, PartiallyPaid, Unpaid
  final List<PaymentModel> payments;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const BillModel({
    required this.id,
    required this.items,
    this.customerName,
    this.customerPhone,
    required this.subtotal,
    required this.totalDiscount,
    required this.totalTax,
    required this.billDiscountPercent,
    required this.billDiscountAmount,
    required this.finalAmount,
    required this.amountPaid,
    required this.pendingAmount,
    required this.status,
    required this.payments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BillModel.fromJson(Map<String, dynamic> json, String id) {
    return BillModel(
      id: id,
      items: (json['items'] as List)
          .map((item) => BillItemModel.fromJson(item))
          .toList(),
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      subtotal: (json['subtotal'] as num).toDouble(),
      totalDiscount: (json['totalDiscount'] as num).toDouble(),
      totalTax: (json['totalTax'] as num).toDouble(),
      billDiscountPercent: (json['billDiscountPercent'] as num).toDouble(),
      billDiscountAmount: (json['billDiscountAmount'] as num).toDouble(),
      finalAmount: (json['finalAmount'] as num).toDouble(),
      amountPaid: (json['amountPaid'] as num).toDouble(),
      pendingAmount: (json['pendingAmount'] as num).toDouble(),
      status: json['status'] as String,
      payments: (json['payments'] as List)
          .map((p) => PaymentModel.fromJson(p))
          .toList(),
      createdAt: json['createdAt'] as Timestamp,
      updatedAt: json['updatedAt'] as Timestamp,
    );
  }

  factory BillModel.fromDocSnap(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return BillModel.fromJson(doc.data(), doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'customerName': customerName,
      'customerPhone': customerPhone,
      'subtotal': subtotal,
      'totalDiscount': totalDiscount,
      'totalTax': totalTax,
      'billDiscountPercent': billDiscountPercent,
      'billDiscountAmount': billDiscountAmount,
      'finalAmount': finalAmount,
      'amountPaid': amountPaid,
      'pendingAmount': pendingAmount,
      'status': status,
      'payments': payments.map((p) => p.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  BillModel copyWith({
    String? id,
    List<BillItemModel>? items,
    String? customerName,
    String? customerPhone,
    double? subtotal,
    double? totalDiscount,
    double? totalTax,
    double? billDiscountPercent,
    double? billDiscountAmount,
    double? finalAmount,
    double? amountPaid,
    double? pendingAmount,
    String? status,
    List<PaymentModel>? payments,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return BillModel(
      id: id ?? this.id,
      items: items ?? this.items,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      subtotal: subtotal ?? this.subtotal,
      totalDiscount: totalDiscount ?? this.totalDiscount,
      totalTax: totalTax ?? this.totalTax,
      billDiscountPercent: billDiscountPercent ?? this.billDiscountPercent,
      billDiscountAmount: billDiscountAmount ?? this.billDiscountAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      amountPaid: amountPaid ?? this.amountPaid,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      status: status ?? this.status,
      payments: payments ?? this.payments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    items,
    customerName,
    customerPhone,
    subtotal,
    totalDiscount,
    totalTax,
    billDiscountPercent,
    billDiscountAmount,
    finalAmount,
    amountPaid,
    pendingAmount,
    status,
    payments,
    createdAt,
    updatedAt,
  ];
}
