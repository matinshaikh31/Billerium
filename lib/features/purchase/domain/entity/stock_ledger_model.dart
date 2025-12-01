import 'package:cloud_firestore/cloud_firestore.dart';

class StockLedgerModel {
  final String id;
  final String productId;
  final String type; // "purchase", "sale", "return"
  final int qtyChange;
  final int finalStock;
  final String referenceId; // billId or purchaseId
  final Timestamp timestamp;

  const StockLedgerModel({
    required this.id,
    required this.productId,
    required this.type,
    required this.qtyChange,
    required this.finalStock,
    required this.referenceId,
    required this.timestamp,
  });

  factory StockLedgerModel.fromJson(Map<String, dynamic> json, String id) {
    return StockLedgerModel(
      id: id,
      productId: json['productId'] as String,
      type: json['type'] as String,
      qtyChange: json['qtyChange'] as int,
      finalStock: json['finalStock'] as int,
      referenceId: json['referenceId'] as String,
      timestamp: json['timestamp'] as Timestamp,
    );
  }

  factory StockLedgerModel.fromDocSnap(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return StockLedgerModel.fromJson(doc.data(), doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'type': type,
      'qtyChange': qtyChange,
      'finalStock': finalStock,
      'referenceId': referenceId,
      'timestamp': timestamp,
    };
  }
}

