import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_todo/models/todo.dart';
import 'package:riverpod_todo/notifiers/todo_notifier.dart';

class TodoList extends ConsumerWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListProvider);
    return ListView.separated(
      itemBuilder: (context, index) {
        return TodoListItem(item: todos[index]);
      },
      separatorBuilder: (context, index) => const Divider(),
      itemCount: todos.length,
    );
  }
}

class TodoListItem extends ConsumerWidget {
  const TodoListItem({super.key, required this.item});
  final Todo item;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosVM = ref.read(todoListProvider.notifier);
    return ListTile(
      key: ValueKey(item.uuid),
      leading: IconButton(
        onPressed: () => todosVM.toggleIsDone(item.uuid),
        icon: item.isDone
            ? Icon(Icons.check_circle_outline)
            : Icon(Icons.circle_outlined),
      ),
      trailing: IconButton(
        onPressed: () => todosVM.remove(item.uuid),
        icon: Icon(Icons.remove),
      ),
      title: Text(
        item.title,
        style: TextStyle(
          decoration: item.isDone ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(
        item.description,
        overflow: TextOverflow.fade,
        maxLines: 1, // Ограничиваем одной строкой
        softWrap: false, // Отключаем перенос слов
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
      onTap: () async {
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
  }
}

class EditTodo extends StatefulWidget {
  const EditTodo({super.key, required this.todo});
  final Todo todo;
  @override
  State<StatefulWidget> createState() => _EditTodoState();
}

class _EditTodoState extends State<EditTodo> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.todo.title;
    _descriptionController.text = widget.todo.description;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        spacing: 16,
        children: [
          Column(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text('name'),
              ),
              TextField(
                controller: _nameController,
                autofocus: true,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  hintStyle: TextStyle(fontSize: 16),
                  filled: true,
                  hintText: 'name',
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text('description'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  hintStyle: TextStyle(fontSize: 16),
                  filled: true,
                  hintText: 'description',
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                maxLines: 10,
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.trim().isEmpty ||
                  _descriptionController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Title or description cannot be empty'),
                  ),
                );
                return;
              }
              final res = widget.todo.copyWith(
                description: _descriptionController.text,
                title: _nameController.text,
              );

              Navigator.of(context).pop(res);
            },
            child: Text('save'),
          ),
        ],
      ),
    );
  }
}
