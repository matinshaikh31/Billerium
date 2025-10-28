import 'package:equatable/equatable.dart';

class PaymentModel extends Equatable {
  final String id;
  final double amount;
  final String mode;
  final DateTime timestamp;

  const PaymentModel({
    required this.id,
    required this.amount,
    required this.mode,
    required this.timestamp,
  });

  PaymentModel copyWith({
    String? id,
    double? amount,
    String? mode,
    DateTime? timestamp,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      mode: mode ?? this.mode,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [id, amount, mode, timestamp];
}

