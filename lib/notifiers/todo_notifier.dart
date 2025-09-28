import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_todo/models/todo.dart';
import 'package:riverpod_todo/repositories/todo_repo.dart';
import 'package:hooks_riverpod/legacy.dart';

final todoListProvider = StateNotifierProvider((ref) {
  return TodoListNotifier(
    UnmodifiableListView([]),
    todoRepository: TodoRepository(),
  )..init();
});

final todoItemProvider = Provider.family<Todo?, String>((ref, uuid) {
  final todos = ref.watch(todoListProvider);
  return todos.firstWhereOrNull((todo) => todo.uuid == uuid);
});

class TodoListNotifier extends StateNotifier<UnmodifiableListView<Todo>> {
  TodoListNotifier(super.state, {required this.todoRepository});

  final TodoRepository todoRepository;
  final Map<String, Todo> _todosMap = {};
  UnmodifiableListView<Todo> get todos =>
      UnmodifiableListView(_todosMap.values);

  Future<void> init() async {
    await todoRepository.init();
    final res = await todoRepository.getAll();
    for (final todo in res) {
      _todosMap[todo.uuid] = todo;
    }
    _emit();
  }

  /// Добавление новой туду
  Future<Todo> createNew() async {
    final newItem = await todoRepository.createNew();
    _todosMap[newItem.uuid] = newItem;
    _emit();
    return newItem;
  }

  /// Удаление туду
  void remove(String uuid) {
    if (_todosMap.containsKey(uuid)) {
      _todosMap.remove(uuid);
      _emit();
    }
  }

  /// Обновление существующего туду
  void updateTodo(Todo updatedTodo) {
    if (_todosMap.containsKey(updatedTodo.uuid)) {
      _todosMap[updatedTodo.uuid] = updatedTodo;
      _emit();
    }
  }

  /// Переключение isDone
  void toggleIsDone(String uuid) {
    final todo = _todosMap[uuid];
    if (todo != null) {
      _todosMap[uuid] = todo.copyWith(isDone: !todo.isDone);
      _emit();
    }
  }

  void _emit() {
    state = UnmodifiableListView(_todosMap.values);
    todoRepository.save(todos);
  }
}
