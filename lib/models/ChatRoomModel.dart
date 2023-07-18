import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel{
  String? chatroomid;
  Map<String,dynamic>? participants;
  String? lastMsg;
  DateTime? chatTime;
  List<dynamic>? users;

  ChatRoomModel({this.chatroomid,this.participants,this.lastMsg,this.chatTime,this.users});

  ChatRoomModel.fromMap(Map<String,dynamic>map){
    chatroomid = map["chatroomid"];
    participants = map["participants"];
    lastMsg = map['lastMsg'];
    chatTime = map["chatTime"].toDate();
    users = map['users'];
  }

  Map<String,dynamic> ToMap(){
    return{
      "chatroomid" : chatroomid,
      "participants" : participants,
      "lastMsg" : lastMsg,
      "chatTime" : chatTime,
      "users" : users
    };
  }

}