import 'package:flutter/material.dart';
import 'globalvar.dart';
import 'models/model_userlog.dart';
import 'models/helper_dblite.dart';
import 'package:sqflite/sqflite.dart';

class UserLogScreen extends StatefulWidget{
  @override
  _UserLogScreenState createState() => _UserLogScreenState();
}

class _UserLogScreenState extends State<UserLogScreen>{
DbHelper dbHelper = DbHelper();
int count = 0;
List<UserLog> userLogList;

void getLogList(){
  final Future<Database> dbFuture = dbHelper.initDB();
  dbFuture.then((database){
    Future<List<UserLog>> logListFuture = dbHelper.getUserLogs();
    logListFuture.then((logList){
      setState(() {
       this.userLogList = logList;
       this.count = logList.length; 
      });
    });
  });
}

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text("User logs - Local"),
        backgroundColor: Colors.green[HeaderMenuColor],// lebih satur
      ),
      backgroundColor: Colors.green[BackgroundColor],// lebih terangan dikit
      body: FutureBuilder<List<UserLog>>(
        future: dbHelper.getUserLogs(),
        builder: (BuildContext context, AsyncSnapshot<List<UserLog>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                UserLog item = snapshot.data[index];
                return Dismissible(
                  key: UniqueKey(),
                  background: Container(color: Colors.red),
                  child: ListTile(
                    title: Text(item.activity??''),
                    leading: Text(item.logTime??''),
                    trailing: Text(item.loginId??''),
                  ),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      )
    );
  }
}