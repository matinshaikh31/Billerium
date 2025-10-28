import 'package:equatable/equatable.dart';

class TransactionModel extends Equatable {
  final String id;
  final String billId;
  final String customerName;
  final double amount;
  final String mode;
  final DateTime timestamp;

  const TransactionModel({
    required this.id,
    required this.billId,
    required this.customerName,
    required this.amount,
    required this.mode,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        billId,
        customerName,
        amount,
        mode,
        timestamp,
      ];
}

