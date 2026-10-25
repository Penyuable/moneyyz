class InitialsUtil {
  static String of(String? input) {
    final text = (input ?? '').trim();
    if (text.isEmpty) return 'S';
    final parts = text.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}
String initialsOf(String? input) => InitialsUtil.of(input);
