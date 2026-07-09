import 'package:shared_preferences/shared_preferences.dart';

class ReportPersistenceService {
  static const _key = 'reported_transaction_ids';

  Future<Set<String>> loadReportedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key);
    return ids?.toSet() ?? {};
  }

  Future<void> saveReportedId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key) ?? [];
    ids.add(id);
    await prefs.setStringList(_key, ids.toSet().toList());
  }
}
