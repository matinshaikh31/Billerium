import 'package:billing_software/features/transactions/domain/models/transaction_model.dart';

abstract class TransactionRepository {
  Future<List<TransactionModel>> searchTransactions(String query);
}
