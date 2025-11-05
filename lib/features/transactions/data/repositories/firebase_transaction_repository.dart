import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/features/transactions/domain/models/transaction_model.dart';
import 'package:billing_software/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTransactionRepository extends TransactionRepository {
  final transactionsCollectionRef = FBFireStore.transactions;

  @override
  Future<String> createTransaction({
    required String billId,
    required String customerName,
    required double amount,
    required String mode,
  }) async {
    try {
      final docRef = transactionsCollectionRef.doc();
      final now = Timestamp.now();

      final transaction = {
        'id': docRef.id,
        'billId': billId,
        'customerName': customerName,
        'amount': amount,
        'mode': mode,
        'timestamp': now,
      };

      await docRef.set(transaction);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create transaction: ${e.toString()}');
    }
  }

  @override
  Stream<List<TransactionModel>> getAllTransactions() {
    try {
      return transactionsCollectionRef
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return TransactionModel(
            id: doc.id,
            billId: data['billId'] as String,
            customerName: data['customerName'] as String,
            amount: (data['amount'] as num).toDouble(),
            mode: data['mode'] as String,
            timestamp: (data['timestamp'] as Timestamp).toDate(),
          );
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to get transactions: ${e.toString()}');
    }
  }

  @override
  Future<List<TransactionModel>> searchTransactions(String query) async {
    try {
      final queryLower = query.toLowerCase();

      // Search by customer name or bill ID
      final snapshot = await transactionsCollectionRef
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      final transactions = snapshot.docs.map((doc) {
        final data = doc.data();
        return TransactionModel(
          id: doc.id,
          billId: data['billId'] as String,
          customerName: data['customerName'] as String,
          amount: (data['amount'] as num).toDouble(),
          mode: data['mode'] as String,
          timestamp: (data['timestamp'] as Timestamp).toDate(),
        );
      }).toList();

      // Filter by customer name or bill ID
      return transactions.where((t) {
        return t.customerName.toLowerCase().contains(queryLower) ||
            t.billId.toLowerCase().contains(queryLower);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search transactions: ${e.toString()}');
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionsByBillId(String billId) async {
    try {
      final snapshot = await transactionsCollectionRef
          .where('billId', isEqualTo: billId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TransactionModel(
          id: doc.id,
          billId: data['billId'] as String,
          customerName: data['customerName'] as String,
          amount: (data['amount'] as num).toDouble(),
          mode: data['mode'] as String,
          timestamp: (data['timestamp'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get transactions by bill ID: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await transactionsCollectionRef.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete transaction: ${e.toString()}');
    }
  }
}

