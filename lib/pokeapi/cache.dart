import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PokeAPICache {
  static const _tableName = 'PokeApiCache';
  final String _path;
  final Database _db;

  PokeAPICache._(this._path, this._db);

  static Future<PokeAPICache> init() async {
    final dbPath = join(await getDatabasesPath(), "pokeapi_cache.db");
    final db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE $_tableName(url TEXT PRIMARY KEY, data TEXT)",
        );
      },
    );

    return PokeAPICache._(dbPath, db);
  }

  Future<void> insert(String url, String value) async {
    await _db.transaction((txn) async {
      await txn.rawInsert(
        'INSERT OR REPLACE INTO $_tableName(url, data) VALUES(?, ?)',
        [url, value],
      );
    });
  }

  Future<bool> contains(String url) async {
    return await get(url) != null;
  }

  Future<String?> get(String url) async {
    final List<Map<String, dynamic>> result = await _db.query(
      _tableName,
      columns: ['data'],
      where: 'url = ?',
      whereArgs: [url],
    );
    return result.isNotEmpty ? result.first['data'] as String : null;
  }
}
