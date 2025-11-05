abstract class TransactionRepository {
  // Create a new transaction
  Future<String> createTransaction({
    required String billId,
    required String customerName,
    required double amount,
    required String mode,
  });

  // Get all transactions
  Stream<List<dynamic>> getAllTransactions();

  // Search transactions
  Future<List<dynamic>> searchTransactions(String query);

  // Get transactions by bill ID
  Future<List<dynamic>> getTransactionsByBillId(String billId);

  // Delete transaction
  Future<void> deleteTransaction(String id);
}

