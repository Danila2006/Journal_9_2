import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/journal_entry.dart';
import '../models/tag.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'journal.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE journal_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        mood TEXT,
        created_at TEXT,
        updated_at TEXT,
        is_favorite INTEGER,
        word_count INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE,
        color TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE entry_tags (
        entry_id INTEGER,
        tag_id INTEGER,
        FOREIGN KEY (entry_id) REFERENCES journal_entries(id),
        FOREIGN KEY (tag_id) REFERENCES tags(id)
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_entries_created_at ON journal_entries(created_at)');
    await db.execute(
        'CREATE INDEX idx_entries_mood ON journal_entries(mood)');
    await db.execute('CREATE INDEX idx_tags_name ON tags(name)');
  }

  Future<void> insertEntry(JournalEntry entry) async {
    final db = await database;

    await db.transaction((txn) async {
      final entryId = await txn.insert('journal_entries', entry.toMap());

      for (var tag in entry.tags) {
        await txn.insert('entry_tags', {
          'entry_id': entryId,
          'tag_id': tag.id,
        });
      }
    });
  }

  Future<List<JournalEntry>> getEntries() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT e.*, t.id as tag_id, t.name, t.color, t.created_at as tag_created
      FROM journal_entries e
      LEFT JOIN entry_tags et ON e.id = et.entry_id
      LEFT JOIN tags t ON t.id = et.tag_id
      ORDER BY e.created_at DESC
    ''');

    Map<int, JournalEntry> entriesMap = {};

    for (var row in result) {
      final entryId = row['id'] as int;

      if (!entriesMap.containsKey(entryId)) {
        entriesMap[entryId] = JournalEntry.fromMap(row);
      }

      if (row['tag_id'] != null) {
        final tag = Tag(
          id: row['tag_id'] as int,
          name: row['name'] as String,
          color: row['color'] as String,
          createdAt: DateTime.parse(row['tag_created'] as String),
        );

        entriesMap[entryId]!.tags.add(tag);
      }
    }

    return entriesMap.values.toList();
  }

  Future<List<JournalEntry>> search(String query) async {
    final db = await database;

    final result = await db.query(
      'journal_entries',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return result.map((e) => JournalEntry.fromMap(e)).toList();
  }

  Future<void> updateEntry(JournalEntry entry) async {
    final db = await database;

    await db.update(
      'journal_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<void> deleteEntry(int id) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete('entry_tags', where: 'entry_id = ?', whereArgs: [id]);
      await txn.delete('journal_entries', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<int> insertTag(Tag tag) async {
    final db = await database;
    return await db.insert('tags', tag.toMap());
  }

  Future<List<Tag>> getTags() async {
    final db = await database;
    final result = await db.query('tags');
    return result.map((e) => Tag.fromMap(e)).toList();
  }

  Future<List<Map<String, dynamic>>> moodBreakdown() async {
    final db = await database;

    return await db.rawQuery('''
      SELECT mood, COUNT(*) as count
      FROM journal_entries
      GROUP BY mood
    ''');
  }
}
