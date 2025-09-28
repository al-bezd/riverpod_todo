import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_todo/notifiers/todo_notifier.dart';
import 'package:riverpod_todo/widgets/todo_list.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Consumer(
        builder: (context, ref, _) {
          final todosVM = ref.read(todoListProvider.notifier);
          return FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () async {
              final item = await todosVM.add();
              if (!context.mounted) return;
              final res = await showModalBottomSheet(
                backgroundColor: Colors.grey[300],
                enableDrag: true,
                isScrollControlled: true,
                context: context,
                showDragHandle: true,
                builder: (context) =>
                    SingleChildScrollView(child: EditTodo(todo: item)),
              );
              if (res != null) todosVM.updateTodo(res);
            },
          );
        },
      ),
      body: const TodoList(),
    );
  }
}
