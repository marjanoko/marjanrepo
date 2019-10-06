import 'package:flutter/material.dart';
import 'layout_useradministration.dart';
import 'dart:async';
import 'dart:convert';
import 'globalvar.dart';
import 'package:http/http.dart' as http;
import 'models/model_user.dart';

class UserlistScreen extends StatefulWidget{
  @override
  _UserlistScreenState createState() => _UserlistScreenState();
}

class _UserlistScreenState extends State<UserlistScreen>{

  TextEditingController editingController = TextEditingController();

  void filterSearchResults(String query) {
    List<User> dummySearchList = List<User>();
    dummySearchList.addAll(duplicateItems);
    if(query.isNotEmpty) {
      List<User> dummyListData = List<User>();
      dummySearchList.forEach((item) {
        if(item.firstname.contains(query)
        ||item.loginid.contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        listOfUsers.clear();
        listOfUsers.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        listOfUsers.clear();
        listOfUsers.addAll(duplicateItems);
      });
    }
  }

  List<User> listOfUsers;
  List<User> duplicateItems = new List<User>();
  Future<List<User>> _fetchUsers() async {
    var response = await http.get("http://"+SERVER_NAME+"/getusers.php");
    if (response.statusCode == 200) {
      setState(() {
        final items = json.decode(response.body).cast<Map<String, dynamic>>();
        listOfUsers = items.map<User>((json) {
          return User.fromJson(json);
        }).toList();
      });
      return listOfUsers;
    } else {
      throw Exception('Failed to load internet');
    }
  }

  @override
  void initState() {
    _fetchUsers();
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: new AppBar(
        title: Text("User List"),
        backgroundColor: Colors.green[HeaderMenuColor],// lebih satur
        actions: <Widget>[
          IconButton(icon: Icon(Icons.add), onPressed: () {
            User objNewUser = new User();
            objNewUser.id = 0;
            Navigator.push(context, MaterialPageRoute(builder: (context)=> new UserAdministrationScreen(objUser: objNewUser)));
          })
        ],
      ),
      backgroundColor: Colors.green[BackgroundColor],// lebih terangan dikit
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: TextField(
                onChanged: (value) {
                  filterSearchResults(value);
                },
                controller: editingController,
                decoration: InputDecoration(
                    labelText: "Search",
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)))),
              ),
            ),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(color: Colors.black26),
                padding: EdgeInsets.all(30.0),
                shrinkWrap: true,
                itemCount: listOfUsers == null ? 0 : listOfUsers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: new CircleAvatar(
                      backgroundImage:
                      new NetworkImage("http://"+SERVER_NAME+"/"+listOfUsers[index].picturepath),
                    ),
                    title: Text(listOfUsers[index].loginid+" ("+listOfUsers[index].firstname+")"),
                    subtitle: Text(listOfUsers[index].role+" , active:"+listOfUsers[index].isActive),
                    trailing: Icon(Icons.edit),
                    onTap: (){
                      int selectedId = listOfUsers[index].id;
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> new UserAdministrationScreen(objUser: listOfUsers[index])));
                      },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}