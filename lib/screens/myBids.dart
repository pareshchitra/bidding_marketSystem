import 'package:bidding_market/main.dart';
import 'package:bidding_market/models/brew.dart';
import 'package:bidding_market/models/products.dart';
import 'package:bidding_market/models/user.dart';
import 'package:bidding_market/screens/authenticate/authenticate.dart';
import 'package:bidding_market/screens/authenticate/phone_auth.dart';
import 'package:bidding_market/screens/home/brew_list.dart';
import 'package:bidding_market/screens/productDetails.dart';
import 'package:bidding_market/screens/registeration/productRegisteration.dart';
import 'package:bidding_market/services/auth.dart';
import 'package:bidding_market/services/database.dart';
import 'package:bidding_market/services/language_constants.dart';
import 'package:bidding_market/shared/constants.dart';
import 'package:bidding_market/shared/nav-drawer.dart';
import 'package:bidding_market/shared/regFunctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filter_list/filter_list.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';



class MyBids extends StatefulWidget {

  @override
  _MyBidsState createState() => _MyBidsState();
}

class _MyBidsState extends State<MyBids> {
  final AuthService _auth = AuthService();

  DatabaseService dbConnection = DatabaseService();

  List<dynamic> bidsMapList ;
  List<String>  villageList = [];
  List<String> selectedVillageList = [];


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

  Widget showProductTiles(BuildContext context, List<dynamic> bidsMapList,int index) {

    final border = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    );
    final padding = const EdgeInsets.all(4.0);

    String differenceInYears = '';
    if( index < bidsMapList.length ) {
      Duration dur = DateTime.now().difference(
          bidsMapList[index]['Product'].age);
      differenceInYears = (dur.inDays / 365).floor().toString();
    }

