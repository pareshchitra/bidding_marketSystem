import 'package:bidding_market/models/brew.dart';
import 'package:bidding_market/models/products.dart';
import 'package:bidding_market/models/user.dart';
import 'package:bidding_market/screens/authenticate/authenticate.dart';
import 'package:bidding_market/screens/authenticate/phone_auth.dart';
import 'package:bidding_market/screens/home/brew_list.dart';
import 'package:bidding_market/screens/registeration/productRegisteration.dart';
import 'package:bidding_market/services/auth.dart';
import 'package:bidding_market/services/database.dart';
import 'package:bidding_market/shared/nav-drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



class MyProducts extends StatefulWidget {

  @override
  _MyProductsState createState() => _MyProductsState();
}

class _MyProductsState extends State<MyProducts> {
  final AuthService _auth = AuthService();

  DatabaseService dbConnection = DatabaseService();

  List<Product> productsList ;



  Widget showList() {
    final currentUser = Provider.of<User>(context);
    return FutureBuilder(
        future: dbConnection.myProducts(currentUser),
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
          if(snapshot.hasData) {
            if (productsList == null) {
              print("PARESH productList");
              productsList = [];
            }
            productsList.sort((a,b) => a.lastUpdatedOn.isBefore(b.lastUpdatedOn) == true ? 1 : 0);
          }
          final border = RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          );
          final padding = const EdgeInsets.all(4.0);

          return Column(
              children:[
                // Text(
                //   "Product Count is " + (productsList.length).toString(),
                //   style: TextStyle(
                //     fontFamily: "Montesserat",
                //     fontWeight: FontWeight.w700,
                //     fontSize: 20.0,
                //     fontStyle: FontStyle.italic,
                //   ),
                // ),
                Expanded(child:
                ListView.builder(
                  itemCount: productsList.length,
                  itemBuilder: (ctx, i) {
                    Duration dur = DateTime.now().difference(productsList[i].age);
                    String differenceInYears = (dur.inDays/365).floor().toString();
                    return Padding(
                        padding: padding,
                        //margin: const EdgeInsets.only(bottom: 25),
                        child :Card(
                          shape: border,
                          color: Colors.green[100],
                          child: Column(
                            children: [
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15.0),
                                        color: Colors.green[500],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),

                                        child: Image.network(
                                          "${productsList[i].image1}",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        // Icon(Icons.account_circle),
                                        // Text(
                                        //   "${productsList[i].owner}",
                                        //   style: Theme
                                        //       .of(context)
                                        //       .textTheme
                                        //       .title,
                                        // ),
                                        RichText(
                                            text: TextSpan(
                                                children : [
                                                  WidgetSpan(
                                                      child: Icon(Icons.account_circle,size: 25,color: Colors.green[700])),
                                                  WidgetSpan(
                                                      child: SizedBox(width: 8.0)),
                                                  TextSpan(
                                                    text: "${productsList[i].owner}",
                                                    style: TextStyle(color: Colors.black,
                                                        fontSize: 20),
                                                  ),
                                                ]
                                            )),
                                        RichText(
                                            text: TextSpan(
                                                children : [
                                                  WidgetSpan(
                                                      child: Icon(Icons.place,size: 25,color: Colors.green[700])),
                                                  WidgetSpan(
                                                      child: SizedBox(width: 8.0)),
                                                  TextSpan(
                                                    text: "${productsList[i].location}",
                                                    style: TextStyle(color: Colors.black,
                                                        fontSize: 20),
                                                  ),
                                                ]
                                            )),
                                        RichText(
                                            text: TextSpan(
                                                children : [
                                                  WidgetSpan(
                                                      child: Icon(Icons.nature,size: 25,color: Colors.green[700])),
                                                  WidgetSpan(
                                                      child: SizedBox(width: 8.0)),
                                                  TextSpan(
                                                    text: "${productsList[i].noOfPlants} " + "Plants",
                                                    style: TextStyle(color: Colors.black,
                                                        fontSize: 20),
                                                  ),
                                                ]
                                            )),
                                        RichText(
                                            text: TextSpan(
                                                children : [
                                                  WidgetSpan(
                                                      child: Icon(Icons.fence,size: 25, color: Colors.green[700])),
                                                  WidgetSpan(
                                                      child: SizedBox(width: 8.0)),
                                                  TextSpan(
                                                    text: "${productsList[i].size} " + "Bheega",
                                                    style: TextStyle(color: Colors.black,
                                                        fontSize: 20),
                                                  ),
                                                ]
                                            )),
                                        RichText(
                                            text: TextSpan(
                                                children : [
                                                  WidgetSpan(
                                                      child: Icon(Icons.nature_people,size: 25,color: Colors.green[700])),
                                                  WidgetSpan(
                                                      child: SizedBox(width: 8.0)),
                                                  TextSpan(
                                                    text: "$differenceInYears " + "Years",
                                                    style: TextStyle(color: Colors.black,
                                                        fontSize: 20),
                                                  ),
                                                ]
                                            )),
                                        RichText(
                                            text: TextSpan(
                                                children : [
                                                  WidgetSpan(
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(left:8.0),
                                                        child: Text('\u{20B9}',style: TextStyle(fontSize: 23, color:Colors.green[700]),),
                                                      )), //Rupee Symbol
                                                  WidgetSpan(
                                                      child: SizedBox(width: 8.0)),
                                                  TextSpan(
                                                    text: "${productsList[i].reservePrice} " +"Rs.",
                                                    style: TextStyle(color: Colors.black,
                                                        fontSize: 20),
                                                  ),
                                                ]
                                            )),


                                        SizedBox(height: 15),
                                        //MyCounter(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children:[
                                  RaisedButton.icon(onPressed: () => { update(productsList[i]) }, icon: Icon(Icons.update), label: Text("UPDATE")),
                                  RaisedButton.icon(onPressed: () => { delete() }, icon: Icon(Icons.delete_forever), label: Text("DELETE"))
                              ])
                            ],
                          ),
                        ));
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
                Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) => Authenticate()
                ));
                //PhoneAuthDataProvider().signOut();
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


    );

  }
  void update(Product p)
  {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => ProductRegisterForm(p:p)
    ));
  }

  void delete()
  {

  }
}