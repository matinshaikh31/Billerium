import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TransactionModel extends Equatable {
  final String id;
  final String billId;
  final String customerName;
  final String? customerPhone;
  final double amount;
  final String mode; // Cash, Card, UPI, Bank Transfer
  final Timestamp timestamp;

  const TransactionModel({
    required this.id,
    required this.billId,
    required this.customerName,
    this.customerPhone,
    required this.amount,
    required this.mode,
    required this.timestamp,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json, String id) {
    return TransactionModel(
      id: id,
      billId: json['billId'] as String,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String?,
      amount: (json['amount'] as num).toDouble(),
      mode: json['mode'] as String,
      timestamp: json['timestamp'] as Timestamp,
    );
  }

  factory TransactionModel.fromDocSnap(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return TransactionModel.fromJson(doc.data(), doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'billId': billId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'amount': amount,
      'mode': mode,
      'timestamp': timestamp,
    };
  }

  @override
  List<Object?> get props => [
    id,
    billId,
    customerName,
    customerPhone,
    amount,
    mode,
    timestamp,
  ];
}