    int daysLeft = (bidsMapList[index]['Bid'].endTime.difference(DateTime.now())).inDays;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return ProductDetails(product: bidsMapList[index]['Product'], bid: (daysLeft > 0 )? bidsMapList[index]['Bid'] : null);
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
                  title: Text( getTranslated(context, (bidsMapList[index]['Product'].category.toLowerCase() + "_category_key")).toUpperCase() + " - " + prettifyDouble(bidsMapList[index]['Product'].size) + " " + toBeginningOfSentenceCase(getTranslated(context, "bigha_key")) + " - "
                      + bidsMapList[index]['Product'].location, style: TextStyle( color : Colors.green[600], fontSize: 25)),
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
                  height: 250.0,
                  width: 250.0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),

                    child: (bidsMapList[index]['Product'].image1 != null && bidsMapList[index]['Product'].image1 != "" ) ? Image.network(
                      "${bidsMapList[index]['Product'].image1}" ,
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
                    Text(camelCasingFields(getTranslated(context, "status_key")) + " : ",style: TextStyle(fontSize: 20)),
                    // TODO: Mark status when DB field is correct
                    //  Text("${bidsMapList[index]['Bid'].status}",style: TextStyle(fontSize: 20, color: Colors.red)),
                    Text( (daysLeft > 0)? camelCasingFields(getTranslated(context, "active_key")) : camelCasingFields(getTranslated(context, "closed_key")),style: TextStyle(fontSize: 20, color: Colors.red)),
                    SizedBox(width: 20.0,),

                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Text(camelCasingFields(getTranslated(context, "current_bid_key")) + ' : ' + "${currencyFormat.format(bidsMapList[index]['Bid'].bidVal[0])}",
                          style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),) ,

                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    SizedBox(width: 10.0,),
                    (daysLeft > 0)? Text(camelCasingFields(getTranslated(context, "days_left_key")) + " :",style: TextStyle(fontSize: 20, color: Colors.red)) : SizedBox(width:0),
                    (daysLeft > 0)? Text("$daysLeft",style: TextStyle(fontSize: 20)) : SizedBox(width:0),
                    SizedBox(width: 20.0,),
                    // ( bidsMapList[index]['Bid'].bidders.length > 0 ) ? Text("${bidsMapList[index]['Bid'].bidders[0]}" , style: TextStyle(fontSize: 23, color: Colors.black))
                    //     : Text("- No Bids ",style: TextStyle(fontSize: 20)),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Text(camelCasingFields(getTranslated(context, "your_qoute_key")) + ' : ' + "${currencyFormat.format(double.parse(bidsMapList[index]['QuotePrice']))}",
                          style: TextStyle(fontSize: 20, color: Colors.black),) ,

                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.0,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 10.0,),
                    tilesInfo(camelCasingFields(getTranslated(context, "owner_key")), Icons.account_circle, bidsMapList[index]['Product'].owner),
                    SizedBox(width: 10.0,),
                    tilesInfo(camelCasingFields(getTranslated(context, "location_key")), Icons.place, bidsMapList[index]['Product'].location),
                    SizedBox(width: 10.0,),
                    tilesInfo(camelCasingFields(getTranslated(context, "age_key")), Icons.nature_people, differenceInYears),
                    SizedBox(width: 10.0,),
                    tilesInfo(camelCasingFields(getTranslated(context, "size_key")), Icons.fence, prettifyDouble(bidsMapList[index]['Product'].size)),
                    SizedBox(width: 10.0,),
                    tilesInfo(camelCasingFields(getTranslated(context, "plants_key")), Icons.nature, (bidsMapList[index]['Product'].noOfPlants).toString()),
                    SizedBox(width: 10.0,),
                    Expanded(child:
                    tilesInfo(camelCasingFields(getTranslated(context, "base_price_key")), Icons.monetization_on, (currencyFormat.format(bidsMapList[index]['Product'].reservePrice)).toString()),
                    ),
                  ],
                ),
                SizedBox(height: 10.0,),



              ],
            ),
          )),
    );
  }

  Widget showList() {
    return FutureBuilder(
        future: dbConnection.myBids(loggedUser),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
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
              if (bidsMapList == null) {
                bidsMapList = [];
              }
              print("Length of snapshot data is ${snapshot.data.length}");
              bidsMapList.addAll(snapshot.data);
              print("Bids Map list is ");
              print(bidsMapList);
              // productsList.sort((a, b) =>
              // a.lastUpdatedOn.isBefore(b.lastUpdatedOn) == true ? 1 : 0);
              for( int count = 0 ;count < bidsMapList.length; count++ )
                villageList.add(bidsMapList[count]['Product'].location);
              villageList = villageList.toSet().toList();
              print("Village List is $villageList");
            }
          }

          return (  bidsMapList.length == 0 )
              ? Center(
              child: Text(toBeginningOfSentenceCase(getTranslated(context, "bids_not_found_key")) + " !!!",
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
              itemCount: bidsMapList.length + 1, //  +1 for the filter button
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
                      label : Text(camelCasingFields(getTranslated(context, "filter_key"))),
                      color: Colors.red[100],

                    ),
                  );
                }

                print("Length of snapshot data is ${snapshot.data.length} && index is $index");
                return ( filterCondition() == true )
                            ? ((!selectedVillageList.contains(bidsMapList[index - 1]['Product'].location)) // if selected filter does not contain village
                                    ? SizedBox(height: 0)
                                    : showProductTiles(context, bidsMapList, index - 1))
                            : showProductTiles(context, bidsMapList, index - 1);
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
          title: Text(camelCasingFields(getTranslated(context, "my_bids_key"))),
          backgroundColor: Colors.green[700],
          elevation: 0.0,
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.person),
              label: Text(camelCasingFields(getTranslated(context, "logout_key"))),
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
        showList()


    );

  }

  void _openFilterList() async {
    FilterListDialog.display<String>(
        context,
        listData: villageList,
        selectedListData: selectedVillageList,
        height: 480,
        headlineText: camelCasingFields(getTranslated(context, "select_village_key")),
        searchFieldHintText: camelCasingFields(getTranslated(context, "search_here_key")),
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
          title: Text(camelCasingFields(getTranslated(context, "alert_dialog_key"))),
          content: Text(camelCasingFields(getTranslated(context, "delete_confirm_key")) + "?"),
          actions: <Widget>[
            FlatButton(
              child: Text(getTranslated(context, "yes_key").toUpperCase()),
              onPressed: () async{
                Navigator.of(context).pop();
                await dbConnection.deleteProduct(p);
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