class User {
  int id;
  String loginid;
  String firstname;
  String lastname;
  String email;
  String gender;
  String regdate;
  String role;
  String isActive;
  String phoneno;
  num altitude;
  num longtude;
  String picturepath;
  String editeddate;

  User({
    this.id,
    this.loginid,
    this.firstname,
    this.lastname,
    this.email,
    this.gender,
    this.regdate,
    this.role,
    this.isActive,
    this.phoneno,
    this.altitude,
    this.longtude,
    this.picturepath,
    this.editeddate
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'] as int,
        loginid: json['login_id'],
        firstname: json['first_name'],
        lastname: json['last_name'],
        email: json['email'],
        gender: json['gender'],
        regdate: json['reg_date'] as String,
        role: json['role'],
        isActive: json['is_Active'],
        phoneno: json['phone_no'],
        altitude: json['altitude'] as num,
        longtude: json['longtude'] as num,
        picturepath: json['picture_path'],
        editeddate: json['edited_date'] as String
    );
  }
}