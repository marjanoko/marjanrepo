import 'package:flutter/material.dart';
import 'layout_userlistscreen.dart';
import 'layout_phonebook.dart';
import 'dart:async';
import 'dart:convert';
import 'globalvar.dart';
import 'package:http/http.dart' as http;
import 'models/model_user.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sms/sms.dart';
import 'models/model_userlog.dart';
import 'models/helper_dblite.dart';
import 'package:sqflite/sqflite.dart';
import 'package:date_format/date_format.dart';

class UserAdministrationScreen extends StatefulWidget{
  final User objUser;
  UserAdministrationScreen({this.objUser});
  @override
  _UserAdministrationScreenState createState() => _UserAdministrationScreenState(this.objUser);
}

class _UserAdministrationScreenState extends State<UserAdministrationScreen> {

  User theUser;
  _UserAdministrationScreenState(this.theUser);
  GlobalKey<FormState> _formKey =  GlobalKey<FormState>();
  DbHelper dbHelper = DbHelper();

  Future<List> _addData(User objTempUser) async {
    int resultdb = -1;
    final response = await http.post("http://"+SERVER_NAME+"/adduser.php", body: {
      "first_name": "",
      "last_name": "",
      "email": objTempUser.email,
      "gender": "",
      "role": objTempUser.role,
      "login_id": objTempUser.loginid,
      "phone_no": objTempUser.loginid,
    });

    var responseJson = json.decode(response.body);
    if(responseJson.length>0){
      if(responseJson[0]['result'] == "SUCCESS"){
        showToast((responseJson[0]['result']+":"+responseJson[0]['message']).toString());
        //Navigator.push(context, MaterialPageRoute(builder: (context)=> UserlistScreen()));
        final String formattedStr = formatDate(new DateTime.now(), [dd, '.', mm, '.', yy, ' ', HH, ':', nn]);
        UserLog log = UserLog(objTempUser.loginid,"data ditambahkan",formattedStr);
        resultdb = await dbHelper.insert(log); 
      }
      else{
        showToast((responseJson[0]['result']+":"+responseJson[0]['message']).toString());
      }
      Navigator.push(context, MaterialPageRoute(builder: (context)=> UserlistScreen()));
    }
    return responseJson;
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
    int resultdb = -1;
    if(responseJson.length>0){
      if(responseJson[0]['result'] == "SUCCESS"){
        showToast((responseJson[0]['result']+":"+responseJson[0]['message']).toString());
        final String formattedStr = formatDate(new DateTime.now(), [dd, '.', mm, '.', yy, ' ', HH, ':', nn]);
        UserLog log = UserLog(objTempUser.loginid,"data diupdate",formattedStr);
        resultdb = await dbHelper.insert(log);        
      }else{
        showToast((responseJson[0]['result']+":"+responseJson[0]['message']).toString());
      }
      print("db result = "+resultdb.toString());
      Navigator.push(context, MaterialPageRoute(builder: (context)=> UserlistScreen()));
    }
    return responseJson;
  }
  Future<List> _deleteData(User objTempUser) async {
    int resultdb = -1;
    final response = await http.post("http://"+SERVER_NAME+"/deleteuser.php", body: {
      "user_id": objTempUser.id.toString()
    });
    var responseJson = json.decode(response.body);
    if(responseJson.length>0){
      if(responseJson[0]['result'] == "SUCCESS"){
        showToast((responseJson[0]['result']+":"+responseJson[0]['message']).toString());
        final String formattedStr = formatDate(new DateTime.now(), [dd, '.', mm, '.', yy, ' ', HH, ':', nn]);
        UserLog log = UserLog(objTempUser.loginid,"data dihapus",formattedStr);
        resultdb = await dbHelper.insert(log);
      }else{
        showToast((responseJson[0]['result']+":"+responseJson[0]['message']).toString());
      }
      Navigator.push(context, MaterialPageRoute(builder: (context)=> UserlistScreen()));
    }
    return responseJson;
  }

  List<String> roleList = ["ADMIN","USER"];
  String roleSelected = "USER";
  void listOnChange(String value){
    setState(() {
      roleSelected = value;
    });
  }

  showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white
    );
  }

  void _showDeleteDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete User'),
            content: Text('Delete '+theUser.loginid+' from database?'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel')),
              FlatButton(
                onPressed: () {
                  _deleteData(theUser);
                },
                child: Text('OK'),
              )
            ],
          );
        });
  }

  TextEditingController txtMessageController = TextEditingController();
  void _displayMessagingDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('SEND MESSAGE:'),
          content: TextField(
            controller: txtMessageController,
            decoration: InputDecoration(hintText: "Type message here"),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('SEND'),
              onPressed: () {
                sendMessage();
              },
            ),
            new FlatButton(
              child: new Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      });
  }
  void sendMessage() async{
    SimCardsProvider provider = SimCardsProvider();
    var cards = await provider.getSimCards();
    SimCard card = cards[0];
    SmsSender sender = SmsSender();
    SmsMessage msg = SmsMessage(theUser.phoneno,txtMessageController.text);
    sender.sendSms(msg,simCard: card);
    showToast("Message sent..");
  }

  void _showContactListDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Find In Contact List'),
            content: Text('Not available phone no for user '+theUser.loginid+'. Find at phone book?'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel')),
              FlatButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> new PhoneBookScreen()));
                },
                child: Text('OK'),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      //key: _formKey,
      appBar: new AppBar(
        title: Text("Input User"),
        backgroundColor: Colors.green[HeaderMenuColor],// lebih satur
        actions: <Widget>[
          IconButton(icon: Icon(Icons.message), onPressed: () {
            if(theUser.phoneno != null){
              if(theUser.phoneno.trim() != ""){
                _displayMessagingDialog(context);
              } else
                showToast("Phone no not available");
            }else
              showToast("Phone no not available");
          }),
          IconButton(icon: Icon(Icons.call), onPressed: () {
            if(theUser.phoneno != null){
              if(theUser.phoneno != ""){
                launch("tel://"+theUser.phoneno);
              } else
                _showContactListDialog();
            }else
              showToast("Phone no not available");
          })
        ]
      ),
      backgroundColor: Colors.green[BackgroundColor],// lebih terangan dikit
      body: Container(
          padding:
          const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Builder(
              builder: (context) => Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          initialValue: theUser.loginid,
                          decoration:
                          InputDecoration(labelText: 'Login ID'),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter user login id';
                            }
                          },
                          onSaved: (val) =>
                              setState(() => theUser.loginid = val),
                        ),
                        TextFormField(
                          initialValue: theUser.email,
                            decoration:
                            InputDecoration(labelText: 'Email'),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter user email.';
                              }
                            },
                            onSaved: (val) =>
                                setState(() => theUser.email = val)
                        ),
                        FormField(
                          builder: (FormFieldState state) {
                            return InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Role',
                              ),
                              isEmpty: theUser.role == '',
                              child: new DropdownButtonHideUnderline(
                                child: new DropdownButton(
                                  value: theUser.role,
                                  isDense: true,
                                  onChanged: (String val){
                                    setState(() =>
                                    theUser.role = val);
                                  },
                                  items: roleList.map((String val){
                                    return DropdownMenuItem(
                                      value: val,
                                      child: Row(
                                        children: <Widget>[
                                          Icon(Icons.person),
                                          Text(val),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),
                        /*Container(
                          padding: const EdgeInsets.fromLTRB(0, 50, 0, 20),
                          child: Text('Status'),
                        ),*/
                        CheckboxListTile(
                            title: const Text('Active status'),
                            value: theUser.isActive == "Y"?true:false,
                            onChanged: (val) {
                              setState(() =>
                              theUser.isActive = (val == true? "Y":"N"));
                            }
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
                                      onPressed: (){
                                        final form = _formKey.currentState;
                                        if (form.validate()) {
                                          form.save();
                                          //_showDialog(context,"Submitting data");
                                          if(theUser.id>0){
                                            _editData( theUser);
                                          }
                                          else{
                                            _addData( theUser);
                                          }
                                        }
                                      }
                                  )
                              ),
                              Container(width: 5.0),//spasi antar tombol
                              Expanded(
                                  child: RaisedButton(
                                      color: Theme.of(context).primaryColorDark,
                                      textColor: Theme.of(context).primaryColorLight,
                                      child: Text('Delete',textScaleFactor: 1.5),
                                      onPressed: (){_showDeleteDialog();}
                                  )
                              )
                            ],
                          ),
                        ),
                      ]
                  )
              )
          )
      ),
    );
  }
}