import 'package:bidding_market/models/brew.dart';
import 'package:bidding_market/models/products.dart';
import 'package:bidding_market/screens/authenticate/authenticate.dart';
import 'package:bidding_market/screens/home/brew_list.dart';
import 'package:bidding_market/services/auth.dart';
import 'package:bidding_market/services/database.dart';
import 'package:bidding_market/shared/nav-drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ABC {
  var productsList = new List<Product>();

  ABC(productsList) {
    Product p1 = new Product(id: '1');
    this.productsList.add(p1);
  }

}

class Home extends StatelessWidget {

  final AuthService _auth = AuthService();
  DatabaseService dbConnection = DatabaseService();
  var productsList = new List<Product>();
  //ABC a = new ABC(productsList);


  @override
  Widget build(BuildContext context) {
    productsList = dbConnection.productListFromSnapshot();
    return Scaffold(
        drawer: NavDrawer(),
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Home'),
          backgroundColor: Colors.green[700],
          elevation: 0.0,
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.person),
              label: Text('logout'),
              onPressed: () async {
                //Navigator.of(context).pop();
                await _auth.signOut();
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => Authenticate()
                ));

              },
            ),
          ],
        ),
        body: Expanded(
          child: ListView.builder(
            itemCount: productsList.length,
            itemBuilder: (ctx, i) {
              return Container(
                margin: const EdgeInsets.only(bottom: 25),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Colors.white,
                        ),
                        child: Image.network(
                          "${productsList[i].image}",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "${productsList[i].owner}",
                            style: Theme.of(context).textTheme.title,
                          ),
                          Text(
                            "${productsList[i].reservePrice}",
                          ),
                          SizedBox(height: 15),
                          //MyCounter(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

  }
}