import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user_profile_model.dart';

class LocalUserDB {
  static Database? _db;

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'user_profile.db');

    // SOLO PARA DESARROLLO TEMPORAL:
    //await deleteDatabase(path); // Esto borra la base de datos actual


    return openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute('''
        CREATE TABLE user_profile(
        uid TEXT PRIMARY KEY,
        email TEXT,
        display_name TEXT,
        phone_number TEXT,
        profile_image_url TEXT,
        local_image_path TEXT,
        earned_points INTEGER,
        device_model TEXT)
      ''');
    });
  }

  static Future<Database> getDb() async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<void> saveUserProfile(UserProfile profile) async {
    final db = await getDb();
    await db.insert('user_profile', profile.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<UserProfile?> getUserProfile(String uid) async {
    final db = await getDb();
    final result =
        await db.query('user_profile', where: 'uid = ?', whereArgs: [uid]);
    if (result.isNotEmpty) {
      return UserProfile.fromMap(result.first);
    }
    return null;
  }

  static Future<void> deleteUserProfile(String uid) async {
    final db = await getDb();
    await db.delete('user_profile', where: 'uid = ?', whereArgs: [uid]);
  }
}
