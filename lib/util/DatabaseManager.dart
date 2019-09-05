import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:music_app/models/FavouriteModel.dart';

class DatabaseManager{

  final String favouriteTable = 'FavouriteTable';
  final String columnIndex = 'indexCol';
  final String columnTitle = 'title';
  final String columnAlbum = 'album';
  final String columnArtist = 'artist';
  final String columnUrl = 'url';
  final String columnImg = 'img';
  final String columnDuration = 'duration';

  static Database database;

  // للتأكد منن ان الداتابيز موجوده ولا لا
  // لو موجده هاتها لو مش موجوده اعملها
  Future<Database> get db async{
    if(database != null)
      return database;
    database = await initDatabase();
    return database;
  }

  initDatabase() async{
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, "favourite.db");
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async{
    var sql = "CREATE TABLE $favouriteTable ($columnIndex INTEGER PRIMARY KEY ,"
        " $columnTitle TEXT, $columnAlbum TEXT, $columnArtist TEXT, $columnUrl Text, $columnImg TEXT, $columnDuration INTEGER)";
    await db.execute(sql);
  }

  Future<int> addSong(FavouriteModel favourite) async{
    var dbClient = await db;
    int result = await dbClient.insert(favouriteTable, favourite.toMap());
    return result;
  }

  Future<List> getAllSongs() async{
    var dbClient = await db;
    String sql = "SELECT * FROM $favouriteTable";
    List result = await dbClient.rawQuery(sql);
    return result.toList();
  }

  Future<int> getCountSongs() async{
    var dbClient = await db;
    String sql = "SELECT COUNT(*) FROM $favouriteTable";
    return Sqflite.firstIntValue(await dbClient.rawQuery(sql));
  }

  Future<FavouriteModel> getCustomSong(int index) async{
    var dbClient = await db;
    var sql = "SELECT * FROM $favouriteTable WHERE $columnIndex= $index";
    var result = await dbClient.rawQuery(sql);

    if(result.length == 0)
      return null;

    return FavouriteModel.fromMap(result.first);
  }

  Future<int> updateSong(FavouriteModel favourite) async{
    var dbClient = await db;
    return dbClient.update(favouriteTable, favourite.toMap(), where: '$columnIndex =? ', whereArgs: [favourite.index]);
  }

  Future<void> deleteSong(int index) async{
    var dbClient = await db;
//    var sql = "DELETE * FROM $favouriteTable WHERE $columnIndex= $index";
//    var result = await dbClient.rawQuery(sql);
    return dbClient.delete(favouriteTable, where: '$columnIndex = ?', whereArgs: [index]);
//  return 1;
  }

  Future closeDb() async{
    var dbClient = await db;
    return await dbClient.close();
  }

}