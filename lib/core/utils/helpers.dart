import 'dart:math';

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

String generateBillNoWithTimestamp() {
  const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final Random random = Random();
  final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

  // Take last 3 digits from timestamp and convert to alphanumeric
  final String timePart = timestamp.substring(timestamp.length - 3);

  // Generate 3 random characters
  final String randomPart = List.generate(3, (index) {
    return chars[random.nextInt(chars.length)];
  }).join();

  return '$timePart$randomPart';
}
