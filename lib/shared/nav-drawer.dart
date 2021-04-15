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
            //   'Side menu',
            //   style: TextStyle(color: Colors.white, fontSize: 25),
            // ),
            decoration: BoxDecoration(
                color: Colors.lightGreen[100],
                image: DecorationImage(
                    fit: BoxFit.contain,
                    image: AssetImage('assets/images/appLogo.jpg'))),
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text('Welcome'),
            onTap: () => {},
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text('Add Product'
                ''),
            onTap:() {
                      //Navigator.of(context).pop();
                      Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ProductRegisterForm()
                      ));
                      }

          ),
          ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('Profile'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: Icon(Icons.border_color),
            title: Text('My Products'),
            onTap: () => {Navigator.of(context).pop()},
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