import 'dart:io';

import 'package:bidding_market/main.dart';
import 'package:bidding_market/models/user.dart';
import 'package:bidding_market/screens/authenticate/authenticate.dart';
import 'package:bidding_market/screens/registeration/BuyerForm.dart';
import 'package:bidding_market/screens/registeration/SellerForm.dart';
import 'package:bidding_market/screens/registeration/registerDetails.dart';
import 'package:bidding_market/services/auth.dart';
import 'package:bidding_market/services/language_constants.dart';
import 'package:bidding_market/shared/nav-drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Profile extends StatefulWidget {
  final User user;
  Profile(this.user);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthService _auth = AuthService();

  // //Translated values
  // User _translatedUser = new User();
  //
  // void _getTranslatedValues(BuildContext context)
  // {
  //   _translatedUser.Name = widget.user.Name;
  //   _translatedUser.Village = widget.user.Village;
  //   _translatedUser.District = widget.user.District;
  //   _translatedUser.State = widget.user.State;
  //
  //   getTranslatedOnline(context, _translatedUser.Name, "0").then((
  //       value) =>
  //       setState(() {
  //         _translatedUser.Name = value;
  //       }));
  //   getTranslatedOnline(context, _translatedUser.Village, "0").then((
  //       value) =>
  //       setState(() {
  //         _translatedUser.Village = value;
  //       }));
  //   getTranslatedOnline(context, _translatedUser.District, "0").then((
  //       value) =>
  //       setState(() {
  //         _translatedUser.District = value;
  //       }));
  //   getTranslatedOnline(context, _translatedUser.State, "0").then((
  //       value) =>
  //       setState(() {
  //         _translatedUser.State = value;
  //       }));
  // }
  //
  // @override
  // // ignore: must_call_super
  // void didChangeDependencies() {
  //   //super.initState();
  //   _getTranslatedValues(context);
  // }

  @override
  Widget build(BuildContext context) {
    String type;
    if(widget.user.type == 2)
      type = "Farmer";
    else
      type = "Buyer";
    return Scaffold(
        drawer: NavDrawer(),
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(toBeginningOfSentenceCase(getTranslated(context, "my_profile_key"))),
          backgroundColor: Colors.green[700],
          elevation: 0.0,
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.person),
              label: Text(getTranslated(context, "logout_key")),
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
                          "${widget.user.photo}"
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
                widget.user.Name + "  (" + toBeginningOfSentenceCase(getTranslated(context, (type.toLowerCase() + "_key"))) + ")"
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
                widget.user.Village + ", " + widget.user.District
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
                toBeginningOfSentenceCase(getTranslated(context, "state_key")) + " : " + widget.user.State
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
                "${widget.user.Pincode}"
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
                toBeginningOfSentenceCase(getTranslated(context, "contact_key")) + " : ${widget.user.PhoneNo}"
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
                          getTranslated(context, "update_key").toUpperCase(),
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
                          getTranslated(context, "remove_account_key").toUpperCase(),
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