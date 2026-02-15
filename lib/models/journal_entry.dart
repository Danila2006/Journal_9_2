import 'tag.dart';

class JournalEntry {
  final int? id;
  final String title;
  final String content;
  final String mood;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final int wordCount;
  final List<Tag> tags;

  JournalEntry({
    this.id,
    required this.title,
    required this.content,
    required this.mood,
    required this.createdAt,
    required this.updatedAt,
    required this.isFavorite,
    required this.wordCount,
    this.tags = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'mood': mood,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_favorite': isFavorite ? 1 : 0,
      'word_count': wordCount,
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      mood: map['mood'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      isFavorite: map['is_favorite'] == 1,
      wordCount: map['word_count'],
    );
  }
}
