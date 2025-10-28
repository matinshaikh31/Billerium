import 'package:equatable/equatable.dart';

class StockHistoryModel extends Equatable {
  final String id;
  final String productId;
  final int qtyChange;
  final String reason;
  final DateTime date;

  const StockHistoryModel({
    required this.id,
    required this.productId,
    required this.qtyChange,
    required this.reason,
    required this.date,
  });

  @override
  List<Object?> get props => [id, productId, qtyChange, reason, date];
}

