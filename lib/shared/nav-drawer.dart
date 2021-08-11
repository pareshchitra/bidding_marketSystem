import 'package:bidding_market/main.dart';
import 'package:bidding_market/screens/admin/liveBidding.dart';
import 'package:bidding_market/models/user.dart';
import 'package:bidding_market/screens/authenticate/authenticate.dart';
import 'package:bidding_market/screens/home/home.dart';
import 'package:bidding_market/screens/myBids.dart';
import 'package:bidding_market/screens/myProducts.dart';
import 'package:bidding_market/screens/registeration/BuyerForm.dart';
import 'package:bidding_market/screens/registeration/SellerForm.dart';
import 'package:bidding_market/screens/viewProfile.dart';
import 'package:bidding_market/services/auth.dart';
import 'package:bidding_market/services/language_constants.dart';
import 'package:bidding_market/shared/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bidding_market/screens/registeration/productRegisteration.dart';
import 'package:intl/intl.dart';

import 'contactSupport.dart';

class NavDrawer extends StatefulWidget {
  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {

  // //Translated values
  // User _translatedUser = new User();
  //
  // void _getTranslatedValues(BuildContext context)
  // {
  //   _translatedUser.Name = loggedUser.Name;
  //
  //   getTranslatedOnline(context, _translatedUser.Name, "0").then((
  //       value) =>
  //       setState(() {
  //         _translatedUser.Name = value;
  //       }));
  // }
  //
  // @override
  // // ignore: must_call_super
  // void didChangeDependencies() {
  //   //super.initState();
  //   _getTranslatedValues(context);
  // }
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            // child: Text(
            //   'WELCOME     ' + loggedUser.Name +' !!!!',
            //   style: TextStyle(color: Colors.black, fontSize: 20),
            // ),

            child: Image.asset('assets/images/appLogo_v2.png', scale: 4, /*fit: BoxFit.contain,*/),
            // decoration: BoxDecoration(
            //     color: Colors.white,
            //     image: DecorationImage(
            //         fit: BoxFit.fill,
            //         image: AssetImage('assets/images/appLogo.png')),
            //
            // ),
          ),
          ListTile(
            leading: Icon(Icons.verified_user_outlined),
            title: (loggedUser.Name == null )? Text(toBeginningOfSentenceCase(getTranslated(context, "welcome_key")) + ' !!!'): Text(toBeginningOfSentenceCase(getTranslated(context, "welcome_key")) + '  '+  loggedUser.Name  + ' !!!'),
            onTap: () => {},
          ),
          ListTile(
            leading: Icon(Icons.home_outlined),
            title: Text(toBeginningOfSentenceCase(getTranslated(context, "home_key"))),
            onTap: () => {
                          Navigator.push(context, MaterialPageRoute(
                          builder: (context) => Home()
            ))},
          ),
          ListTile(
              leading: Icon(CupertinoIcons.hammer_fill),
              title: Text(toBeginningOfSentenceCase(getTranslated(context, "live_bids_key"))),
              onTap:() {
                //Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => LiveBids()
                ));
              }

          ),
          (loggedUser.type == 1) ?
          ListTile(
            leading: Icon(Icons.border_color),
            title: Text(toBeginningOfSentenceCase(getTranslated(context, "my_bids_key"))),
            onTap: () => {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => MyBids()
              ))
            },
          ) : SizedBox(),
          (loggedUser.type == 2) ?
          ListTile(
            leading: Icon(Icons.input),
            title: Text(toBeginningOfSentenceCase(getTranslated(context, "add_product_key"))),
            onTap:() {
                      //Navigator.of(context).pop();
                      Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ProductRegisterForm()
                      ));
                      }

          ) : SizedBox(),
          (loggedUser.type == 2) ?
          ListTile(
            leading: Icon(Icons.border_color),
            title: Text(toBeginningOfSentenceCase(getTranslated(context, "my_products_key"))),
            onTap: () => {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => MyProducts()
              ))
            },
          ) : SizedBox(),
          ListTile(
            leading: Icon(Icons.details),
            title: Text(toBeginningOfSentenceCase(getTranslated(context, "my_profile_key"))),
            onTap: ()  {

              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => Profile(loggedUser)
              ));
            }


          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(toBeginningOfSentenceCase(getTranslated(context, "settings_key"))),
            onTap: () => {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => Settings()))
            },
          ),
          ListTile(
            leading: Icon(Icons.contact_support_outlined),
            title: Text(toBeginningOfSentenceCase(getTranslated(context, "contact_support_key"))),
            onTap: () => {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ContactSupport()))
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text(toBeginningOfSentenceCase(getTranslated(context, "logout_key"))),
            onTap: () async{
              await _auth.signOut();
              Navigator.of(context)
                  .pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => Authenticate() ), (Route<dynamic> route) => false
              );
            },
          ),
        ],
      ),
    );
  }
}