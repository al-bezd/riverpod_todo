import 'package:collection/collection.dart';
import 'package:riverpod_todo/models/todo.dart';
import 'package:riverpod_todo/repositories/todo_repo.dart';
import 'package:hooks_riverpod/legacy.dart';

final todoListProvider = StateNotifierProvider((ref) {
  final todosVM = TodoListNotifier(
    UnmodifiableListView([]),
    todoRepository: TodoRepository(),
  );
  todosVM.init();
  return todosVM;
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
  Todo add() {
    final newItem = todoRepository.createNew();
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
