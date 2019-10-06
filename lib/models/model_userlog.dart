class UserLog{
  int _id;
  String _loginId;
  String _activity;
  String _logTime;

  UserLog(this._loginId,this._activity,this._logTime);
  UserLog.fromMap(Map<String,dynamic> map){
    this._id = map['id'];
    this._loginId = map['loginId'];
    this._activity = map['activity'];
    this._logTime = map['logTime'];
  }

  //getter
  int get id => _id;
  String get loginId => _loginId;
  String get activity => _activity;
  String get logTime => _logTime;

  //SETTER
  set loginId(String value){
    _loginId = value;
  }
  set activity(String value){
    _activity = value;
  }
  set logTime(String value){
    _logTime = value;
  }

  Map<String,dynamic> toMap(){
    Map<String,dynamic> map = Map<String,dynamic>();
    map['id'] = this._id;
    map['loginId'] = loginId== null?"":loginId;
    map['activity'] = activity== null?"":activity;
    map['logTime'] = logTime == null?"":logTime;
    return map;
  }
}