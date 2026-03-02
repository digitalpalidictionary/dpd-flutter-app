import 'dart:convert';
void main() {
  String rootsStr = '["√har 1", "√har 2", "√har 3", "√har 4"]';
  final decoded = jsonDecode(rootsStr) as List;
  List<String> keys = [];
  for (final key in decoded) {
    if (key is String && key.isNotEmpty) keys.add(key);
  }
}
