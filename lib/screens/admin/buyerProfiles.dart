import 'dart:io';
import 'package:bidding_market/main.dart';
import 'package:bidding_market/models/bid.dart';
import 'package:bidding_market/models/brew.dart';
import 'package:bidding_market/models/products.dart';
import 'package:bidding_market/models/user.dart';
import 'package:bidding_market/screens/admin/buyerProfileDetails.dart';
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



class BuyerProfiles extends StatefulWidget {

  @override
  _BuyerProfilesState createState() => _BuyerProfilesState();
}

class _BuyerProfilesState extends State<BuyerProfiles> {
  final AuthService _auth = AuthService();

  DatabaseService dbConnection = DatabaseService();

  List<User> buyerList ;
  List<String>  villageList = [];
  List<String> selectedVillageList = [];

  int pagesPerBatch = 10;


  Widget tilesInfo(String property, IconData icon, String propertyValue)
  {
    return RichText(
              text: TextSpan(
                  children : [
                    WidgetSpan(
                        child: Icon(icon,size: 22,color: Colors.green[700])),
                    WidgetSpan(
                        child: SizedBox(width: 8.0)),
                    TextSpan(
                      text: propertyValue,
                      style: TextStyle(color: Colors.black,
                          fontSize: 18),
                    ),
                  ]
              ));
  }

  Widget showBuyerTiles(BuildContext context, List<User> buyerList,int index) {
    final border = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    );
    final padding = const EdgeInsets.all(4.0);


