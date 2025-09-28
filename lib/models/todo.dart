import 'package:intl/intl.dart';
import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final String uuid;
  final String title;
  final String description;
  final DateTime createDt;
  final bool isDone;

  String get formattedDateCreate =>
      DateFormat('dd.MM.yyyy HH:mm').format(createDt);

  const Todo({
    required this.uuid,
    required this.title,
    required this.description,
    required this.createDt,
    required this.isDone,
  });

  factory Todo.fromJson(Map<String, dynamic> data) {
    return Todo(
      uuid: data['uuid'],
      title: data['title'],
      description: data['description'],
      createDt: DateTime.parse(data['createDt'] as String),
      isDone: data['isDone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'title': title,
      'description': description,
      'createDt': createDt.toIso8601String(),
      'isDone': isDone,
    };
  }

  Todo copyWith({
    String? uuid,
    String? title,
    String? description,
    DateTime? createDt,
    bool? isDone,
  }) {
    return Todo(
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      description: description ?? this.description,
      createDt: createDt ?? this.createDt,
      isDone: isDone ?? this.isDone,
    );
  }

  @override
  List<Object?> get props => [uuid, title, description, createDt, isDone];
}
