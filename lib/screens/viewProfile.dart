import 'dart:io';

import 'package:bidding_market/main.dart';
import 'package:bidding_market/models/user.dart';
import 'package:bidding_market/screens/authenticate/authenticate.dart';
import 'package:bidding_market/screens/registeration/BuyerForm.dart';
import 'package:bidding_market/screens/registeration/SellerForm.dart';
import 'package:bidding_market/screens/registeration/registerDetails.dart';
import 'package:bidding_market/services/auth.dart';
import 'package:bidding_market/shared/nav-drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  final User user;
  Profile(this.user);

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    String type;
    if(user.type == 2)
      type = "Farmer";
    else
      type = "Buyer";
    return Scaffold(
        drawer: NavDrawer(),
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('My Profile'),
          backgroundColor: Colors.green[700],
          elevation: 0.0,
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.person),
              label: Text('logout'),
              onPressed: () async {
                //Navigator.of(context).pop();
                await _auth.signOut();
                Navigator.of(context)
                    .pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => Authenticate() ), (Route<dynamic> route) => false
                );
                //PhoneAuthDataProvider().signOut();
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(

            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey
                ),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  child: Container(
                    alignment: Alignment(0.0,2.5),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                          "${user.photo}"
                      ),
                      radius: 60.0,
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 60,
              ),
              Text(
                "${user.Name}  ($type)"
                ,style: TextStyle(
                  fontSize: 25.0,
                  color:Colors.blueGrey,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w400
              ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "${user.Village}, ${user.District}"
                ,style: TextStyle(
                  fontSize: 18.0,
                  color:Colors.black45,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w300
              ),
              ),
              SizedBox(
                height: 10,
              ),

              Text(
                "State : ${user.State}"
                ,style: TextStyle(
                  fontSize: 18.0,
                  color:Colors.black45,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w300
              ),
              ),

              SizedBox(
                height: 10,
              ),
              Text(
                "${user.Pincode}"
                ,style: TextStyle(
                  fontSize: 15.0,
                  color:Colors.black45,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w300
              ),
              ),
              SizedBox(
                height: 10,
              ),

              Text(
                "Contact : ${user.PhoneNo}"
                ,style: TextStyle(
                  fontSize: 18.0,
                  color:Colors.black45,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w300
              ),
              ),

              SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RaisedButton(
                    onPressed: (){
                      // if( loggedUser.type == 1) {
                      //       buyerForm(user: loggedUser);
                      //
                      // }
                      // else if( loggedUser.type == 2) {
                      //      return sellerForm(user: loggedUser);
                      //
                      // }
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => RegisterDetails(user: loggedUser)
                      ));

                    },
                    shape:  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80.0),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Colors.pink,Colors.redAccent]
                        ),
                        borderRadius: BorderRadius.circular(30.0),

                      ),
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 100.0,maxHeight: 40.0,),
                        alignment: Alignment.center,
                        child: Text(
                          "UPDATE",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w300
                          ),
                        ),
                      ),
                    ),
                  ),
                  RaisedButton(
                    onPressed: (){

                    },
                    shape:  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80.0),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Colors.pink,Colors.redAccent]
                        ),
                        borderRadius: BorderRadius.circular(80.0),

                      ),
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 100.0,maxHeight: 40.0,),
                        alignment: Alignment.center,
                        child: Text(
                          "REMOVE ACCOUNT",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w300
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        )
    );
  }
}