extension StringCap on String? {
  String capitalize() {
    final text = this ?? "";
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
