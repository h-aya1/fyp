
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/dashboard/models/child_model.dart';

class DataService {
  static const String _key = 'fidelkids_data';

  Future<void> saveChildren(List<Child> children) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = children.map((c) => c.toJson()).toList();
    await prefs.setString(_key, json.encode(jsonList));
  }

  Future<List<Child>> loadChildren() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final jsonList = json.decode(data) as List;
    return jsonList.map((j) => Child.fromJson(j)).toList();
  }
}
