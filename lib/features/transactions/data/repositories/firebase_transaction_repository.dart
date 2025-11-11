import 'package:billing_software/core/services/firebase.dart';
import 'package:billing_software/features/transactions/domain/models/transaction_model.dart';
import 'package:billing_software/features/transactions/domain/repositories/transaction_repository.dart';

class FirebaseTransactionRepository extends TransactionRepository {
  final transactionsCollectionRef = FBFireStore.transactions;

  @override
  Future<List<TransactionModel>> searchTransactions(String query) async {
    try {
      final snapshot = await transactionsCollectionRef
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => TransactionModel.fromDocSnap(doc))
          .where(
            (transaction) =>
                transaction.billId.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                transaction.customerName.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                (transaction.customerPhone?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search transactions: ${e.toString()}');
    }
  }
}
