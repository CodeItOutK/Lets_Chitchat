import 'dart:developer';
import 'dart:io';

import 'package:chat_app/models/UIhelper.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../models/UserModel.dart';

class CompleteProfile extends StatefulWidget {

  final UserModel userModel;
  final User firebaseUser;

  const CompleteProfile({super.key, required this.userModel, required this.firebaseUser});
//now we can construct our completeProfile page using this constructor also



  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {

  File? imageFile;
  TextEditingController fullNameController = TextEditingController();



  void selectImage(ImageSource source)async{
    XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if(pickedFile != null){
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file)async{
   CroppedFile? croppedImage =  await ImageCropper().cropImage(
     sourcePath: file.path,
     aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
     compressQuality: 20,
   ) ;

   if(croppedImage != null){
     setState(() {
       imageFile = File(croppedImage.path);
     });
   }

  }


  void showPhotoOptions(){
    showDialog(context: context, builder:(context){
      return  AlertDialog(
        title : Text("Upload Profile Picture"),
        content: Column(
          mainAxisSize: MainAxisSize.min, //so that our dialog box of choices is not expanding
          children: [
            ListTile(
              onTap : (){
                Navigator.pop(context); //to remove the dialog box showing options now
                selectImage(ImageSource.gallery);
              },
              leading : Icon(Icons.photo_album),
              title: Text("Select from gallery"),
            ),
            ListTile(
              onTap: (){
                Navigator.pop(context);
                selectImage(ImageSource.camera);
              },
              leading: Icon(Icons.camera_alt),
              title: Text("Take a Photo"),
            ),
          ],
        ),
      );
    });
  }


  void checkValues(){
    String fullname = fullNameController.text.trim();

    if(fullname==""  || imageFile == null){
      UIHelper.showAlertDialogue(context,"Incomplete Data", "Please fill all details and upload profile picture");
    }

    else{
      log("uploading data...");
      uploadData(); //upload the data on firestore
    }
  }

  // Future<void> upload_image(var reference) async {
  //   reference.putFile(imageFile! as File);
  // }

  void uploadData()async{
    log("dialog now");
    UIHelper.showLoadingDialogue(context, "Uploading Image...");

    log("1");
    // TaskSnapshot snapshot= await FirebaseStorage.instance.ref("profilepic").child(widget.userModel.uid.toString()).putFile(imageFile! as File);

    UploadTask uploadTask = FirebaseStorage.instance.ref("profilepictures").child(widget.userModel.uid.toString()).putFile(imageFile!);

//This will store our imageFile into the folder of "profilepictures" with the name of user id

     TaskSnapshot snapshot = await  uploadTask ;
    log("3");
    String imageURL = await snapshot.ref.getDownloadURL();
    log("4");
    String fullname= fullNameController.text.trim();
    log("5");
    widget.userModel.fullname = fullname;
    log("6");
    widget.userModel.profilepic = imageURL;
    log("7");
    await FirebaseFirestore.instance.collection("users").doc(widget.userModel.uid).set(widget.userModel.ToMap()).then((value){
      log("Data uploaded");
      log("8");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.push(context, MaterialPageRoute(
          builder: (context){
            return HomePage(userModel: widget.userModel, firebaseUser: widget.firebaseUser);
          }
      ));
    }

    );
  }


  @override
  void initState() {
    super.initState();
    setUpFirebase();
  }

  void setUpFirebase() async {
    await Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Complete Profile"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: ListView(
            children: [

              SizedBox(height: 20),

              CupertinoButton(
                onPressed: () {
                  showPhotoOptions();
                },
                padding: EdgeInsets.all(0),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: (imageFile!=null)?FileImage(imageFile!):null,
                  child: (imageFile==null)?Icon(Icons.person,size: 60) : null,
                ),
              ),

              SizedBox(height: 20),

              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                ),
              ),

              SizedBox(height: 20),

              CupertinoButton(
                color: Theme.of(context).colorScheme.secondary,
                  child: Text("Submit"),
                  onPressed: (){
                  checkValues();
                  }
              ),

            ],
          ),
        ),
      ),
    );
  }
}
