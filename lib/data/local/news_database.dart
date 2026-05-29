import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class NewsDBHelper {
  NewsDBHelper._();

  static NewsDBHelper getInstance(){
    return NewsDBHelper._();
  }

  Database? mDb;

  static const String newsTableName = "news";
  static const String newsID = "n_id";
  static const String newsTitle = "n_title";
  static const String newsImage = "n_image";
  static const String newsSource = "n_source";
  static const String newsDate = "n_date";
  static const String newsUrl = "n_url";

  Future<Database> initDB() async {
    mDb = mDb ?? await openDB();
    return mDb!;
  }

  Future<Database> openDB() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDocDir.path, "newsDB.db");
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) {db.execute(''' CREATE TABLE $newsTableName($newsID INTEGER PRIMARY KEY AUTOINCREMENT,$newsTitle TEXT UNIQUE,$newsImage TEXT,$newsSource TEXT,$newsDate TEXT,$newsUrl TEXT ) ''');},
    );
  }

  Future<bool> insertNews({required String title, required String image, required String source, required String date,required String url}) async {
    var db = await initDB();
    int rows = await db.insert(newsTableName, {
      newsTitle: title,
      newsImage: image,
      newsSource: source,
      newsDate: date,
      newsUrl: url,
    },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return rows > 0;
  }

  Future<List<Map<String,dynamic>>> fetchAllNews() async {
    var db = await initDB();
    return await db.query(
      newsTableName,
      orderBy: "$newsDate DESC",
    );
  }

  Future<bool> deleteAllNews() async {
    var db = await initDB();
    int rows = await db.delete(newsTableName);
    return rows > 0;
  }
}