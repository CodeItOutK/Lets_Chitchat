import 'package:chat_app/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel{
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdon;
  String? messageId;

  MessageModel({this.sender,this.text,this.seen,this.createdon,this.messageId});
//Creating object from map
  MessageModel.FromMap(Map<String,dynamic>map){
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    createdon = (map["createdon"]as Timestamp).toDate();
    messageId = map["messageId"];
  }
//Converting object to map
  Map<String,dynamic> ToMap(){
    return{
      "sender" : sender,
      "text" : text,
      "seen" : seen,
      "createdon" : createdon,
      "messageId" : messageId,
    };
  }

}