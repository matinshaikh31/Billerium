import 'dart:math';

import 'package:billing_software/core/services/firebase.dart';

String capitalizeWords(String str) {
  if (str.isEmpty) return str;
  return str
      .split(' ')
      .map(
        (word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '',
      )
      .join(' ');
}

Future<String> generateBillNumber() async {
  try {
    // 1. Get total count of bills from Firebase
    final billsSnapshot = await FBFireStore.bills.count().get();
    final billCount = (billsSnapshot.count ?? 0) + 1;

    // 2. Get current financial year (April to March)
    final now = DateTime.now();
    final int currentYear = now.year;
    final int currentMonth = now.month;

    // Financial year starts in April
    String financialYear;
    if (currentMonth >= 4) {
      // April to December: 2025-26
      financialYear =
          '$currentYear-${(currentYear + 1).toString().substring(2)}';
    } else {
      // January to March: 2024-25
      financialYear =
          '${currentYear - 1}-${currentYear.toString().substring(2)}';
    }

    // 3. Generate bill number: HA/195/2025-26
    final billNo = 'HA/$billCount/$financialYear';

    return billNo;
  } catch (e) {
    // Fallback: use timestamp-based number
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final now = DateTime.now();
    final financialYear = now.month >= 4
        ? '${now.year}-${(now.year + 1).toString().substring(2)}'
        : '${now.year - 1}-${now.year.toString().substring(2)}';

    return 'HA/$timestamp/$financialYear';
  }
}

String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}
