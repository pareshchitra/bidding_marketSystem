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
import 'package:bidding_market/shared/nav-drawer.dart';
import 'package:bidding_market/shared/sharedPrefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:filter_list/filter_list.dart';



class LiveBids extends StatefulWidget {

  @override
  _LiveBidsState createState() => _LiveBidsState();
}

class _LiveBidsState extends State<LiveBids> {
  final AuthService _auth = AuthService();

  DatabaseService dbConnection = DatabaseService();

  List<Product> productsList ;
  List<Bid> bidList = [];
  List<String>  villageList = [];
  List<String> selectedVillageList = [];

  int pagesPerBatch = 10;

  Future<List<Product>> getActiveBidProducts() async {
    List<Bid> bids = await dbConnection.getAllBids("Active");

    List<Product> products = [];

    for(Bid bid in bids)
      {
        Product prod = await dbConnection.getProduct(bid.productId);
        products.add(prod);
      }
    bidList.addAll(bids); // ORDER OF GET IN PRODUCTS AND BIDS ??
    return products;
  }

  Widget tilesInfo(String property, IconData icon, String propertyValue)
  {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(property,style: TextStyle(color: Colors.grey, fontSize: 15)),
          RichText(
              text: TextSpan(
                  children : [
                    // WidgetSpan(
                    //     child: Icon(icon,size: 25,color: Colors.green[700])),
                    WidgetSpan(
                        child: SizedBox(width: 1.0)),
                    TextSpan(
                      text: propertyValue,
                      style: TextStyle(color: Colors.black,
                          fontSize: 20),
                    ),
                  ]
              )),

        ]);
  }

  Widget showProductTiles(BuildContext context, List<Product> productsList,int index) {

    final border = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    );
    final padding = const EdgeInsets.all(4.0);

    String differenceInYears = '';
    if( index < productsList.length ) {
      Duration dur = DateTime.now().difference(
          productsList[index].age);
      differenceInYears = (dur.inDays / 365).floor().toString();
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return ProductDetails(product: productsList[index], bid: bidList[index]);
            },
          ),
        );
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
                  title: Text( getTranslated(context, (productsList[index].category.toLowerCase() + "_category_key")).toUpperCase() + " - " + productsList[index].size.toString() + " " + toBeginningOfSentenceCase(getTranslated(context, "bigha_key")) + " - "
                               + productsList[index].location, style: TextStyle( color : Colors.green[600], fontSize: 25)),
                ),
                //Row(
                  //children: <Widget>[
                    //Expanded(
                     // child:
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Colors.green[500],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),

                          child: (productsList[index].image1 != "File not uploaded" ) ? Image.network(
                            "${productsList[index].image1}" ,
                            fit: BoxFit.cover,
                          ) : Text(getTranslated(context, "no_image_key")),
                        ),
                      ),
                    //),
                    SizedBox(height: 15),
                    //Expanded(
                    //  child:
                      Row(
                        children: [
                          SizedBox(width: 10.0,),
                          Text(getTranslated(context, "days_left_key") + " : ",style: TextStyle(fontSize: 20, color: Colors.red)),
                          Text("${(bidList[index].endTime.difference(DateTime.now())).inDays}",style: TextStyle(fontSize: 20)),
                          SizedBox(width: 20.0,),
                          ( bidList[index].bidders.length > 0 ) ? Text("${bidList[index].bidders[0]}" , style: TextStyle(fontSize: 23, color: Colors.black))
                                                                : Text("- " + getTranslated(context, "no_bids_key"),style: TextStyle(fontSize: 20)),
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child:( bidList[index].bidders.length > 0 ) ? Text('\u{20B9} ' + "${bidList[index].bidVal[0]}",
                                          style: TextStyle(fontSize: 23, color: Colors.black),) : Text('\u{20B9} ' + "-", style: TextStyle(fontSize: 23)),

                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 10.0,),
                          tilesInfo(toBeginningOfSentenceCase(getTranslated(context, "owner_key")), Icons.account_circle, productsList[index].owner),
                          SizedBox(width: 10.0,),
                          tilesInfo(toBeginningOfSentenceCase(getTranslated(context, "location_key")), Icons.place, productsList[index].location),
                          SizedBox(width: 10.0,),
                          tilesInfo(toBeginningOfSentenceCase(getTranslated(context, "age_key")), Icons.nature_people, differenceInYears),
                          SizedBox(width: 10.0,),
                          tilesInfo(toBeginningOfSentenceCase(getTranslated(context, "size_key")), Icons.fence, (productsList[index].size).toString()),
                          SizedBox(width: 10.0,),
                          tilesInfo(toBeginningOfSentenceCase(getTranslated(context, "plants_key")), Icons.nature, (productsList[index].noOfPlants).toString()),
                          SizedBox(width: 10.0,),
                          tilesInfo(toBeginningOfSentenceCase(getTranslated(context, "base_price_key")), Icons.monetization_on, (productsList[index].reservePrice).toString()),
                        ],
                      ),
                SizedBox(height: 10.0,),

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
        future: getActiveBidProducts(),
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
              }
              print("Length of snapshot data is ${snapshot.data.length}");
              productsList.addAll(snapshot.data);
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

          return (productsList.length == 0)
              ? Center(
                  child: Text(getTranslated(context, "zero_active_bids_key") + " !!!",
                      style: TextStyle(color: Colors.black, fontSize: 30)))
              : Column(children: [
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
                            (snapshot.data.length <= pagesPerBatch || snapshot.data.length == 0))
                        ? (snapshot.data.length == 0 || snapshot.data.length < pagesPerBatch)
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
                          ? ((!selectedVillageList.contains(productsList[index - 1].location)) // if selected filter does not contain village
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

    return Scaffold(
        drawer: NavDrawer(),
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(getTranslated(context, "live_bidding_key").toUpperCase()),
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //dropDownList(),
        // RaisedButton.icon(
        //     icon: Icon(CupertinoIcons.hammer_fill),
        //     label: Text('START BIDDING'),
        //     color: Colors.green,
        //     onPressed: () {
        //       startBidding(index);
        //     }),

          RaisedButton.icon(
              icon: Icon(Icons.stop),
              label: Text(getTranslated(context, "stop_bidding_key").toUpperCase()),
              color: Colors.redAccent,
              onPressed: () {}),

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

  startBidding( int index )
  {
    Bid bid = new Bid();

    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);
    bid.id = productsList[index].id + "#" + date.toString();
    bid.productId = productsList[index].id;
    bid.startTime = date;
    bid.endTime = date.add(new Duration( days: int.parse(selectedDuration) ));
    bid.basePrice = productsList[index].reservePrice;
    bid.type = "Best Price";

    dbConnection.addNewBid(bid);
  }
}