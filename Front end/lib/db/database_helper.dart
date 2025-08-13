import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/post_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();


  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'pose_analysis.db');
    return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
          CREATE TABLE poses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            keypointsJson TEXT,
            timestamp TEXT,
            imagePath TEXT,
            imageUrl TEXT
          )
        ''');
          await db.execute('''
          CREATE TABLE errors (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            message TEXT,
            type TEXT,
            timestamp TEXT
          )
        ''');
        }
    );
  }

  Future<List<PoseEntry>> getAllPoseEntries() async {
    final db = await database;
    final maps = await db.query('poses', orderBy: 'timestamp DESC');
    return maps.map((e) => PoseEntry.fromMap(e)).toList();
  }

  Future<void> insertPoseEntry(PoseEntry entry) async {
    final db = await database;
    await db.insert('poses', entry.toMap());
  }

  // Future<void> insertErrorLog(ErrorLog log) async {
  //   final db = await database;
  //   await db.insert('errors', log.toMap());
  // }
  //
  // Future<List<ErrorLog>> getAllErrors() async {
  //   final db = await database;
  //   final maps = await db.query('errors', orderBy: 'timestamp DESC');
  //   return maps.map((e) => ErrorLog.fromMap(e)).toList();
  // }
}