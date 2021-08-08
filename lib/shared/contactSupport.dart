import 'package:bidding_market/services/language_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContactSupport extends StatelessWidget {
  //const ContactSupport({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
