
import 'package:flutter/material.dart';

class UIHelper{

  static void showLoadingDialogue(BuildContext context,String Title){

    AlertDialog loadingDialogue = AlertDialog(
      content: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),

            SizedBox(height: 30),

            Text(Title),
          ],
        ),
      ),
    );

    showDialog(
      barrierDismissible: false,  //on clicking outside now dialog will not be removed
        context: context,
        builder: (context){
          return loadingDialogue;
        }
      );

  }


  static void showAlertDialogue(BuildContext context,String title,String content){
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
            onPressed: (){
                Navigator.pop(context);
            },
            child: Text('OK'),
        )
      ],
    );

    showDialog(context: context, builder: (context){
      return alertDialog;
    });
  }

}