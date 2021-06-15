import 'package:bidding_market/main.dart';
import 'package:bidding_market/screens/admin/liveBidding.dart';
import 'package:bidding_market/screens/home/home.dart';
import 'package:bidding_market/screens/myProducts.dart';
import 'package:bidding_market/screens/registeration/BuyerForm.dart';
import 'package:bidding_market/screens/registeration/SellerForm.dart';
import 'package:bidding_market/screens/viewProfile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bidding_market/screens/registeration/productRegisteration.dart';

class NavDrawer extends StatelessWidget {
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
            decoration: BoxDecoration(
                color: Colors.lightGreen[100],
                image: DecorationImage(
                    fit: BoxFit.contain,
                    image: AssetImage('assets/images/appLogo.jpg'))),
          ),
          ListTile(
            leading: Icon(Icons.verified_user_outlined),
            title: (loggedUser.Name == null )? Text('Welcome  '+  ' !!!'): Text('Welcome  '+  loggedUser.Name  + ' !!!'),
            onTap: () => {},
          ),
          ListTile(
            leading: Icon(Icons.home_outlined),
            title: Text('Home'),
            onTap: () => {
                          Navigator.push(context, MaterialPageRoute(
                          builder: (context) => Home()
            ))},
          ),
          ListTile(
              leading: Icon(CupertinoIcons.hammer_fill),
              title: Text('Live Bids'),
              onTap:() {
                //Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => LiveBids()
                ));
              }

          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text('Add Product'),
            onTap:() {
                      //Navigator.of(context).pop();
                      Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ProductRegisterForm()
                      ));
                      }

          ),
          ListTile(
            leading: Icon(Icons.details),
            title: Text('Profile'),
            onTap: ()  {

              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => Profile(loggedUser)
              ));
            }


          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: Icon(Icons.border_color),
            title: Text('My Products'),
            onTap: () => {
                          Navigator.push(context, MaterialPageRoute(
                          builder: (context) => MyProducts()
            ))
                          },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () => {Navigator.of(context).pop()},
          ),
        ],
      ),
    );
  }
}