    return InkWell(
        onTap: () {
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) {
                    return BuyerProfileDetails(userId: buyerList[index].uid);
                  })
          );
        },

        child: Padding(
            padding: padding,
            //margin: const EdgeInsets.only(bottom: 25),
            child: Card(
                shape: border,
                color: Colors.green[100],
                child: Column(
                    children: [
                      //HEADING
                      // ListTile(
                      //   title: Text( getTranslated(context, (productsList[index].category.toLowerCase() + "_category_key")).toUpperCase() + " - " + prettifyDouble(productsList[index].size) + " " + toBeginningOfSentenceCase(getTranslated(context, "bigha_key")) + " - " +  productsList[index].location,
                      //       style: TextStyle( color : Colors.green[600],
                      //           fontSize: 25)),
                      // ),
                      Row(
                          children: <Widget>[
                            Expanded(
                              //PHOTO
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Colors.green[500],
                                ),
                                height: 200.0,
                                width: 200.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),

                                  child: (buyerList[index].idFrontURL != null &&
                                      buyerList[index].idFrontURL != "") ? Image
                                      .network(
                                    "${buyerList[index].idFrontURL}",
                                    fit: BoxFit.cover,
                                  ) : Center(child: Text(
                                      getTranslated(context, "no_image_key"))),
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
                                  tilesInfo("", Icons.account_circle,
                                      buyerList[index].Name),
                                  tilesInfo("", Icons.home, buyerList[index]
                                      .HouseNo + ", " +
                                      buyerList[index].Village + ", " +
                                      buyerList[index].District + ", " +
                                      buyerList[index].State
                                      + "-" + buyerList[index].Pincode),
                                  //tilesInfo("", Icons.phone, buyerList[index].PhoneNo),
                                  tilesInfo("", Icons.credit_card,
                                      buyerList[index].AadharNo),
                                  tilesInfo("", Icons.verified,
                                  getTranslated(context, "verified_key") + ": " + ((buyerList[index]
                                          .isVerified) ? getTranslated(context, "yes_key") : getTranslated(context, "no_key")))
                                  //IsVERIFIED


                                ],
                              ),
                            )
                          ]
                      )
                    ])
            )
        )
    );
  }

  Widget showList() {
    return StreamBuilder(
        stream: dbConnection.dbBuyerCollection.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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

            if (snapshot.hasData) {
              if (buyerList == null) {
                buyerList = [];
                //_translatedProductsList = [];
              }
              print("Length of snapshot data is ${snapshot.data.docs.length}");
              print("Snapshot Data is ${snapshot.data.docs[0].data()["Name"]}");
              for( QueryDocumentSnapshot document in snapshot.data.docs)
                {
                  //Future<String> phoneNo =  dbConnection.getUserPhoneNo(document.id);
                  buyerList.add(new User(
                    Name : document.data()["Name"],
                    District : document.data()["District"],
                    State : document.data()["State"],
                    Village : document.data()["Village"],
                    Pincode : document.data()["Pincode"],
                    uid : document.id,
                    //TODO : PHOTO AND PHONENO OF BUYER
                    idFrontURL : document.data()["IdFrontUrl"],
                    idBackURL: document.data()["IdBackUrl"],
                    HouseNo : document.data()["HouseNo"],
                    AadharNo : document.data()["AadharNo"],
                    isVerified: document.data()["IsVerified"]

                  ));
                }
              // snapshot.data.docs.map((QueryDocumentSnapshot document)  {
              //   print("Snapshot Data 2 is ${document.data()}");
              //   buyerList.add(new User(
              //     Name : document.data()["Name"],
              //     //District : document.data()["District"],
              //     //State : document.data()["State"],
              //     //Village : document.data()["Village"],
              //     //Pincode : document.data()["Pincode"],
              //     //uid : document['Uid'],
              //     //TODO : PHOTO OF BUYER
              //     //photo : document.data()["IdFrontUrl"],
              //     //HouseNo : document.data()["HouseNo"],
              //     //AadharNo : document.data()["AadharNo"],
              //
              //   ));
              // });
              // _translatedProductsList = List.from(productsList);
              //_getTranslatedValues(context);
              print("Buyer list is now");
              print(buyerList);
              // productsList.sort((a, b) =>
              // a.lastUpdatedOn.isBefore(b.lastUpdatedOn) == true ? 1 : 0);
              for( User buyer in buyerList ) {
                print("Buyer Id is ${buyer.uid}");
                villageList.add(buyer.Village);
              }
              villageList = villageList.toSet().toList();
              print("Village List is $villageList");
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
                  itemCount: buyerList.length + 1, // +1 for the filter button
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

                    print("Length of snapshot data is ${snapshot.data.docs.length} && index is $index");
                    return  (filterCondition() == true)
                        ? ((!selectedVillageList
                        .contains(buyerList[index - 1].Village)) // if selected filter does not contain village
                        ? SizedBox(height: 0)
                        : showBuyerTiles(context, buyerList, index - 1))
                        : showBuyerTiles(context, buyerList, index - 1);
                  },
                )
                )
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {

    print("products list is  $buyerList");
    if( buyerList == null ) {
      print("PARESH productList");
      buyerList = [];
      // _translatedProductsList = [];
    }
    return Scaffold(
        drawer: NavDrawer(),
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(getTranslated(context, "buyers_key")),
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
        body: showList()

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
  // Widget biddingWindow(int index) {
  //   return Row(
  //     children: [
  //       dropDownList(),
  //       SizedBox(width: 20.0),
  //       RaisedButton.icon(
  //           icon: Icon(CupertinoIcons.hammer_fill),
  //           label: Text(getTranslated(context, "start_bidding_key").toUpperCase()),
  //           color: Colors.green,
  //           onPressed: () {
  //             startBidding(index);
  //           }),
  //       // Expanded(
  //       //   child: RaisedButton.icon(
  //       //       icon: Icon(Icons.stop),
  //       //       label: Text('STOP BIDDING'),
  //       //       color: Colors.red,
  //       //       onPressed: () {}),
  //       // )
  //     ],
  //   );
  // }

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

  // startBidding( int index )
  // {
  //   if (selectedDuration == null) {
  //     // NO Duration has been selected
  //     showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //               title: Text(toBeginningOfSentenceCase(getTranslated(context, "alert_dialog_key"))),
  //               content: Text(getTranslated(context, "choose_duration_alert_key") + "!!"),
  //               actions: <Widget>[
  //                 FlatButton(
  //                   child: Text(getTranslated(context, "ok_key").toUpperCase()),
  //                   onPressed: () {
  //                     Navigator.of(context).pop();
  //                   },
  //                 ),
  //               ]);
  //         });
  //   }
  //   else {
  //     Bid bid = new Bid();
  //
  //     DateTime now = new DateTime.now();
  //     DateTime date = new DateTime(now.year, now.month, now.day);
  //     bid.id = productsList[index].id;
  //     bid.productId = productsList[index].id;
  //     bid.startTime = date;
  //     bid.endTime = date.add(new Duration(days: int.parse(selectedDuration)));
  //     bid.basePrice = productsList[index].reservePrice;
  //     bid.type = "Best Price";
  //
  //     dbConnection.addNewBid(bid).then((value) {
  //       showDialog(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return AlertDialog(
  //                 title: Text(toBeginningOfSentenceCase(getTranslated(context, "alert_dialog_key"))),
  //                 content: Text(camelCasingFields(getTranslated(context, "bid_started_key")) + " $selectedDuration !!!"),
  //                 actions: <Widget>[
  //                   FlatButton(
  //                     child: Text(getTranslated(context, "ok_key").toUpperCase()),
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                   ),
  //                 ]);
  //           });
  //     }).catchError((errorMsg) => print("Add New bid database operation failed with msg : $errorMsg"));
  //   }
  // }
}