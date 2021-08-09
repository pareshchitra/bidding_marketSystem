import 'package:bidding_market/services/language_constants.dart';
import 'package:bidding_market/shared/nav-drawer.dart';
import 'package:bidding_market/services/auth.dart';
import 'package:bidding_market/screens/authenticate/authenticate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContactSupport extends StatelessWidget {
  //const ContactSupport({Key key}) : super(key: key);
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(toBeginningOfSentenceCase(getTranslated(context, "contact_us_key"))),
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
      body: Container(
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          Text(toBeginningOfSentenceCase(getTranslated(context, "reach_us_key"))),
          SizedBox(height: 20,),
          Text(toBeginningOfSentenceCase(getTranslated(context, "contact_key"))),
          SizedBox(height: 10,),
          Row(
            children: <Widget>[
              InkWell(
              child: Text("9871561883", style: TextStyle(color: Colors.blue[400])),
              onTap: () {
                launch("tel:+91 9871561883");
              },

              ),
              SizedBox(width: 20,),
              InkWell(
                child: FaIcon(FontAwesomeIcons.whatsapp),
                onTap: () {
                  launch("https://wa.me/+919871561883");
                },
              )
            ],
          ),
          SizedBox(height: 10,),
          Row(
            children: <Widget>[
              InkWell(
                child: Text("9672298812", style: TextStyle(color: Colors.blue[400])),
                onTap: () {
                  launch("tel:+91 9672298812");
                },

              ),
              SizedBox(width: 20,),
              InkWell(
                child: FaIcon(FontAwesomeIcons.whatsapp),
                onTap: () {
                  launch("https://wa.me/+919672298812");
                },
              )
            ],
          ),
          SizedBox(height: 30,),
          Text(toBeginningOfSentenceCase(getTranslated(context, "address_key"))),
          SizedBox(height: 20,),
          Text(toBeginningOfSentenceCase(getTranslated(context, "office_address_key_1"))),
          SizedBox(height: 10,),
          Text(toBeginningOfSentenceCase(getTranslated(context, "office_address_key_2")) + "-322001"),
        ],
      ),
    ));
  }
}
