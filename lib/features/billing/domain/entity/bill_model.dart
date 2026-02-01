import 'package:billing_software/features/billing/domain/entity/bill_item_model.dart';
import 'package:billing_software/features/billing/domain/entity/payment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class BillModel extends Equatable {
  final String id;
  final String billNo;
  final List<BillItemModel> items;
  final String? customerName;
  final String? customerPhone;
  final String? customerGstNumber;
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
  final Timestamp?
  billDate; // Nullable for backward compatibility with existing data

  const BillModel({
    required this.id,
    required this.billNo,
    required this.items,
    this.customerName,
    this.customerPhone,
    this.customerGstNumber,
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
    this.billDate,
  });

  factory BillModel.fromJson(Map<String, dynamic> json, String id) {
    return BillModel(
      id: id,
      billNo: json['billNo'] as String,
      items: (json['items'] as List)
          .map((item) => BillItemModel.fromJson(item))
          .toList(),
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      customerGstNumber: json['customerGstNumber'] as String?,
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
      billDate:
          json['billDate'] as Timestamp?, // Nullable for backward compatibility
    );
  }

  factory BillModel.fromDocSnap(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return BillModel.fromJson(doc.data(), doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'billNo': billNo,
      'items': items.map((item) => item.toJson()).toList(),
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerGstNumber': customerGstNumber,
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
      if (billDate != null) 'billDate': billDate,
    };
  }

  BillModel copyWith({
    String? id,
    String? billNo,
    List<BillItemModel>? items,
    String? customerName,
    String? customerPhone,
    String? customerGstNumber,
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
    Timestamp? billDate,
  }) {
    return BillModel(
      id: id ?? this.id,
      billNo: billNo ?? this.billNo,
      items: items ?? this.items,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerGstNumber: customerGstNumber ?? this.customerGstNumber,
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
      billDate: billDate ?? this.billDate,
    );
  }

  /// Helper to get the effective bill date (billDate if set, otherwise createdAt)
  Timestamp get effectiveBillDate => billDate ?? createdAt;

  @override
  List<Object?> get props => [
    id,
    billNo,
    items,
    customerName,
    customerPhone,
    customerGstNumber,
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
    billDate,
  ];
}
