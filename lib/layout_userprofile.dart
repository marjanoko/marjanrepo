import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'layout_userpicture.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'globalvar.dart';
import 'package:http/http.dart' as http;
import 'models/model_user.dart';

class UserProfileScreen extends StatefulWidget{
  final User objUser;
  UserProfileScreen({this.objUser});
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState(this.objUser);
}

class _UserProfileScreenState extends State<UserProfileScreen> {

  User theUser ;//= new User();
  _UserProfileScreenState(this.theUser);

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController txtLoginId=new TextEditingController();
  TextEditingController txtFirstName=new TextEditingController();
  TextEditingController txtPhoneNo=new TextEditingController();
  TextEditingController txtEmail=new TextEditingController();

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
        txtLoginId.text = theUser.loginid;
        txtFirstName.text = theUser.firstname;
        txtPhoneNo.text = theUser.phoneno;
        txtEmail.text = theUser.email;
        print(theUser.role);
      });
      return 1;
    } else {
      throw Exception('Failed to load internet');
    }
  }
  Future<List> _editData(User objTempUser) async {
    final response = await http.post("http://"+SERVER_NAME+"/edituser.php", body: {
      "user_id": objTempUser.id.toString(),
      "first_name": objTempUser.firstname,
      "last_name": objTempUser.lastname,
      "email": objTempUser.email,
      "gender": objTempUser.gender,
      "role": objTempUser.role,
      "is_Active": objTempUser.isActive,
      "phone_no": objTempUser.phoneno,
    });
    var responseJson = json.decode(response.body);
    if(responseJson.length>0){
      if(responseJson[0]['result'] == "SUCCESS"){
      }else{
      }
      Navigator.pop(context);
    }
    return responseJson;
  }

  @override
  void initState() {
    _getData(theUser);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: Text("Profile"),
            backgroundColor: Colors.green[HeaderMenuColor],// lebih satur
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
                              image: theUser.picturepath == null?new ExactAssetImage('assets/images/as.png'):NetworkImage("http://"+SERVER_NAME+"/"+theUser.picturepath),
                              fit: BoxFit.cover,
                            ),
                          )
                      ),
                    ],
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 90.0, right: 100.0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 25.0,
                            child: IconButton(
                                icon:  Icon(Icons.camera_alt), onPressed: (){
                              User objUser = new User();
                              objUser.id = 1;
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> new UserPictureScreen(objUser: objUser)));
                            }
                            ),
                          )
                        ],
                      )),
                ]),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 50, 0, 20),
                child: Text(''),
              ),
              Padding(
                padding: EdgeInsets.only(top: 6.0,bottom: 10.0),
                child: TextField(
                  controller: txtLoginId,
                  enabled: false,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      labelText: 'Login id',
                  ),
                  onChanged: (value){},
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 6.0,bottom: 10.0),
                child: TextField(
                  controller: txtFirstName,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'First name',
                  ),
                  onChanged: (value){
                    setState(() => theUser.firstname = value);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
                child: TextField(
                  controller: txtPhoneNo,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                      labelText: 'Phone',
                  ),
                  onChanged: (value){
                    setState(() => theUser.phoneno = value);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
                child: TextField(
                  controller: txtEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'Email',
                  ),
                  onChanged: (value){
                    setState(() => theUser.email = value);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text('Save',textScaleFactor: 1.5),
                        onPressed: (){_editData(theUser);}
                      )
                    ),
                    Container(width: 5.0),//spasi antar tombol
                    Expanded(
                        child: RaisedButton(
                            color: Theme.of(context).primaryColorDark,
                            textColor: Theme.of(context).primaryColorLight,
                            child: Text('Cancel',textScaleFactor: 1.5),
                            onPressed: (){Navigator.pop(context);}
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