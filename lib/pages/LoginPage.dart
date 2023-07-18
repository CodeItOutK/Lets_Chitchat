import 'dart:developer';

import 'package:chat_app/models/UIhelper.dart';
import 'package:chat_app/models/UserModel.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'SignUpPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkValues(){
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if(email=="" || password==""){
      print("Please fill all the fields");
      UIHelper.showAlertDialogue(context,"Incomplete Data", "Please fill all the fields");

    }

    else{
      login(email, password);
    }
  }

  void login(String email,String password) async {
    UIHelper.showLoadingDialogue(context, "Logging In...");
    UserCredential? credential;
    try{
      credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

    }on FirebaseAuthException catch(ex){
      Navigator.pop(context); //to remove loading dialogue
      // print(ex.toString());
      UIHelper.showAlertDialogue(context,"An error occurred", ex.message.toString());
    }

    if(credential != null){
      String uid = credential.user!.uid;
//User already has an account hence they are logging in so their details are already stored we just need to fetch those details
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection("users").doc(uid).get();
      UserModel userModel = UserModel.fromMap(userData.data() as Map<String,dynamic>);

      //Go to Home Page
      log("login successful");
      Navigator.popUntil(context, (route) => route.isFirst); //to remove back button on new pg
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: ( context){
            return HomePage(userModel: userModel, firebaseUser: credential!.user!);
          }
      ));

    }



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Center(
            child : SingleChildScrollView(
              child: Column(
                children: [
                  Text("Chat App",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10),

                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email Address",
                    ),
                  ),

                  SizedBox(height: 10),

                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                    ),
                  ),

                  SizedBox(height: 20),

                  CupertinoButton(
                    color: Theme.of(context).colorScheme.secondary,
                      child: Text("Log In"),
                      onPressed: (){
                      checkValues();
                      }
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        child : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Don't have an account?",
              style: TextStyle(
                fontSize: 16,
              ) ,
            ),

            CupertinoButton(
                child: Text("Sign Up"),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context)=>SignUpPage()
                  ));
                }
            ),
          ],
        ),
      ),
    );
  }
}
