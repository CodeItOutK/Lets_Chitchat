import 'package:chat_app/models/ChatRoomModel.dart';
import 'package:chat_app/models/Firebasehelper.dart';
import 'package:chat_app/models/UIhelper.dart';
import 'package:chat_app/models/UserModel.dart';
import 'package:chat_app/pages/ChatRoomPage.dart';
import 'package:chat_app/pages/LoginPage.dart';
import 'package:chat_app/pages/SearchPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomePage({super.key, required this.userModel, required this.firebaseUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat App"),
        centerTitle: true,
        actions: [
          IconButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.popUntil(
                context, (route) => route.isFirst);
            Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context)=>LoginPage()
            ));
          },
          icon: Icon(Icons.exit_to_app),
        ),
        ],
      ),
      body: Container(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("chatrooms").where
            ("users",arrayContains: widget.userModel.uid).orderBy("chatTime",descending:true).
          snapshots(),
          builder: (context,snapshot){
            if(snapshot.connectionState == ConnectionState.active){
              if(snapshot.hasData){
                QuerySnapshot chatroomSnapshot = snapshot.data as QuerySnapshot;

                return ListView.builder(
                    itemCount: chatroomSnapshot.docs.length,
                    itemBuilder: (context,index){
                      ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                        chatroomSnapshot.docs[index].data() as Map<String,dynamic>);

                      //get keys of participants (i.e ids of particip) from chat model and display all keys whose value is not ours and is of those whom we are talking to

                      Map<String, dynamic>? participants = chatRoomModel.participants;
                      List<String> participantKeys = participants!.keys.toList();
                      participantKeys.remove(widget.userModel.uid);

                      //we will use a future builder bec we will use getUserModelByID() of FirebaseHelper.dart which is a FUTURE ,to build our widget

                      return FutureBuilder(
                          future: FirebaseHelper.getUserModelByUId(participantKeys[0]),
                          builder: (context,userData){
                            if(userData.connectionState == ConnectionState.done) {
                              UserModel targetUser = userData.data as UserModel;

                              if(userData.data!=null){
                                return ListTile(
                                  onTap: (){
                                    Navigator.push(context,MaterialPageRoute(
                                        builder: (context){
                                          return ChatRoomPage(
                                              targetUser: targetUser,
                                              chatroom: chatRoomModel,
                                              userModel: widget.userModel,
                                              firebaseUser: widget.firebaseUser);
                                        }
                                    ));
                                  },
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    backgroundImage: NetworkImage(targetUser.profilepic.toString()),
                                  ),
                                  title: Text(targetUser.fullname.toString()),
                                  subtitle:(chatRoomModel.lastMsg!="")? Text(chatRoomModel.lastMsg.toString()):
                                  Text("Say hi to your new Friend",style: TextStyle(color:Theme.of(context).colorScheme.secondary),),
                                );
                              }
                              else{
                                return Container();
                              }

                            }
                            else{
                              return Container();
                            }
                          }
                      );

                    }
                );

              }
              else if(snapshot.hasError){
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
              else{
                return Center(
                  child: Text("No chats to show"),
                );
              }
            }
            else{
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
              builder: (context){
                return SearchPage(userModel: widget.userModel, firebaseUser: widget.firebaseUser);
              }
          ));
        },
        child: Icon(Icons.search),
      ),
    );
  }
}
