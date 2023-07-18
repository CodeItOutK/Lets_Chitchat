class UserModel{
  String? uid;  //string? means the string can be null also
  String? fullname;
  String? email;
  String? profilepic;

  UserModel({this.uid,this.fullname,this.email,this.profilepic});

  //Add a construct that creates object from a Map
  UserModel.fromMap(Map<String,dynamic> map){
    uid = map["uid"];
    fullname = map["fullname"];
    email = map["email"];
    profilepic = map["profilepic"];
  }

  //Add a method that converts object TO A MAP
  Map<String,dynamic> ToMap(){
    return {
      "uid" : uid,
      "fullname" : fullname,
      "email" : email,
      "profilepic" : profilepic,
    };
  }

}