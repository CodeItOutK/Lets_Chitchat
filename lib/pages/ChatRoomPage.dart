import 'dart:developer';

import 'package:chat_app/models/ChatRoomModel.dart';
import 'package:chat_app/models/MessageModel.dart';
import 'package:chat_app/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';
class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomPage({Key? key, required this.targetUser, required this.chatroom, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  void sendMsg() async {
    String msg=messageController.text.trim();
    messageController.clear();

    if(msg!=""){
        MessageModel newMessage = MessageModel(
          messageId: uuid.v1(),
          sender: widget.userModel.uid,
          createdon: DateTime.now(),
          seen: false,
          text: msg
        );

        FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroom.chatroomid).collection("messages").
        doc(newMessage.messageId).set(newMessage.ToMap());

        widget.chatroom.lastMsg=msg;
        widget.chatroom.chatTime = DateTime.now();
        FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroom.chatroomid).set(widget.chatroom.ToMap());

        log("message sent!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage: NetworkImage(widget.targetUser.profilepic.toString()),
            ),

            SizedBox(width: 20),

            Text(widget.targetUser.fullname.toString()),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [

              //this is where our chat will go
              Expanded(
                child: Container(
                  //padding: EdgeInsets.symmetric(horizontal: 10),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection("chatrooms").
                    doc(widget.chatroom.chatroomid).collection("messages").orderBy("createdon",descending: true).snapshots(),
                    builder: (context,snapshot){
                      if(snapshot.connectionState==ConnectionState.active){
                        if(snapshot.hasData){
                          QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;

                          return ListView.builder(
                            reverse: true,
                            itemCount: dataSnapshot.docs.length,
                            itemBuilder: (context,index){
                              MessageModel currentMsg = MessageModel.FromMap(dataSnapshot.docs[index].data() as Map<String,dynamic>);
                              return SafeArea(
                                child: Row(
                                  mainAxisAlignment: (currentMsg.sender==widget.userModel.uid)?MainAxisAlignment.end:MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: 2),
                                      padding: EdgeInsets.symmetric(horizontal: 5,vertical: 10),

                                      decoration: BoxDecoration(
                                      color: (currentMsg.sender==widget.userModel.uid)?Colors.grey:Theme.of(context).colorScheme.secondary,
                                      borderRadius: BorderRadius.circular(5),
                                      ),
                                        child: Flexible(
                                          child: Text(
                                              currentMsg.text.toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),

                                          ),
                                        )
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                        if(snapshot.hasError){
                          return Center(
                            child: Text("An error occurred! Please check your internet connection"),
                          );
                        }
                        else{
                          return Center(
                            child: Text("Say Hi to your new friend!"),
                          );
                        }

                      }
                      else{
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
              ),

              Container(
                color: Colors.grey[200],
                padding: EdgeInsets.symmetric(
                  horizontal: 15,vertical: 5
                ),
                child:  Row(
                  children: [
                    Flexible(
                        child: TextField(
                          controller: messageController,
                          maxLines: null,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter message",
                          ),
                        ),
                    ),

                    IconButton(
                        onPressed: (){
                          sendMsg();
                        },
                        icon: Icon(Icons.send),
                      color: Theme.of(context).colorScheme.secondary,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
