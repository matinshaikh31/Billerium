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
