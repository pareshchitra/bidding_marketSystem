import 'dart:io';

import 'package:bidding_market/models/user.dart';
import 'package:bidding_market/screens/authenticate/authenticate.dart';
import 'package:bidding_market/screens/authenticate/phone_auth.dart';
import 'package:bidding_market/screens/authenticate/sign_in.dart';
import 'package:bidding_market/screens/registeration/registerDetails.dart';
import 'package:bidding_market/screens/home/home.dart';
import 'package:bidding_market/screens/registeration/registerMobile.dart';
import 'package:bidding_market/services/database.dart';
import 'package:bidding_market/services/language_constants.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bidding_market/main.dart';



class Wrapper extends StatelessWidget {

  DatabaseService dbConnection = DatabaseService();

  @override
  Widget build(BuildContext context) {


  /*  final user = Provider.of<User>(context);

    dbConnection.initialLoggedUserCheck();
    sleep(Duration(seconds: 1));

    // return either the Home or Authenticate widget
    if (user == null){
      return Authenticate();
      // Navigator.push(context, MaterialPageRoute(
      //     builder: (context) => Authenticate()
      // ));
    } else {

      // var documents =  dbConnection.dbPhoneCollection.getDocuments();
      // bool register = true;
      // await documents.then((snapshot) {
      //   snapshot.documents.forEach((result) {
      //     if(user.uid.compareTo(result.data["Uid"]) == 0)
      //       {
      //         register = false;
      //       }
      // if(loggedUser.type == 0) {
      //   dbConnection.initialLoggedUserCheck();
      //   sleep(Duration(seconds: 1));
      // }
      if(loggedUser.type == 0) //New User
      {
        print("New User");
        return RegisterDetails();
        // Navigator.push(context, MaterialPageRoute(
        //     builder: (context) => RegisterDetails()
        // ));
      }
      else //Registered User
        {
          print("Old User");
        return Home();
          // Navigator.push(context, MaterialPageRoute(
          //     builder: (context) => Home()
          // ));
      }
    }
    */
    //final provider = Provider.of<PhoneAuthDataProvider>(context , listen: false);
   final user = Provider.of<User>(context);

   print("Inside Wrapper");
   print("user status $user");


   if(user == null)
     {
       return SignIn();
     }
   else
     {
       return FutureBuilder(
           future: dbConnection.checkIfUserExists(user.uid),
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      print(snapshot);
      int userExists = snapshot.data;
      print("Snapshot of user exits : $userExists");

      if (!snapshot.hasData) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
              child: Text(
                toBeginningOfSentenceCase(getTranslated(context, "loading_key")) + "...",
                style: TextStyle(
                  fontFamily: "Montesserat",
                  fontWeight: FontWeight.w700,
                  fontSize: 40.0,
                  fontStyle: FontStyle.italic,
                ),
              )),
        );
      }


      if(userExists == 1 || userExists == 2)
        return Home();
      else
        return RegisterDetails(user: null);
    });


        dbConnection.initialLoggedUserCheck();
        sleep(Duration(seconds: 1));

        // if(loggedUser.type == 0) //New User
        //     {
        //   print("New User");
        //   return RegisterDetails();
        //   // Navigator.push(context, MaterialPageRoute(
        //   //     builder: (context) => RegisterDetails()
        //   // ));
        // }
        // else //Registered User
        //     {
          print("Old User");
          return Home();
          // Navigator.push(context, MaterialPageRoute(
          //     builder: (context) => Home()
          // ));
       // }
     }



  }
}