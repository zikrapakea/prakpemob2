import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // Dipanggil saat database baru dibuat (struktur terbaru / versi 3).
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT,
        category TEXT NOT NULL DEFAULT 'Pribadi',
        color INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // Dipanggil saat versi database naik (data lama tetap aman).
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE notes ADD COLUMN created_at TEXT');
    }
    if (oldVersion < 3) {
      await db.execute(
          "ALTER TABLE notes ADD COLUMN category TEXT NOT NULL DEFAULT 'Pribadi'");
      await db.execute(
          'ALTER TABLE notes ADD COLUMN color INTEGER NOT NULL DEFAULT 0');
    }
  }

  // CREATE
  Future<int> insert(Note note) async {
    final db = await instance.database;
    return await db.insert('notes', note.toMap());
  }

  // READ (+ pencarian LIKE dan filter kategori)
  Future<List<Note>> getNotes({String keyword = '', String? category}) async {
    final db = await instance.database;
    final where = <String>[];
    final args = <Object>[];

    final key = keyword.trim();
    if (key.isNotEmpty) {
      where.add('(title LIKE ? OR content LIKE ?)');
      args.addAll(['%$key%', '%$key%']);
    }
    if (category != null) {
      where.add('category = ?');
      args.add(category);
    }

    final result = await db.query(
      'notes',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'id DESC',
    );
    return result.map((e) => Note.fromMap(e)).toList();
  }

  // UPDATE
  Future<int> update(Note note) async {
    final db = await instance.database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // DELETE
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
