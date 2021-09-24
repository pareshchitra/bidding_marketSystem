import 'dart:io';
import 'package:bidding_market/main.dart';
import 'package:bidding_market/models/bid.dart';
import 'package:bidding_market/models/brew.dart';
import 'package:bidding_market/models/products.dart';
import 'package:bidding_market/screens/authenticate/authenticate.dart';
import 'package:bidding_market/screens/authenticate/phone_auth.dart';
import 'package:bidding_market/screens/home/brew_list.dart';
import 'package:bidding_market/screens/productDetails.dart';
import 'package:bidding_market/services/auth.dart';
import 'package:bidding_market/services/database.dart';
import 'package:bidding_market/services/language_constants.dart';
//import 'package:bidding_market/shared/TranslatedText.dart';
import 'package:bidding_market/shared/nav-drawer.dart';
import 'package:bidding_market/shared/regFunctions.dart';
import 'package:bidding_market/shared/sharedPrefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:filter_list/filter_list.dart';
import 'package:intl/intl.dart';



class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();

  DatabaseService dbConnection = DatabaseService();

  List<Product> productsList ;
  List<String>  villageList = [];
  List<String> selectedVillageList = [];

  int pagesPerBatch = 10;

//  List<Product> products = [];
  //Translated values
//   List<Product> _translatedProductsList = [] ;
//   int callCount = 0;
//   void _getTranslatedValues(BuildContext context)
//   {
//     callCount++;
//     print("Called func- $callCount with productListnumber-${_translatedProductsList.length}");
//       for (var i = 0; i < productsList.length; i++) {
//         print(
//             "Calling for Category- i=${i}, callCount=${callCount}, productId=${_translatedProductsList[i]
//                 .id}");
//         if(selectedLanguage == "hi") {
//         getTranslatedOnline(context, _translatedProductsList[i].category, "0").then((
//             value) =>
//             setState(() {
//               _translatedProductsList[i].category = value;
//             }));
//         print(
//             "Calling for location- i=${i}, callCount=${callCount}, productId=${_translatedProductsList[i]
//                 .id}");
//         getTranslatedOnline(context, _translatedProductsList[i].location, "0").then((
//             value) =>
//             setState(() {
//               _translatedProductsList[i].location = value;
//             }));
//         print(
//             "Calling for Owner- i=${i}, callCount=${callCount}, productId=${_translatedProductsList[i]
//                 .id}");
//         getTranslatedOnline(context, _translatedProductsList[i].owner, "0").then((value) =>
//             setState(() {
//               _translatedProductsList[i].owner = value;
//             }));
//         }
//         else if(selectedLanguage == "en")
//         {
//           _translatedProductsList[i].category = productsList[i].category;
//           _translatedProductsList[i].location = productsList[i].location;
//           _translatedProductsList[i].owner = productsList[i].owner;
//         }
//       }
//
//   }
//
//   Future<void> productsGet() async {
//   products = await dbConnection.getProducts();
// }
//
//   @override
//   void initState() {
//     productsGet();
//     super.initState();
//   }
//
//   @override
//   // ignore: must_call_super
//   Future<void> didChangeDependencies() async {
//     //super.initState();
//     //showList();
//     await Future.delayed(const Duration(seconds: 1));
//     _translatedProductsList = List.from(products);
//     _getTranslatedValues(context);
//   }

  Widget showProductTiles(BuildContext context, List<Product> productsList,int index) {

    final border = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    );
    final padding = const EdgeInsets.all(4.0);

    String differenceInYears = '';
    if( index < productsList.length ) {
      Duration dur = DateTime.now().difference(
          productsList[index].age);
      differenceInYears = (dur.inDays / 365)
          .floor()
          .toString();
    }

    return InkWell(
      onTap: () {
        if( SharedPrefs().adminId != "" &&
            FireBase.auth.currentUser == null ) {  // Admin is Logged In
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return FutureBuilder<String>(
                    future: dbConnection.getUserPhoneNo(productsList[index].id.split("#")[0]),
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData)
                      return ProductDetails(product: productsList[index],
                        userPhoneNo: snapshot.data,);

                    return Container(child: CircularProgressIndicator());
                  }

                );
              },
            ),
          );
        }
        else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return ProductDetails(product: productsList[index]);
              },
            ),
          );
        }
      },
      child: Padding(
          padding: padding,
          //margin: const EdgeInsets.only(bottom: 25),
          child :Card(
            shape: border,
            color: Colors.green[100],
            child: Column(
              children: [
                ListTile(
                  title: Text( getTranslated(context, (productsList[index].category.toLowerCase() + "_category_key")).toUpperCase() + " - " + prettifyDouble(productsList[index].size) + " " + toBeginningOfSentenceCase(getTranslated(context, "bigha_key")) + " - " +  productsList[index].location,
                      style: TextStyle( color : Colors.green[600],
                          fontSize: 25)),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Colors.green[500],
                        ),
                        height: 200.0,
                        width: 200.0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),

                          child: (productsList[index].image1 != null && productsList[index].image1 != "" ) ? Image.network(
                            "${productsList[index].image1}" ,
                            fit: BoxFit.cover,
                          ) : Center(child: Text(getTranslated(context, "no_image_key"))),
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
                                      text: productsList[index].owner,
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
                                      text: productsList[index].location,
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
                                      text: "${productsList[index].noOfPlants} " + toBeginningOfSentenceCase(getTranslated(context, "plants_key")),
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
                                      text: "${prettifyDouble(productsList[index].size)} " + toBeginningOfSentenceCase(getTranslated(context, "bigha_key")),
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
                                  children: [
                                    WidgetSpan(
                                        child: Icon(Icons.money,size: 25,color: Colors.green[700])
                                        // child: Padding(
                                        //   padding: const EdgeInsets.only(
                                        //       left: 10.0),
                                        //   child: Text('\u{20B9}',
                                        //     style: TextStyle(fontSize: 23,
                                        //         color: Colors.green[700]),),
                                        // ) //Rupee Symbol
                                    ),
                                    WidgetSpan(
                                        child: SizedBox(width: 8.0)),
                                    TextSpan(
                                      text: "${NumberFormat.currency(locale: 'gu', symbol: '\u{20B9} ').format(productsList[index].reservePrice)}",
                                      style: TextStyle(color: Colors.black,
                                          fontSize: 20),
                                    ),
                                  ]
                              )),


                          SizedBox(height: 5),


                          //MyCounter(),
                        ],
                      ),
                    ),
                  ],
                ),
                if( SharedPrefs().adminId != "" &&
                    FireBase.auth.currentUser == null ) //Admin is Logged In
                    biddingWindow(index),

                        ],
            ),
          )),
    );
    }

 Widget showList() {
    return FutureBuilder(
        future: dbConnection.getProducts(),
        builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
          print("Snapshot is " + snapshot.toString());
          //productsList.addAll(snapshot.data);

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
          if(snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              if (productsList == null) {
                productsList = [];
                //_translatedProductsList = [];
              }
              print("Length of snapshot data is ${snapshot.data.length}");
              productsList.addAll(snapshot.data);
             // _translatedProductsList = List.from(productsList);
              //_getTranslatedValues(context);
              print("products list is now");
              print(productsList);
              // productsList.sort((a, b) =>
              // a.lastUpdatedOn.isBefore(b.lastUpdatedOn) == true ? 1 : 0);
              for( Product product in productsList )
                villageList.add(product.location);
              villageList = villageList.toSet().toList();
              print("Village List is $villageList");
            }
          }


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
                  itemCount: productsList.length + 2, // +1 for the load button , +1 for the filter button
                  itemBuilder: (ctx, index) {
                    String differenceInYears = '';
                    if( index == 0 )
                      {
                        return Container(
                          alignment: Alignment.topRight,
                          color: Colors.brown[200],
                          child: RaisedButton.icon(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                side: BorderSide(color: Colors.red)
                            ),
                            icon: Icon(Icons.filter_alt_outlined),
                            onPressed: _openFilterList,
                            label : Text(toBeginningOfSentenceCase(getTranslated(context, "filter_key"))),
                            color: Colors.red[100],

                  ),
                        );
                }

                print("Length of snapshot data is ${snapshot.data.length} && index is $index");
                return ((index == productsList.length + 1) &&
                        (snapshot.data.length <= pagesPerBatch ||
                            snapshot.data.length == 0))
                    ? (snapshot.data.length == 0 ||
                            snapshot.data.length < pagesPerBatch)
                        ? SizedBox(height: 5)
                        : Container(
                            color: Colors.greenAccent,
                            child: FlatButton(
                              child: Text(toBeginningOfSentenceCase(getTranslated(context, "load_more_key"))),
                              onPressed: () async {
                                //List<Product> newProducts = await dbConnection.getProducts();
                                setState(() {
                                  //productsList.addAll(newProducts);
                                });
                              },
                            ),
                          )
                    : (filterCondition() == true)
                        ? ((!selectedVillageList
                                .contains(productsList[index - 1].location)) // if selected filter does not contain village
                            ? SizedBox(height: 0)
                            : showProductTiles(context, productsList, index - 1))
                        : showProductTiles(context, productsList, index - 1);
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
     // _translatedProductsList = [];
    }
    return Scaffold(
        drawer: NavDrawer(),
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(toBeginningOfSentenceCase(getTranslated(context, "home_key"))),
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

  void _openFilterList() async {
    FilterListDialog.display<String>(
        context,
        listData: villageList,
        selectedListData: selectedVillageList,
        height: 480,
        headlineText: toBeginningOfSentenceCase(getTranslated(context, "select_village_key")),
        searchFieldHintText: toBeginningOfSentenceCase(getTranslated(context, "search_here_key")),
        label: (item) {
          return item;
        },
        validateSelectedItem: (list, val) {
          return list.contains(val);
        },
        onItemSearch: (list, text) {
          if (list.any((element) =>
              element.toLowerCase().contains(text.toLowerCase()))) {
            return list
                .where((element) =>
                element.toLowerCase().contains(text.toLowerCase()))
                .toList().toSet().toList();
          }
          else{
            return [];
          }
        },
        onApplyButtonClick: (list) {
          if (list != null) {
            setState(() {
              selectedVillageList = List.from(list);
            });
          }
          Navigator.pop(context);
        });
  }

  // Returns TRUE if any filter is selected otherwise false
  bool filterCondition() {
    if (selectedVillageList == null || selectedVillageList.length == 0)
      return false;
    else
      return true;
  }


  // FOR ADMIN HOME PAGE
  Widget biddingWindow(int index) {
    return Row(
        children: [
        dropDownList(),
        SizedBox(width: 20.0),
        RaisedButton.icon(
            icon: Icon(CupertinoIcons.hammer_fill),
            label: Text(getTranslated(context, "start_bidding_key").toUpperCase()),
            color: Colors.green,
            onPressed: () {
              startBidding(index);
            }),
        // Expanded(
        //   child: RaisedButton.icon(
        //       icon: Icon(Icons.stop),
        //       label: Text('STOP BIDDING'),
        //       color: Colors.red,
        //       onPressed: () {}),
        // )
      ],
    );
  }

  String selectedDuration;
  Widget dropDownList()
  {
    return DropdownButton<String>(
      value: selectedDuration,
      //elevation: 5,
      style: TextStyle(color: Colors.black),

      items: <String>[
        '5', '7', '10', '14', '21', '28', '30'
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      hint: Text(
        toBeginningOfSentenceCase(getTranslated(context, "choose_duration_key")),
        style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600),
      ),
      onChanged: (String value) {
        setState(() {
          selectedDuration = value;
        });
      },
    );
  }

  startBidding( int index ) async
  {
    if (selectedDuration == null) {
      // NO Duration has been selected
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text(toBeginningOfSentenceCase(getTranslated(context, "alert_dialog_key"))),
                content: Text(getTranslated(context, "choose_duration_alert_key") + "!!"),
                actions: <Widget>[
                  FlatButton(
                    child: Text(getTranslated(context, "ok_key").toUpperCase()),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ]);
          });
    }
    else {
      Bid bid = new Bid();

      DateTime now = new DateTime.now();
      DateTime date = new DateTime(now.year, now.month, now.day);
      bid.id = productsList[index].id;
      bid.productId = productsList[index].id;
      bid.startTime = date;
      bid.endTime = date.add(new Duration(days: int.parse(selectedDuration)));
      bid.basePrice = productsList[index].reservePrice;
      bid.type = "Best Buyer";

      //Check if Bid is already Active
      Bid Oldbid = await dbConnection.getBid(bid.id);
      if ( Oldbid != null && Oldbid.status == "Active") {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  title: Text(toBeginningOfSentenceCase(
                      getTranslated(context, "alert_dialog_key"))),
                  content: Text(camelCasingFields(
                      getTranslated(context, "bid_is_active_key"))),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(
                          getTranslated(context, "ok_key").toUpperCase()),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ]);
            });
      }
      else {
        dbConnection.addNewBid(bid).then((value) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                    title: Text(toBeginningOfSentenceCase(
                        getTranslated(context, "alert_dialog_key"))),
                    content: Text(camelCasingFields(
                        getTranslated(context, "bid_started_key")) +
                        " $selectedDuration !!!"),
                    actions: <Widget>[
                      FlatButton(
                        child: Text(
                            getTranslated(context, "ok_key").toUpperCase()),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ]);
              });
        }).catchError((errorMsg) =>
            print(
                "Add New bid database operation failed with msg : $errorMsg"));
      }
    }
  }
}