import 'dart:developer';

import 'package:chat_app/models/Firebasehelper.dart';
import 'package:chat_app/models/UserModel.dart';
import 'package:chat_app/pages/CompleteProfile.dart';
import 'package:chat_app/pages/LoginPage.dart';
import 'package:chat_app/pages/SignUpPage.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'firebase_options.dart';

var uuid = Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // runApp(const MyApp());
  User? currentUser = FirebaseAuth.instance.currentUser;
  //we are not logged in then-
  if(currentUser==null){
    runApp(MyApp());
  }
  else{
    //We are already logged in then-
    UserModel? thisUsermodel =await  FirebaseHelper.getUserModelByUId(currentUser!.uid);
    if(thisUsermodel!=null){
      runApp(MyAppLoggedIn(userModel: thisUsermodel, firebaseUser: currentUser));
    }
    else{
      runApp(MyApp());
    }
  }

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppLoggedIn({super.key, required this.userModel, required this.firebaseUser});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      debugShowCheckedModeBanner: false,
      home: HomePage(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}

