import 'dart:developer';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/ChatRoomModel.dart';
import 'package:chat_app/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ChatRoomPage.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage({super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?>getChatRoomModel (UserModel targetUser) async {
    ChatRoomModel? chatroom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("chatrooms").where("participants.${widget.userModel.uid}",isEqualTo: true).
  where("participants.${targetUser.uid}",isEqualTo: true).get();

    if(snapshot.docs.length>0){
      //Fetch already created chatroom
      log("Chatroom already exists");
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroomModel = ChatRoomModel.fromMap(docData as Map<String,dynamic>);
      chatroom = existingChatroomModel;
    }
    else{
      //Create a new chatroom
      log("Chatroom does not exist");
      ChatRoomModel newChatroom = ChatRoomModel(
        chatroomid : uuid.v1(),
        lastMsg: "",
        participants: {
          widget.userModel.uid.toString() : true,
          targetUser.uid.toString() : true,
        },
        users: [widget.userModel.uid.toString(),targetUser.uid.toString()],
        chatTime: DateTime.now(),
      );
      await FirebaseFirestore.instance.collection("chatrooms").doc(newChatroom.chatroomid).set(newChatroom.ToMap());
      chatroom = newChatroom;
      log("new chatroom created now");
    }
    return chatroom;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
      ),
      body:SafeArea(
        child: Container(
          padding:EdgeInsets.symmetric(horizontal: 10,vertical: 15),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: "Email Address",
                ),
              ),
              SizedBox(height: 20),
              CupertinoButton(
                onPressed: (){
                  setState(() {});
                },
                  child: Text('Search'),
                  color: Theme.of(context).colorScheme.secondary,
              ),

              SizedBox(height: 20),

              StreamBuilder(
                stream: FirebaseFirestore.instance.collection("users").where("email",isEqualTo: searchController.text.toString().trim()).where
                  ("email",isNotEqualTo: widget.userModel.email).snapshots(),
                builder: ( context, snapshot) {
                  if(snapshot.connectionState==ConnectionState.active){
                    log("start");

                    if(snapshot.hasData){
                      log("1");
                      QuerySnapshot dataSnap = snapshot.data as QuerySnapshot;
                      log("2");
                      log(snapshot.toString());
                      if(dataSnap.docs.isNotEmpty){
                        log("3");
                        log(dataSnap.docs.length.toString());
                        log(dataSnap.docs.first.data().toString());
                        Map<String,dynamic> userMap = dataSnap.docs[0].data() as Map<String,dynamic>;
                        log(userMap.toString());
                        UserModel searchedUser =  UserModel.fromMap(userMap);
                        log(searchedUser.fullname.toString()+" "+searchedUser.email.toString());
                        return ListTile(
                          onTap: () async {

                            ChatRoomModel? chatroomModel = await getChatRoomModel(searchedUser);
                            if(chatroomModel!=null){
                              Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context){
                                    return ChatRoomPage(
                                      targetUser: searchedUser,
                                      userModel: widget.userModel,
                                      firebaseUser: widget.firebaseUser,
                                      chatroom: chatroomModel,
                                    );
                                  }
                               )
                              );
                            }
                          },
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(searchedUser.profilepic!),
                            backgroundColor: Colors.grey[500],
                          ),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          title: Text(searchedUser.fullname!),
                          subtitle: Text(searchedUser.email.toString()),
                        );
                      }
                      else {
                        return Text("No result found");
                      }
                    }
                    else if(snapshot.hasError){
                      return Text("Some error occured");
                    }
                    else{
                      return Text("No result found");
                    }

                  }
                  else{
                    return CircularProgressIndicator();
                  }
                },

              ),

            ],
          ),

        ),
      ),
    );
  }
}
