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

class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();

  DatabaseService dbConnection = DatabaseService();

  List<Product> productsList ;


 Widget showList() {
    return FutureBuilder(
        future: dbConnection.productListFromSnapshot(),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          print(snapshot);
          productsList = snapshot.data;

          if (!snapshot.hasData) {
            return Center(
                child: Text(
                  "Loading...",
                  style: TextStyle(
                    fontFamily: "Montesserat",
                    fontWeight: FontWeight.w700,
                    fontSize: 40.0,
                    fontStyle: FontStyle.italic,
                  ),
                ));
          }
          if(productsList == null) {
            print("PARESH productList");
            productsList = [];
          }
          return Column(
              children:[
                Text(
                  "Product Count is " + (productsList.length).toString(),
                  style: TextStyle(
                    fontFamily: "Montesserat",
                    fontWeight: FontWeight.w700,
                    fontSize: 20.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Expanded(child:
                ListView.builder(
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
                                "${productsList[i].image1}",
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
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .title,
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
          )
                )
          ]);
        });
  }

  @override
  Widget build(BuildContext context) {

    print("products list is  $productsList");
    if(productsList == null) {
      print("PARESH productList");
      productsList = [];
    }
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
         body:
         //Column(
        //   children: [
        //   Text(
        //   "Product Count is " + (productsList.length).toString(),
        //   style: TextStyle(
        //     fontFamily: "Montesserat",
        //     fontWeight: FontWeight.w700,
        //     fontSize: 20.0,
        //     fontStyle: FontStyle.italic,
        //   ),
        //
        // ),
    showList()
    //])
        // body:  ListView.builder(
        //     itemCount: productsList.length,
        //     itemBuilder: (ctx, i) {
        //       return Container(
        //         margin: const EdgeInsets.only(bottom: 25),
        //         child: Row(
        //           children: <Widget>[
        //             Expanded(
        //               child: Container(
        //                 decoration: BoxDecoration(
        //                   borderRadius: BorderRadius.circular(15.0),
        //                   color: Colors.white,
        //                 ),
        //                 child: Image.network(
        //                   "${productsList[i].image}",
        //                   fit: BoxFit.cover,
        //                 ),
        //               ),
        //             ),
        //             SizedBox(width: 15),
        //             Expanded(
        //               child: Column(
        //                 crossAxisAlignment: CrossAxisAlignment.start,
        //                 children: <Widget>[
        //                   Text(
        //                     "${productsList[i].owner}",
        //                     style: Theme.of(context).textTheme.title,
        //                   ),
        //                   Text(
        //                     "${productsList[i].reservePrice}",
        //                   ),
        //                   SizedBox(height: 15),
        //                   //MyCounter(),
        //                 ],
        //               ),
        //             ),
        //           ],
        //         ),
        //       );
        //     },
        //   ),

      );

  }
}