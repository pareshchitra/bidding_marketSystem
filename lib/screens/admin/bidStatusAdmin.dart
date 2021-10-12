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
import 'package:bidding_market/shared/constants.dart';
import 'package:bidding_market/shared/nav-drawer.dart';
import 'package:bidding_market/shared/regFunctions.dart';
import 'package:bidding_market/shared/sharedPrefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:filter_list/filter_list.dart';



class BidStatusAdmin extends StatefulWidget {

  @override
  _BidStatusAdminState createState() => _BidStatusAdminState();
}

class _BidStatusAdminState extends State<BidStatusAdmin> {
  final AuthService _auth = AuthService();

  DatabaseService dbConnection = DatabaseService();

  List<Product> productsList = [];
  Stream<List<Bid>> bidsListFuture;
  List<Bid> bidList = [];
  List<String>  villageList = [];
  List<String> selectedVillageList = [];
  List<String> pincodeList = [];
  List<String> selectedPincodeList = [];
  Map<Product, String> prodPinMap = new Map();
  Map<Bid, Product> bidProdMap = new Map();

  int pagesPerBatch = 10;
  List<Map<String,bool>> biddersCheckboxList = new List();

  @override
  void initState() {
    super.initState();

    // initial load
    bidsListFuture = dbConnection.dbBidCollection.orderBy("Bids", descending: true).snapshots()
    .asyncMap((bidDocs) => Future.wait([for (var bidDoc in bidDocs.docs) generateBid(bidDoc),for (var bidDoc in bidDocs.docs) generateProduct(bidDoc) ] ));

  }

  Future<Bid> generateBid(QueryDocumentSnapshot document) async {
    Bid bid = new Bid();
    bid.id = document.id;
    bid.productId = document.data()['ProductId'];
    bid.startTime = document.data()['StartTime'].toDate();
    bid.endTime = document.data()['EndTime'].toDate();
    bid.basePrice = document.data()['BasePrice'];
    bid.status = document.data()['Status'];
    bid.bidWinner = document.data()["BidWinner"];
    bid.finalBidPrice = document.data()["FinalBidPrice"];
    List bidders = document.data()['Bids'];
    bid.bidders = [];
    bid.bidVal = [];
    for(var bidder in bidders)
    {
      if( bidder['name'] != null )
        bid.bidders.add(bidder['name']);
      if( bidder['price'] != null )
        bid.bidVal.add(double.parse(bidder['price']));
    }

    print("Bid ${bid.id} bidders are ${bid.bidders}");
    // Product prod = await dbConnection.getProduct(bid.id);
    // productsList.add(prod);
    // QuerySnapshot query = await dbConnection.dbSellerCollection.where("Name", isEqualTo : prod.owner).get();
    // query.docs.forEach((doc) {
    //   String pincode = doc.data()["Pincode"];
    //   pincodeList.add(pincode);
    //   prodPinMap[prod] = pincode;
    // });
    Map<String,bool> bidderCheckbox = new Map();
    for(var count = 0;bid.bidders != null  && count < bid.bidders.length && count < topThreeBidders; count++){
      bidderCheckbox[bid.bidders[count]] = false; // Set default checkbox to false for all bidder
    }
    biddersCheckboxList.add(bidderCheckbox);
    print("Bidders Checkbox list is  $biddersCheckboxList ");
    return bid;

  }


  Future<Bid> generateProduct(QueryDocumentSnapshot document) async {
    String bidId = document.id;
    Product prod = await dbConnection.getProduct(bidId);
    productsList.add(prod);
    String pincode = await dbConnection.getProductPincode(prod);
    pincodeList.add(pincode);
    prodPinMap[prod] = pincode;
  }



  // Future<List<Bid>> getAllBidProducts() async {
  //   List<Bid> bids = await dbConnection.getSellerBidProducts(loggedUser);
  //
  //   List<Product> products = [];
  //
  //   for(Bid bid in bids)
  //   {
  //     Product prod = await dbConnection.getProduct(bid.productId);
  //     products.add(prod);
  //     Map<String,bool> bidderCheckbox = new Map();
  //     for(var count = 0; count < bid.bidders.length && count < topThreeBidders; count++){
  //       bidderCheckbox[bid.bidders[count]] = false; // Set default checkbox to false for all bidder
  //     }
  //     biddersCheckboxList.add(bidderCheckbox);
  //   }
  //   bidList.addAll(bids); // ORDER OF GET IN PRODUCTS AND BIDS ??
  //   return products;
  // }

