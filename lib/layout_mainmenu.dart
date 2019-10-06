import 'package:flutter/material.dart';
import 'layout_userprofile.dart';
import 'layout_userlistscreen.dart';
import 'models/model_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'layout_userlogs.dart';
import 'globalvar.dart';
import 'layout_musicplayer.dart';

class MainMenu extends StatefulWidget{
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu>{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: new AppBar(
        title: Text("Menu Utama"),
        backgroundColor: Colors.green[HeaderMenuColor],// lebih satur
      ),
      backgroundColor: Colors.green[BackgroundColor],// lebih terangan dikit

      drawer: new Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: new Text("Jokonthil", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),),
              accountEmail: new Text("tralala@trilili.com"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage("https://jagad.id/wp-content/uploads/2018/06/Kesaktian-Semar-Mesem-Menurut-Islam-Yang-Sebenarnya.jpg"),
              ),
              decoration: new BoxDecoration(color: Colors.green[700]),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("PROFILE"),
              onTap: (){
                User objUser = new User();
                objUser.id = 1;
                Navigator.push(context, MaterialPageRoute(builder: (context)=> new UserProfileScreen(objUser: objUser)));
                },
            ),
            ListTile(
              leading: Icon(Icons.vpn_key),
              title: Text("Ubah Password"),
            ),
            ListTile(
              leading: Icon(Icons.event_note),
              title: Text("Logs"),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> new UserLogScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("Exit"),
            )
          ],
        ),
      ),

      body: Container(
        padding: EdgeInsets.all(30.0),
        child: GridView.count(
          crossAxisCount: 2,
          children: <Widget>[
            MyMenu(titleMenu: "CRUD User",iconMenu: Icons.person,warnaMenu: Colors.orange,keyMenu: "us"),
            MyMenu(titleMenu: "Mp3 Player",iconMenu: Icons.music_note,warnaMenu: Colors.red,keyMenu: "vd",),
            MyMenu(titleMenu: "Mbuh",iconMenu: Icons.gps_fixed,warnaMenu: Colors.blue,keyMenu: "nr"),
          ],
        ),
      ),
    );
  }
}

class MyMenu extends StatelessWidget{
  MyMenu({this.titleMenu,this.iconMenu,this.warnaMenu,this.keyMenu});

  final String titleMenu;
  final IconData iconMenu;
  final MaterialColor warnaMenu;
  final String keyMenu;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: (){
          //showAlertDialog(context);
          if(keyMenu == "vd")
            Navigator.push(context, MaterialPageRoute(builder: (context)=> new AudioScreen()));
          else if(keyMenu == "us")
            Navigator.push(context, MaterialPageRoute(builder: (context)=> UserlistScreen()));
        },
        splashColor: Colors.green,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(iconMenu,size: 70.0,color: warnaMenu,),
              Text(titleMenu, style: new TextStyle(fontSize: 15.0,),textAlign: TextAlign.center,)
            ],
          ),
        ),
      ),
    );
  }
}