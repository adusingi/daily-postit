class Task {
  final int? id;
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
    int? id,
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
    return Task(
      id: map['id'],
      content: map['content'],
      date: map['date'],
      isDone: map['is_done'] == 1,
      hiddenText: map['hidden_text'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, content: $content, date: $date, isDone: $isDone)';
  }
}
