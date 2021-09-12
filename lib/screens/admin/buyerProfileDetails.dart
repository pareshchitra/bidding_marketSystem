import 'dart:io';

import 'package:bidding_market/main.dart';
import 'package:bidding_market/models/user.dart';
import 'package:bidding_market/screens/authenticate/authenticate.dart';
import 'package:bidding_market/screens/registeration/BuyerForm.dart';
import 'package:bidding_market/screens/registeration/SellerForm.dart';
import 'package:bidding_market/screens/registeration/registerDetails.dart';
import 'package:bidding_market/services/auth.dart';
import 'package:bidding_market/services/database.dart';
import 'package:bidding_market/services/language_constants.dart';
import 'package:bidding_market/shared/nav-drawer.dart';
import 'package:bidding_market/shared/sharedPrefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class BuyerProfileDetails extends StatefulWidget {
  final String userId;
  BuyerProfileDetails({this.userId});

  @override
  _BuyerProfileDetailsState createState() => _BuyerProfileDetailsState(userId: userId);
}

class _BuyerProfileDetailsState extends State<BuyerProfileDetails> {
  final AuthService _auth = AuthService();
  final String userId;
  User user;
  String _phoneNo;
  _BuyerProfileDetailsState({this.userId});

  DatabaseService  dbConnection = DatabaseService();

  @override
  void initState() {
    super.initState();
    getPhoneNo(userId);
  }

  Future<String> getPhoneNo (String userId) async
  {
    print("getPhoneNo called with userId $userId");
    String phone = await dbConnection.getUserPhoneNo(userId);

    setState(() {
        _phoneNo = phone;
    });
  }

  @override
  Widget build(BuildContext context) {

    String type;
    // if(widget.user.type == 2)
    //   type = "Farmer";
    // else if(widget.user.type == 1)
    //   type = "Buyer";
    // else if(widget.user.type == 3)
    //   type = "Admin";
    return Scaffold(
        drawer: NavDrawer(),
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(toBeginningOfSentenceCase(getTranslated(context, "buyer_details_key"))),
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
        body: userListener()
    );
  }

  Widget userListener() {
    return StreamBuilder(
        stream: dbConnection.dbBuyerCollection.doc(userId).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          print("Snapshot is " + snapshot.toString());
          //productsList.addAll(snapshot.data);

          if (!snapshot.hasData) {
            return Center(
                child: Text(
                  toBeginningOfSentenceCase(
                      getTranslated(context, "loading_key")) + "...",
                  style: TextStyle(
                    fontFamily: "Montesserat",
                    fontWeight: FontWeight.w700,
                    fontSize: 40.0,
                    fontStyle: FontStyle.italic,
                  ),
                ));
          }

          if (snapshot.hasData) {
            var snapshotData = snapshot.data.data();
            print("Snapshot ID is ${snapshot.data.id} ${snapshot.data.exists}");
            print("Snapshot Data is $snapshotData");

              //Future<String> phoneNo =  dbConnection.getUserPhoneNo(document.id);
                  user = new User();
                  user.Name = snapshotData["Name"];
                  user.District = snapshotData["District"];
                  user.State = snapshotData["State"];
                  user.Village = snapshotData["Village"];
                  user.Pincode = snapshotData["Pincode"];
                  user.uid = snapshot.data.id;
                  //TODO : PHOTO AND PHONENO OF BUYER
                  user.idFrontURL = snapshotData["IdFrontUrl"];
                  user.idBackURL = snapshotData["IdBackUrl"];
                  user.HouseNo = snapshotData["HouseNo"];
                  user.AadharNo = snapshotData["AadharNo"];
                  user.isVerified = snapshotData["IsVerified"];
            }

          return userDetails();
        });
  }

  Widget userDetails()
  {
    return SafeArea(
      child: Column(

        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.grey
            ),
            child: Container(
              width: double.infinity,
              height: 150,
              child: Container(
                  alignment: Alignment(0.0,4.5),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Colors.green[500],
                        ),
                        height: 200.0,
                        width: 200.0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),

                          child: (user.idFrontURL != null && user.idBackURL != "" ) ? Image.network(
                            "${user.idFrontURL}" ,
                            fit: BoxFit.cover,
                          ) : Center(child: Text(getTranslated(context, "no_image_key"))),
                        ),
                      ),
                      SizedBox(width: 5.0,),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Colors.green[500],
                        ),
                        height: 200.0,
                        width: 200.0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),

                          child:( user.idBackURL != null && user.idBackURL != "" ) ? Image.network(
                            "${user.idBackURL}" ,
                            fit: BoxFit.cover,
                          ) : Center(child: Text(getTranslated(context, "no_image_key"))),
                        ),
                      ),
                    ],
                  )

              ),
            ),
          ),

          SizedBox(
            height: 60,
          ),
          Text(
            user.Name
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
          ) ,
          SizedBox(
            height: 10,
          ),
          Text(
            toBeginningOfSentenceCase(getTranslated(context, "state_key")) + " : " + user.State
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
            toBeginningOfSentenceCase(getTranslated(context, "contact_key")) + " : $_phoneNo"
            ,style: TextStyle(
              fontSize: 18.0,
              color:Colors.black45,
              letterSpacing: 2.0,
              fontWeight: FontWeight.w300
          ),
          ) ,
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                toBeginningOfSentenceCase(getTranslated(context, "verified_key")) + " : "
                ,style: TextStyle(
                  fontSize: 18.0,
                  color:Colors.black45,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w300
              ),
              ),
              (user.isVerified) ? Icon(Icons.check, size: 15.0,) : Icon(Icons.close, size: 15.0)
            ],
          ) ,

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
              ),

              RaisedButton(
                onPressed: (){
                  (user.isVerified) ? null : verifyAccount(context);
                },
                disabledColor: Colors.grey,
                disabledTextColor: Colors.black54,
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
                      getTranslated(context, "verify_account_key").toUpperCase(),
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
    );
  }

  verifyAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(toBeginningOfSentenceCase(getTranslated(context, "alert_dialog_key"))),
          content: Text(toBeginningOfSentenceCase(getTranslated(context, "verify_account_confirm_key"))),
          actions: <Widget>[
            FlatButton(
              child: Text(getTranslated(context, "yes_key").toUpperCase()),
              onPressed: () async{
                Navigator.of(context).pop();
                //await dbConnection.deleteProduct(p);
                await dbConnection.verifyBuyer(userId);
                setState(() {    });
              },
            ),

            FlatButton(
              child: Text(getTranslated(context, "no_key").toUpperCase()),
              onPressed: () {

                Navigator.of(context).pop();
              },
            ),

          ],
        );
      },
    );
  }
}