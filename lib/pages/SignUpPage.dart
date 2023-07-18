import 'dart:developer';

import 'package:chat_app/models/UIhelper.dart';
import 'package:chat_app/models/UserModel.dart';
import 'package:chat_app/pages/CompleteProfile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();

  void checkValues(){
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cPassword = cPasswordController.text.trim();

    if(email=="" || password=="" || cPassword==""){
      print("Please fill all the fields");

      UIHelper.showAlertDialogue(context,"Incomplete Data", "Please fill all the fields");
    }
    else if(password != cPassword){
      print("Passwords do not match!");
      UIHelper.showAlertDialogue(context, "Password mismatch", "Passwords you filled are not matching!");


    }
    else{
      signup(email, password);
    }
  }


  void signup(String email,String password) async {

    UIHelper.showLoadingDialogue(context,"Creating New Account...");

    UserCredential? credential;
    try{
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    }on FirebaseAuthException catch(exp){
      Navigator.pop(context);
      UIHelper.showAlertDialogue(context, "AN error occurred", exp.message.toString());

    }

    if(credential != null){
      String uid = credential.user!.uid;

      UserModel newUser = UserModel(
        email: email,
        profilepic: "",
        uid : uid,
        fullname: "",
      );

      await FirebaseFirestore.instance.collection("users").doc(uid).set(newUser.ToMap()).then((value) {
        print("new user created");
        Navigator.popUntil(
            context, (route) => route.isFirst);
        Navigator.pushReplacement(context,
        MaterialPageRoute(
        builder: (context){
          return CompleteProfile(userModel: newUser, firebaseUser: credential!.user!);
        }
        )
        );

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text("Chat App",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
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
                  SizedBox(height: 10),

                  TextField(
                    controller: cPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                    ),
                  ),

                  SizedBox(height: 20),

                  CupertinoButton(
                    color: Theme.of(context).colorScheme.secondary,
                      child: Text("Sign Up" ),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Already have an account?",
            style: TextStyle(
              fontSize: 16,
            ),
            ),

            CupertinoButton(
                child: Text("Log In",
                style: TextStyle(
                  fontSize: 16,
                ),
                ),
                onPressed: (){
                  Navigator.pop(context);//Sign up pg will come only when you have already been through login pg so we just need to pop this screen to reach back to our log in pg

                }
            ),
          ],
        ),
      ),
    );
  }
}
