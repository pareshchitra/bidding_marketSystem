import 'package:bidding_market/main.dart';
import 'package:bidding_market/models/brew.dart';
import 'package:bidding_market/models/products.dart';
import 'package:bidding_market/models/user.dart';
import 'package:bidding_market/screens/authenticate/authenticate.dart';
import 'package:bidding_market/screens/authenticate/phone_auth.dart';
import 'package:bidding_market/screens/home/brew_list.dart';
import 'package:bidding_market/screens/registeration/productRegisteration.dart';
import 'package:bidding_market/services/auth.dart';
import 'package:bidding_market/services/database.dart';
import 'package:bidding_market/services/language_constants.dart';
import 'package:bidding_market/shared/constants.dart';
import 'package:bidding_market/shared/nav-drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';



class MyProducts extends StatefulWidget {

  @override
  _MyProductsState createState() => _MyProductsState();
}

class _MyProductsState extends State<MyProducts> {
  final AuthService _auth = AuthService();

  DatabaseService dbConnection = DatabaseService();

  List<Product> productsList ;

  // //Translated values
  // List<Product> _translatedProductsList = [];
  //
  // void _getTranslatedValues(BuildContext context)
  // {
  //   for (var i = 0; i < productsList.length;i++ ) {
  //     if(selectedLanguage == "hi") {
  //     getTranslatedOnline(context, _translatedProductsList[i].location, "0").then((
  //         value) =>
  //         setState(() {
  //           _translatedProductsList[i].location = value;
  //         }));
  //     getTranslatedOnline(context, _translatedProductsList[i].owner, "0").then((
  //         value) =>
  //         setState(() {
  //           _translatedProductsList[i].owner = value;
  //         }));
  //     }
  //     else if(selectedLanguage == "en")
  //     {
  //       _translatedProductsList[i].location = productsList[i].location;
  //       _translatedProductsList[i].owner = productsList[i].owner;
  //     }
  //   }
  // }
  //
  // @override
  // // ignore: must_call_super
  // Future<void> didChangeDependencies() async {
  //   //super.initState();
  //   showList();
  //   await Future.delayed(const Duration(seconds: 1));
  //   _getTranslatedValues(context);
  // }

  Widget showList() {
    //final currentUser = Provider.of<User>(context);
    return FutureBuilder(
        future: dbConnection.myProducts(loggedUser),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          print(snapshot);
          productsList = snapshot.data;

          if (!snapshot.hasData) {
            return Center(
                child: Text(
                  toBeginningOfSentenceCase(getTranslated(context, "loading_key")) + "...",
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
              //_translatedProductsList = [];
            }
            productsList.sort((a,b) => a.lastUpdatedOn.isBefore(b.lastUpdatedOn) == true ? 1 : 0);

           // _translatedProductsList = List.from(productsList);
            //_getTranslatedValues(context);
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
                Expanded(
                    child:productsList.length == 0
                        ? Center(
                      child: Text(toBeginningOfSentenceCase(getTranslated(context, "no_product_user_key")), style: TextStyle(fontSize: 20),),
                    )
                : ListView.builder(
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

                                        child: (productsList[i].image1 != null && productsList[i].image1 != "" ) ? Image.network(
                                          "${productsList[i].image1}" ,
                                          fit: BoxFit.cover,
                                        ) : Text(toBeginningOfSentenceCase(getTranslated(context, "no_image_key")))
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
                                                    text: productsList[i].owner,
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
                                                    text: productsList[i].location,
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
                                                    text: "${productsList[i].noOfPlants} " + toBeginningOfSentenceCase(getTranslated(context, "plants_key")),
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
                                                    text: "${productsList[i].size} " + toBeginningOfSentenceCase(getTranslated(context, "bigha_key")),
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
                                                    text: "$differenceInYears " + toBeginningOfSentenceCase(getTranslated(context, "years_key")),
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
                                                    //text: "₹ " + "${productsList[i].reservePrice}",
                                                    text: "${currencyFormat.format(productsList[i].reservePrice)}",
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                children:[
                                  RaisedButton.icon(onPressed: () => { update(productsList[i]) }, icon: Icon(Icons.update), label: Text(getTranslated(context, "update_key").toUpperCase())),
                                  SizedBox(width: 10.0),
                                  RaisedButton.icon(onPressed: () => { delete( context,productsList[i]) }, icon: Icon(Icons.delete_forever), label: Text(getTranslated(context, "delete_key").toUpperCase()))
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
      //_translatedProductsList = [];
    }
    return Scaffold(
        drawer: NavDrawer(),
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(toBeginningOfSentenceCase(getTranslated(context, "my_products_key"))),
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
  Future<Widget> update(Product p)
  {
    return Navigator.push(context, MaterialPageRoute(
        builder: (context) => ProductRegisterForm(p:p)
    ));
  }



  delete(BuildContext context, Product p) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(toBeginningOfSentenceCase(getTranslated(context, "alert_dialog_key"))),
          content: Text(toBeginningOfSentenceCase(getTranslated(context, "delete_confirm_key"))),
          actions: <Widget>[
            FlatButton(
              child: Text(getTranslated(context, "yes_key").toUpperCase()),
              onPressed: () async{
                Navigator.of(context).pop();
                //await dbConnection.deleteProduct(p);
                await dbConnection.dbDeleteProduct(p);
                setState(() {  showList();  });
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