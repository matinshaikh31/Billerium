import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/bill_model.dart';
import '../../domain/models/bill_item_model.dart';
import '../../domain/models/payment_model.dart';

class BillDto {
  final String id;
  final List<Map<String, dynamic>> items;
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
  final String status;
  final List<Map<String, dynamic>> payments;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  BillDto({
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

  factory BillDto.fromJson(Map<String, dynamic> json, String id) {
    return BillDto(
      id: id,
      items: List<Map<String, dynamic>>.from(json['items'] ?? []),
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
      payments: List<Map<String, dynamic>>.from(json['payments'] ?? []),
      createdAt: json['createdAt'] as Timestamp,
      updatedAt: json['updatedAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items,
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
      'payments': payments,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  BillModel toModel() {
    return BillModel(
      id: id,
      items: items
          .map((item) => BillItemModel(
                productId: item['productId'] as String,
                productName: item['productName'] as String,
                price: (item['price'] as num).toDouble(),
                quantity: item['quantity'] as int,
                discountPercent: (item['discountPercent'] as num).toDouble(),
                taxPercent: (item['taxPercent'] as num).toDouble(),
              ))
          .toList(),
      customerName: customerName,
      customerPhone: customerPhone,
      subtotal: subtotal,
      totalDiscount: totalDiscount,
      totalTax: totalTax,
      billDiscountPercent: billDiscountPercent,
      billDiscountAmount: billDiscountAmount,
      finalAmount: finalAmount,
      amountPaid: amountPaid,
      pendingAmount: pendingAmount,
      status: status,
      payments: payments
          .map((payment) => PaymentModel(
                id: payment['id'] as String,
                amount: (payment['amount'] as num).toDouble(),
                mode: payment['mode'] as String,
                timestamp: (payment['timestamp'] as Timestamp).toDate(),
              ))
          .toList(),
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt.toDate(),
    );
  }

  factory BillDto.fromModel(BillModel model) {
    return BillDto(
      id: model.id,
      items: model.items
          .map((item) => {
                'productId': item.productId,
                'productName': item.productName,
                'price': item.price,
                'quantity': item.quantity,
                'discountPercent': item.discountPercent,
                'taxPercent': item.taxPercent,
              })
          .toList(),
      customerName: model.customerName,
      customerPhone: model.customerPhone,
      subtotal: model.subtotal,
      totalDiscount: model.totalDiscount,
      totalTax: model.totalTax,
      billDiscountPercent: model.billDiscountPercent,
      billDiscountAmount: model.billDiscountAmount,
      finalAmount: model.finalAmount,
      amountPaid: model.amountPaid,
      pendingAmount: model.pendingAmount,
      status: model.status,
      payments: model.payments
          .map((payment) => {
                'id': payment.id,
                'amount': payment.amount,
                'mode': payment.mode,
                'timestamp': Timestamp.fromDate(payment.timestamp),
              })
          .toList(),
      createdAt: Timestamp.fromDate(model.createdAt),
      updatedAt: Timestamp.fromDate(model.updatedAt),
    );
  }
}

