import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'model_userlog.dart';

class DbHelper{
  static DbHelper _dbLiteHelper;
  static Database _database;

  DbHelper._createObject();
  factory DbHelper(){
    if(_dbLiteHelper==null){
      _dbLiteHelper = DbHelper._createObject();
    }
    return _dbLiteHelper;
  }

  Future<Database> initDB() async{
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path+"userlog.db";
    var logDatabase = openDatabase(path,version:1,onCreate:_createDb);
    return logDatabase;
  }
  void _createDb(Database db, int version) async{
    await db.execute('''CREATE TABLE userlog(id INTEGER PRIMARY KEY AUTOINCREMENT,
    loginId TEXT,
    activity TEXT,
    logTime TEXT)''');
  }
  Future<Database> get database async{
    if(_database==null){
      _database = await initDB();
    }
    return _database;
  }
  Future<int> insert(UserLog obj) async{
    Database db = await this.database;
    int count = await db.insert('userlog', obj.toMap());
    return count;
  }
  Future<List<Map<String,dynamic>>> select() async{
    Database db = await this.database;
    var mapList = await db.query('userlog',orderBy: 'id');
    return mapList;
  }
  Future<List<UserLog>> getUserLogs() async{
    var logMapList = await select();
    int count = logMapList.length;
    List<UserLog> logList = List<UserLog>();
    for(int i = 0;i<count;i++){
      logList.add(UserLog.fromMap(logMapList[i]));
    }
    return logList;
  }
}