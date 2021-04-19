import 'package:bidding_market/main.dart';
import 'package:bidding_market/screens/myProducts.dart';
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
            child: Text(
              'WELCOME     ' + loggedUser.Name +' !!!!',
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            decoration: BoxDecoration(
                color: Colors.lightGreen[100],
                image: DecorationImage(
                    fit: BoxFit.contain,
                    image: AssetImage('assets/images/appLogo.jpg'))),
          ),
          ListTile(
            leading: Icon(Icons.verified_user_outlined),
            title: Text('Welcome  '+  loggedUser.Name + ' !!!'),
            onTap: () => {},
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