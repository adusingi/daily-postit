import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String? id;
  final String content;
  final String date;
  final bool isDone;
  final String? hiddenText;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    this.id,
    required this.content,
    required this.date,
    this.isDone = false,
    this.hiddenText,
    required this.createdAt,
    required this.updatedAt,
  });

  Task copyWith({
    String? id,
    String? content,
    String? date,
    bool? isDone,
    String? hiddenText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      content: content ?? this.content,
      date: date ?? this.date,
      isDone: isDone ?? this.isDone,
      hiddenText: hiddenText ?? this.hiddenText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'date': date,
      'is_done': isDone ? 1 : 0,
      'hidden_text': hiddenText,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    final idValue = map['id'];
    final id = idValue == null ? null : idValue.toString();
    return Task(
      id: id,
      content: map['content'],
      date: map['date'],
      isDone: map['is_done'] == 1,
      hiddenText: map['hidden_text'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toFirestoreMap({String? id}) {
    return {
      if (id != null) 'id': id,
      'content': content,
      'date': date,
      'is_done': isDone,
      'hidden_text': hiddenText,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Task.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final created = data['created_at'];
    final updated = data['updated_at'];

    return Task(
      id: doc.id,
      content: data['content'] ?? '',
      date: data['date'] ?? '',
      isDone: data['is_done'] == true,
      hiddenText: data['hidden_text'],
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
      updatedAt: updated is Timestamp ? updated.toDate() : DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, content: $content, date: $date, isDone: $isDone)';
  }
}
