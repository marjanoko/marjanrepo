import 'package:flutter/material.dart';
import 'dart:async';
import 'layout_mainmenu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget{
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>{
  String welcome = "";
  @override
  void initState(){
    super.initState();
    Future.delayed(
      Duration(seconds: 1),
        (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=> MainMenu()));
        },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: new Color(0xff622F74),
              gradient: LinearGradient(colors: [new Color(0xff6094e8),new Color(0xffde5cbc)],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft)
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 75.0,
                child: Icon(
                  Icons.beach_access,
                  color: Colors.deepOrange,
                  size: 50.0,
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 10.0)),
              Text(
                "Ambyyaarrrrr...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}