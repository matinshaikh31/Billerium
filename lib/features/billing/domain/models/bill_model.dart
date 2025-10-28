import 'package:equatable/equatable.dart';
import 'bill_item_model.dart';
import 'payment_model.dart';

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
  final DateTime createdAt;
  final DateTime updatedAt;

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
    DateTime? createdAt,
    DateTime? updatedAt,
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

