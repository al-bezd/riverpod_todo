import 'dart:async';
import 'dart:convert';

import 'package:riverpod_todo/models/todo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class TodoRepository {
  late final SharedPreferences _prefs;

  final _uuid = Uuid();
  int _count = 0;
  Timer? _saveTimer;
  bool _isInited = false;

  init() async {
    if (_isInited) return;
    _prefs = await SharedPreferences.getInstance();
    _isInited = true;
    _count = _prefs.getInt('count') ?? 0;
  }

  Future<Todo> createNew() async {
    _count++;
    await _prefs.setInt('count', _count);
    return Todo(
      uuid: _uuid.v4(),
      title: 'new todo #$_count',
      description: '',
      createDt: DateTime.now(),
      isDone: false,
    );
  }

  Future<List<Todo>> getAll() async {
    final res = _prefs.getString('todos');
    if (res == null) {
      return [];
    }
    final t = jsonDecode(res);
    return [...t].map((x) => Todo.fromJson(x)).toList();
  }

  Future<void> save(List<Todo> todos) async {
    if (_saveTimer != null) {
      _saveTimer?.cancel();
      _saveTimer = null;
    }
    _saveTimer = Timer(Duration.zero, () async {
      await _prefs.setString('todos', jsonEncode(todos));
    });
  }
}