  Widget tilesInfo(String property, IconData icon, String propertyValue)
  {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(property,style: TextStyle(color: Colors.grey, fontSize: 13)),
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
                          fontSize: 15),
                    ),
                  ]
              )),

        ]);
  }

  Widget showProductTiles(BuildContext context, Map<Bid,Product> bidProductMap,int index) {
    bool isBidActive;
    if( bidList[index].status == "Active" )
      isBidActive = true;
    else
      isBidActive = false;

    Product product = bidProductMap[bidList[index]];
    final border = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    );
    final padding = const EdgeInsets.all(4.0);

    String differenceInYears = '';
    if( index < productsList.length ) {
      Duration dur = DateTime.now().difference(
          product.age);
      differenceInYears = (dur.inDays / 365).floor().toString();
    }

    return InkWell(
      onTap: () {
        // if( SharedPrefs().adminId != "" &&
        //     FireBase.auth.currentUser == null ) {  // Admin is Logged In
        //   Navigator.of(context).push(
        //     MaterialPageRoute(
        //       builder: (context) {
        //         return FutureBuilder<String>(
        //             future: dbConnection.getUserPhoneNo(productsList[index].id.split("#")[0]),
        //             builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        //               if (snapshot.hasData)
        //                 return ProductDetails(product: productsList[index],
        //                   userPhoneNo: snapshot.data,);
        //
        //               return Container(child: CircularProgressIndicator());
        //             }
        //
        //         );
        //       },
        //     ),
        //   );
        // }
        //else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return ProductDetails(
                  product: product, bid: bidList[index]);
            },
          ),
        );
        //}
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
                  title: Text( getTranslated(context, (product.category.toLowerCase() + "_category_key")).toUpperCase()
                      + " - " + prettifyDouble(product.size) + " " + toBeginningOfSentenceCase(getTranslated(context, "bigha_key"))
                      + " - " + product.location, style: TextStyle( color : Colors.green[600], fontSize: 25)),
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
                  height: 200.0,
                  width: 250.0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),

                    child: Center(
                      child: (product.image1 != null && product.image1 != "" ) ? Image.network(
                        "${product.image1}" ,
                        fit: BoxFit.cover,
                      ) : Text(getTranslated(context, "no_image_key")),
                    ),
                  ),
                ),
                //),
                SizedBox(height: 15),
                //Expanded(
                //  child:



                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget> [

                      Text("Bid Status : ${bidList[index].status}" ,
                          style: TextStyle(fontSize: 18, color: Colors.black)),
                      Text("Bid Start Date : ${bidList[index].startTime.day}/ ${bidList[index].startTime.month}/ ${bidList[index].startTime.year}" ,
                          style: TextStyle(fontSize: 18, color: Colors.black)),
                      (isBidActive) ?
                      Text( getTranslated(context, "days_left_key") + ":  ${(bidList[index].endTime.difference(DateTime.now())).inDays}" ,
                          style: TextStyle(fontSize: 18, color: Colors.black))
                          : Text("Bid Ended On : ${bidList[index].endTime.day}/ ${bidList[index].endTime.month}/ ${bidList[index].endTime.year}" ,
                          style: TextStyle(fontSize: 18, color: Colors.black)),

                      (bidList[index].bidWinner != null) ?
                      (Text("SOLD !!! Bid Winner is ${bidList[index].bidWinner} - ${currencyFormat.format(bidList[index].finalBidPrice)}" ,
                          style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)))
                          : (

                          (bidList[index].bidders.length == 0) ?  (Text("No Bidders !!!" ,
                              style: TextStyle(fontSize: 18, color: Colors.black)))
                              : SizedBox(height: 0) ),


                      for(var count = 0; (bidList[index].bidWinner == null) && count < biddersCheckboxList[index].length
                          && count < topThreeBidders; count++)
                        (isBidActive) ? ( new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              (bidList[index].bidders[count] != null) ? Text(
                                  "${count+1}. ${bidList[index].bidders[count]}",
                                  style: TextStyle(fontSize: 18, color: Colors
                                      .black))
                                  : Text(
                                  "${count+1}. -  ", style: TextStyle(fontSize: 18)),
                              (bidList[index].bidders[count] != null) ? Text(
                                "  ${currencyFormat.format(bidList[index]
                                    .bidVal[count])}",
                                style: TextStyle(fontSize: 18, color: Colors
                                    .black, fontWeight: FontWeight.bold),)
                                  : Text('\u{20B9} ' + "-",
                                  style: TextStyle(fontSize: 18))
                            ]) )
                            :
                        new //Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        //children: [
                        CheckboxListTile(
                          title: Text("${count+1}. " + biddersCheckboxList[index].keys.elementAt(count) + " -  ${currencyFormat.format(bidList[index].bidVal[count])}"),
                          value: biddersCheckboxList[index][biddersCheckboxList[index].keys.elementAt(count)],
                          contentPadding: EdgeInsets.only(left:60.0, right:60.0, top:0.0, bottom:0.0),
                          onChanged: (bool value){
                            setState(() {
                              if( value == true ){
                                for(var count = 0; count < bidList[index].bidders.length && count < topThreeBidders; count++){
                                  biddersCheckboxList[index][bidList[index].bidders[count]] = false; // Set default checkbox to false for all bidder
                                }
                              }
                              biddersCheckboxList[index][biddersCheckboxList[index].keys.elementAt(count)] = value;
                            });
                          },
                        ),
                      (bidList[index].bidWinner == null && !isBidActive) ?
                      RaisedButton.icon(
                          icon: Icon(Icons.verified_user),
                          label: Text(getTranslated(context, "select_bid_winner_key").toUpperCase()),
                          color: Colors.grey,
                          onPressed: () { selectBidWinner(bidList[index], index); }
                      )
                          : SizedBox(height:0),
                      //]),
                    ]),
                // Row(
                //   children: [
                //     SizedBox(width: 10.0,),
                //     Text(getTranslated(context, "days_left_key") + " : ",style: TextStyle(fontSize: 20, color: Colors.red)),
                //     Text("${(bidList[index].endTime.difference(DateTime.now())).inDays}",style: TextStyle(fontSize: 20)),
                //     SizedBox(width: 10.0,),
                //     // ( bidList[index].bidders.length > 0 ) ? Text("${bidList[index].bidders[0]}" ,
                //     //                                         style: TextStyle(fontSize: 23, color: Colors.cyan))
                //     //     : Text("- " + getTranslated(context, "no_bids_key"),style: TextStyle(fontSize: 20)),,
                //   ],
                // ),
                SizedBox(height: 10.0,),
                Row(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 10.0,),
                      tilesInfo(toBeginningOfSentenceCase(getTranslated(context, "owner_key")), Icons.account_circle, product.owner),
                      SizedBox(width: 10.0,),
                      Expanded(child:
                      tilesInfo(toBeginningOfSentenceCase(getTranslated(context, "location_key")), Icons.place, product.location),)
                    ]),
                Row(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 10.0,),
                    tilesInfo(toBeginningOfSentenceCase(getTranslated(context, "age_key")), Icons.nature_people, differenceInYears),
                    SizedBox(width: 10.0,),
                    tilesInfo(toBeginningOfSentenceCase(getTranslated(context, "size_key")), Icons.fence, prettifyDouble(product.size) ),
                    SizedBox(width: 10.0,),
                    tilesInfo(toBeginningOfSentenceCase(getTranslated(context, "plants_key")), Icons.nature, (product.noOfPlants).toString()),
                    SizedBox(width: 10.0,),
                    Expanded(child:
                    tilesInfo(toBeginningOfSentenceCase(getTranslated(context, "base_price_key")), Icons.monetization_on, (currencyFormat.format(product.reservePrice)).toString())
                    ),
                  ],
                ),
                SizedBox(height: 5.0,),

                // RaisedButton.icon(
                //     icon: Icon(Icons.verified_user),
                //     label: Text(getTranslated(context, "select_bid_winner_key").toUpperCase()),
                //     color: Colors.grey,
                //     onPressed: () { selectBidWinner(bidList[index], index); }
                // ),



              ],
            ),
          )),
    );
  }

  callDbBidWinnerUpdate(String bidId, String bidderName, double bidValue, int index)
  {
    dbConnection.updateBidWinner(bidId, bidderName, bidValue)
        .then((value) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text(toBeginningOfSentenceCase(
                    getTranslated(context, "alert_dialog_key"))),
                content: Text(
                    "Bid Winner successfully updated as $bidderName !!!"),
                actions: <Widget>[
                  FlatButton(
                    child: Text(getTranslated(context, "ok_key").toUpperCase()),
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        bidList[index].bidWinner = bidderName;
                        bidList[index].finalBidPrice = bidValue;
                      });
                    },
                  ),
                ]);
          });
    }).catchError((errorMsg) =>
        print("Update bid winner database operation failed with msg : $errorMsg"));
  }

  selectBidWinner(Bid bid, int index){
    if(biddersCheckboxList[index].containsValue(true)){
      String bidderName;
      double bidValue;
      for(MapEntry map in biddersCheckboxList[index].entries){
        if(map.value == true) {
          bidderName = map.key;
          bidValue = bid.bidVal[bid.bidders.indexOf(bidderName)];
        }
      }
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text(toBeginningOfSentenceCase(
                    getTranslated(context, "alert_dialog_key"))),
                content: Text(
                    getTranslated(context, "select_bidder_confirm_key_1") +
                        " $bidderName " +
                        getTranslated(context, "select_bidder_confirm_key_2")),
                actions: <Widget>[
                  FlatButton(
                      child: Text(toBeginningOfSentenceCase(
                          getTranslated(context, "yes_key"))),
                      onPressed: () {
                        Navigator.of(context).pop();
                        callDbBidWinnerUpdate(bid.id, bidderName, bidValue, index);
                      }),
                  FlatButton(
                    child: Text(toBeginningOfSentenceCase(
                        getTranslated(context, "no_key"))),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ]);
          });
    }
    else{ // No Bidder checkbox is selected
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text(toBeginningOfSentenceCase(
                    getTranslated(context, "alert_dialog_key"))),
                content: Text(
                    getTranslated(context, "select_bidder_alert_key") +
                        " !!"),
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
  }

  Widget showList() {
    return StreamBuilder(
        stream: bidsListFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Bid>> snapshot) {
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
          if(snapshot.hasData) {
            // if (productsList == null) {
            //   productsList = [];
            // }
            print("Length of snapshot data is ${snapshot.data.length}");
            snapshot.data.forEach((bid) { if( bid != null ) bidList.add(bid); });

            for( Bid bid in bidList) {
              int index = productsList.indexWhere((product) => product.id == bid.id);
              bidProdMap[bid] = productsList[index];
            }
            print("products list ids are");
            int count = 0, count1=0, i=0;
            bidProdMap.entries.forEach((entry) { print("Bid id is ${entry.key.id}"); print("Product id is ${entry.value.id}");});

            print("Bids list ids are");
            i = 0 ;
            for( Bid b in bidList )
            {
              count1++;
              if( b != null )
                print(" ${i++} + ${b.id} ");
            }
            print("bid count is $count1");
            //bidList.forEach((bid) {print(bid.id + " ");});
            // productsList.sort((a, b) =>
            // a.lastUpdatedOn.isBefore(b.lastUpdatedOn) == true ? 1 : 0);
            for (Product product in productsList)
              villageList.add(product.location);
            villageList = villageList.toSet().toList();
            pincodeList = pincodeList.toSet().toList();
            print("Village List is $villageList");
            print("Pincode List is $pincodeList");

            return (productsList.length == 0)
                ? Center(
                child: Text(
                    getTranslated(context, "zero_active_bids_key") + " !!!",
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
                itemCount: productsList.length + 1, //  +1 for the filter button
                itemBuilder: (ctx, index) {
                  if( index == 0 )
                  {
                    return Container(
                      alignment: Alignment.topRight,
                      color: Colors.brown[200],
                      child: Row(
                        children: [
                          RaisedButton.icon(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                side: BorderSide(color: Colors.red)
                            ),
                            icon: Icon(Icons.filter_alt_outlined),
                            onPressed: _openVillageFilterList,
                            label : Text(toBeginningOfSentenceCase(getTranslated(context, "village_filter_key"))),
                            color: Colors.red[100],

                          ),
                          RaisedButton.icon(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                side: BorderSide(color: Colors.red)
                            ),
                            icon: Icon(Icons.filter_alt_outlined),
                            onPressed: _openPincodeFilterList,
                            label : Text(toBeginningOfSentenceCase(getTranslated(context, "pincode_filter_key"))),
                            color: Colors.red[100],

                          ),
                        ],
                      ),
                    );
                  }

                  print("Length of snapshot data is ${snapshot.data
                      .length} && index is $index");
                  Product currentProd = bidProdMap[bidList[index - 1]];
                  return (filterCondition() == true)
                      ? ((!selectedVillageList.contains(currentProd.location) && !(selectedPincodeList.contains(prodPinMap[currentProd]))) // if selected filter does not contain village and pincode
                          ? SizedBox(height: 0)
                          : showProductTiles(context, bidProdMap, index - 1))
                      : showProductTiles(context, bidProdMap, index - 1);

                },
              )
              )
            ]);
          }
          else{
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
        });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        drawer: NavDrawer(),
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(getTranslated(context, "bid_status_key").toUpperCase()),
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

  void _openVillageFilterList() async {
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


  void _openPincodeFilterList() async {
    FilterListDialog.display<String>(
        context,
        listData: pincodeList,
        selectedListData: selectedPincodeList,
        height: 480,
        headlineText: toBeginningOfSentenceCase(getTranslated(context, "select_pincode_key")),
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
              selectedPincodeList = List.from(list);
            });
          }
          Navigator.pop(context);
        });
  }

  // Returns TRUE if any filter is selected otherwise false
  bool filterCondition() {
    if ((selectedVillageList == null || selectedVillageList.length == 0 ) && (selectedPincodeList == null || selectedPincodeList.length == 0))
      return false;
    else
      return true;
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

}