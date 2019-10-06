import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'globalvar.dart';
import 'package:http/http.dart' as http;
import 'models/model_user.dart';

class UserPictureScreen extends StatefulWidget{
  final User objUser;
  UserPictureScreen({this.objUser});
  @override
  _UserPictureScreenState createState() => _UserPictureScreenState(this.objUser);
}

class _UserPictureScreenState extends State<UserPictureScreen> {
  User theUser ;//= new User();
  _UserPictureScreenState(this.theUser);

  Future<int> _getData(User objTempUser) async {
    final response = await http.post("http://"+SERVER_NAME+"/getuserbyid.php", body: {
      "id": objTempUser.id.toString()
    });
    if (response.statusCode == 200) {
      setState(() {
        final items = json.decode(response.body).cast<Map<String, dynamic>>();
        List<User> listOfUsers = items.map<User>((json) {
          return User.fromJson(json);
        }).toList();
        //print(listOfUsers.toString());
        theUser = listOfUsers[0];
        print(theUser.role);
      });
      return 1;
    } else {
      throw Exception('Failed to load internet');
    }
  }
  Future<int> _uploadPhoto(User objTempUser) async {
    final response = await http.post("http://"+SERVER_NAME+"/uploadphotouser.php", body: {
      "uid": objTempUser.id.toString(),
      "image": base64Image,
      "filename":fileName
    });
    if (response.statusCode == 200) {
      setState(() {
        final items = json.decode(response.body).cast<Map<String, dynamic>>();
        List<User> listOfUsers = items.map<User>((json) {
          return User.fromJson(json);
        }).toList();
        //print(listOfUsers.toString());
        theUser = listOfUsers[0];
        print(theUser.role);
      });
      return 1;
    } else {
      throw Exception('Failed to load internet');
    }
  }

  Future<File> file;
  String fileName = '';
  String base64Image;
  File tmpFile;
  String errMessage = 'Error Uploading Image';
  Future _openCamera() async{
    var myImage = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );
    setState(() {
      tmpFile = myImage;
      base64Image = base64Encode(tmpFile.readAsBytesSync());
      fileName = tmpFile.path.split('/').last;
    });
  }
  Future _openGallery() async{
    var myImage = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      tmpFile = myImage;
      base64Image = base64Encode(tmpFile.readAsBytesSync());
      fileName = tmpFile.path.split('/').last;
    });
  }
  chooseImage() {
    setState(() {
      file = ImagePicker.pickImage(source: ImageSource.gallery);
    });
  }

  @override
  void initState() {
    //items.addAll(duplicateItems);
    _getData(theUser);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: Text("Profile"),
          backgroundColor: Colors.green[HeaderMenuColor],// lebih satur
          actions: <Widget>[
            IconButton(icon: Icon(Icons.cloud_upload), onPressed: () {
              _uploadPhoto(theUser);
            })
          ],
        ),
        backgroundColor: Colors.green[BackgroundColor],// lebih terangan dikit

        body: Padding(
          padding: EdgeInsets.only(top: 6.0,left: 10.0,right: 10.0),
          child: ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: new Stack(fit: StackFit.loose, children: <Widget>[
                  new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Container(
                          width: 140.0,
                          height: 140.0,
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            image: new DecorationImage(
                              //image: NetworkImage(theUser.picturepath),
                              //image: new FileImage(tmpFile),
                              image: tmpFile == null?new ExactAssetImage('assets/images/as.png'):new FileImage(tmpFile),
                              fit: BoxFit.cover,
                            ),
                          )
                      ),
                    ],
                  ),
                ]),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 50, 0, 20),
                child: Text(''),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: RaisedButton(
                            color: Theme.of(context).primaryColorDark,
                            textColor: Theme.of(context).primaryColorLight,
                            child: Text('Gallery',textScaleFactor: 1.5),
                            onPressed: (){_openGallery();}
                        )
                    ),
                    Container(width: 5.0),//spasi antar tombol
                    Expanded(
                        child: RaisedButton(
                            color: Theme.of(context).primaryColorDark,
                            textColor: Theme.of(context).primaryColorLight,
                            child: Text('Camera',textScaleFactor: 1.5),
                            onPressed: (){_openCamera();}
                        )
                    )
                  ],
                ),
              )
            ],
          ),
        )
    );
  }

}
