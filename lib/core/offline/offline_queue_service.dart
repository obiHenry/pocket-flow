import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineQueueService {
  final SharedPreferences _prefs;
  static const _queueKey = 'offline_action_queue';

  OfflineQueueService(this._prefs);

  List<Map<String, dynamic>> getQueue() {
    final raw = _prefs.getString(_queueKey);
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> enqueue(String type, Map<String, dynamic> payload) async {
    final queue = getQueue();
    queue.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': type,
      'payload': payload,
    });
    await _prefs.setString(_queueKey, jsonEncode(queue));
  }

  Future<void> remove(String id) async {
    final queue = getQueue()..removeWhere((item) => item['id'] == id);
    await _prefs.setString(_queueKey, jsonEncode(queue));
  }

  Future<void> clearAll() async => _prefs.remove(_queueKey);

  bool get isEmpty => getQueue().isEmpty;
}
