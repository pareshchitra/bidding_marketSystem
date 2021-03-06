import 'dart:async';
import 'dart:io';
import 'package:bidding_market/models/user.dart';
import 'package:bidding_market/screens/home/home.dart';
import 'package:bidding_market/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:bidding_market/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  final FirebaseAuth.FirebaseAuth _auth = FirebaseAuth.FirebaseAuth.instance;
  DatabaseService dbConnection = DatabaseService();

  // create user obj based on firebase user
  User _userFromFirebaseUser(FirebaseAuth.User user) {
    return user != null ? User(uid: user.uid ) : null;
  }

  // auth change user stream
  // void createGuiStream () {
  //   guiController = StreamController<int>();
  //   guiController.add(states.home as int);
  // }
  Stream<User> get user {
    return _auth.onAuthStateChanged
    //.map((FirebaseUser user) => _userFromFirebaseUser(user));
        .map(_userFromFirebaseUser);
  }

  // sign in anon
  // Future signInAnon() async {
  //   try {
  //     AuthResult result = await _auth.signInAnonymously();
  //     FirebaseUser user = result.user;
  //     return _userFromFirebaseUser(user);
  //   } catch (e) {
  //     print(e.toString());
  //     return null;
  //   }
  // }

  // sign in with email and password
  // Future signInWithEmailAndPassword(String email, String password) async {
  //   try {
  //     AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
  //     FirebaseUser user = result.user;
  //     return user;
  //   } catch (error) {
  //     print(error.toString());
  //     return null;
  //   }
  // }

  //sign in with mobile number
  final _codeController = TextEditingController();
  Future signInWithMobileNumber(String phone, BuildContext context) async{

    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (FirebaseAuth.AuthCredential credential) async{
          print("Entering verificationCompleted flow of signIn");
          //Navigator.of(context).pop();

          await dbConnection.checkIfPhoneExists(phone);
          print("Status of user $loggedUser.type");

          FirebaseAuth.UserCredential result = await _auth.signInWithCredential(credential);
          //print("After first signInWithCredential");
          FirebaseAuth.User user = result.user;
          int type;
          if(user != null){
            loggedUser.uid = user.uid;
            // Navigator.push(context, MaterialPageRoute(
            //     builder: (context) => Home()
            // ));

            //loggedUser.type = await dbConnection.checkIfUserExists(user.uid);
            await dbConnection.updatePhoneData(phone, user.uid, 1);
          }else{
            print("Error");
          }
          print("Before returning from authentication");
          return _userFromFirebaseUser(user);
          //This callback would gets called when verification is done automatically
        },
        verificationFailed: (FirebaseAuth.FirebaseAuthException exception){
          print(exception.message);
        },
        codeSent: (String verificationId, [int forceResendingToken]){
          print("Entering codeSent flow of signIn");
          sleep(Duration(seconds:1));
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: Text("Give the code?"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: _codeController,
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    FlatButton(onPressed: ()
                      {
                        Navigator.of(context).pop();
                    }, child: Text("Cancel"),
                      textColor: Colors.white,
                      color: Colors.blue,),
                    FlatButton(
                      child: Text("Confirm"),
                      textColor: Colors.white,
                      color: Colors.blue,
                      onPressed: () async {
                        final code = _codeController.text.trim();
                        FirebaseAuth.AuthCredential credential = FirebaseAuth.PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code);
                        //print("Before second signInWithCredential call");

                        //print("Going to check phoneNumber in DB");

                        //await dbConnection.checkIfPhoneExists(phone);
                        print("Status of user ${loggedUser.type}");

                        FirebaseAuth.UserCredential result = await _auth.signInWithCredential(credential);
                        //print("After second signInWithCredential call");
                        FirebaseAuth.User user = result.user;
                        print("Inside codeSent: user is $user");

                        if(user != null){
                          loggedUser.uid = user.uid;
                          loggedUser.PhoneNo = phone;
                          //loggedUser.type = await dbConnection.checkIfUserExists(user.uid);
                          print("Logged user type changed to $loggedUser.type");

                          // Navigator.push(context, MaterialPageRoute(
                          //     builder: (context) => Home()
                         // ));
                        Navigator.of(context).pop();
                        await dbConnection.updatePhoneData(phone, user.uid, 1);
                        }else{

                          print("Error");
                        }
                        print("Before returning from authentication");
                        return _userFromFirebaseUser(user);
                      },
                    )
                  ],
                );
              }
          );
        },
        codeAutoRetrievalTimeout: null
    );

  }

  // register with email and password
  // Future registerWithEmailAndPassword(String email, String password) async {
  //   try {
  //     AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
  //     FirebaseUser user = result.user;
  //     // create a new document for the user with the uid
  //     await DatabaseService(uid: user.uid).updateUserData('0','new crew member', 100);
  //     return _userFromFirebaseUser(user);
  //   } catch (error) {
  //     print(error.toString());
  //     return null;
  //   }
  // }

  // sign out
  Future signOut() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('PhoneNo');
      prefs.remove('RegisterState');
      prefs.commit();
      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

}