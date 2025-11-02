import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel  {
  final String id;
  final double amount;
  final String mode; // Cash, Card, UPI, etc.
  final Timestamp paidAt;

  const PaymentModel({
    required this.id,
    required this.amount,
    required this.mode,
    required this.paidAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      mode: json['mode'] as String,
      paidAt: json['paidAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'amount': amount, 'mode': mode, 'paidAt': paidAt};
  }
}
