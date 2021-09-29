import 'dart:ffi';

import 'package:bidding_market/main.dart';
import 'package:bidding_market/models/bid.dart';
import 'package:bidding_market/models/products.dart';

import 'package:bidding_market/services/database.dart';
import 'package:bidding_market/services/language_constants.dart';
import 'package:bidding_market/shared/constants.dart';
import 'package:bidding_market/shared/regFunctions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class ProductDetails extends StatefulWidget {
  final Product product;
  final Bid bid;
  String userPhoneNo;
  ProductDetails({this.product, this.bid, this.userPhoneNo});

  @override
  _ProductDetails createState() => _ProductDetails(product,bid,userPhoneNo);
}

class _ProductDetails extends State<ProductDetails>
    with TickerProviderStateMixin {
  final Product product;
  final Bid bid;
  String userPhoneNo;
  _ProductDetails(this.product, this.bid, this.userPhoneNo);


  DatabaseService dbConnection = DatabaseService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: 40.0,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.white,
        title: Text(
          getTranslated(context, "farm_detail_key").toUpperCase(),
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: _buildProductDetailsPage(context),
      bottomNavigationBar: (bid != null && loggedUser.type == 1)?_buildBottomNavigationBar() :SizedBox(),
    );
  }

  _buildProductDetailsPage(BuildContext context) {
    List productImages = [];
    productImages.addAll([product.image1, product.image2, product.image3]);
    Size screenSize = MediaQuery.of(context).size;

    return ListView(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(4.0),
          child: Card(
            elevation: 4.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildProductImagesWidgets(productImages),
                _buildProductTitleWidget(),
                SizedBox(height: 12.0),
                _buildPriceWidgets(),
                SizedBox(height: 12.0),
                //_buildDivider(screenSize),
                //SizedBox(height: 12.0),
                //_buildFurtherInfoWidget(),
                //SizedBox(height: 12.0),
                //_buildDivider(screenSize),
                //SizedBox(height: 12.0),
                //_buildSizeChartWidgets(),
                //SizedBox(height: 12.0),
                _buildDetailsAndMaterialWidgets(),
                SizedBox(height: 12.0),
                _buildStyleNoteHeader(),
                SizedBox(height: 6.0),
                _buildDivider(screenSize),
                SizedBox(height: 4.0),
                _buildStyleNoteData(),
                SizedBox(height: 10.0),
                //_buildMoreInfoHeader(),
                //SizedBox(height: 6.0),
                //_buildDivider(screenSize),
                //SizedBox(height: 4.0),
                //_buildMoreInfoData(),
                //SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _buildDivider(Size screenSize) {
    return Column(
      children: <Widget>[
        Container(
          color: Colors.grey[600],
          width: screenSize.width,
          height: 0.25,
        ),
      ],
    );
  }

  _buildProductImagesWidgets(List productImages) {
    TabController imagesController =
    TabController(length: productImages.length, vsync: this);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 250.0,
        child: Center(
          child: DefaultTabController(
            length: productImages.length,
            child: Stack(
              children: <Widget>[
                TabBarView(
                  controller: imagesController,
                  children: productImages.map(
                        (image) {
                      return (image != null && image != "") ? Image.network(
                        image,
                      ) : Container(alignment: Alignment.center,child: Text(toBeginningOfSentenceCase(getTranslated(context, "no_image_key")) +" !! \n" + toBeginningOfSentenceCase(getTranslated(context, "update_farm_photos_key"))));
                    },
                  ).toList(),
                ),
                Container(
                  alignment: FractionalOffset(0.5, 0.95),
                  child: TabPageSelector(
                    controller: imagesController,
                    selectedColor: Colors.grey,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildProductTitleWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Center(
        child: Text(
          //name,
          getTranslated(context, (product.category.toLowerCase() + "_category_key")).toUpperCase() + " - " + prettifyDouble(product.size) + " " + toBeginningOfSentenceCase(getTranslated(context, "bigha_key")) + " - " + product.location,
          style: TextStyle(fontSize: 16.0, color: Colors.black),
        ),
      ),
    );
  }

  _buildPriceWidgets() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            "${currencyFormat.format(product.reservePrice)}",
            style: TextStyle(fontSize: 16.0, color: Colors.black),
          ),
          SizedBox(
            width: 8.0,
          ),
          Text(
            "${currencyFormat.format(product.reservePrice)}",
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          SizedBox(
            width: 8.0,
          ),
          // Text(
          //   "${product.discount}% Off",
          //   style: TextStyle(
          //     fontSize: 12.0,
          //     color: Colors.blue[700],
          //   ),
          // ),
        ],
      ),
    );
  }

  _buildFurtherInfoWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.local_offer,
            color: Colors.grey[500],
          ),
          SizedBox(
            width: 12.0,
          ),
          Text(
            toBeginningOfSentenceCase(getTranslated(context, "tap_further_info_key")),
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  _buildSizeChartWidgets() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.straighten,
                color: Colors.grey[600],
              ),
              SizedBox(
                width: 12.0,
              ),
              Text(
                toBeginningOfSentenceCase(getTranslated(context, "size_key")),
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          Text(
            getTranslated(context, "size_chart_key").toUpperCase(),
            style: TextStyle(
              color: Colors.blue[400],
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }

  _buildDetailsAndMaterialWidgets() {
    TabController tabController = new TabController(length: 2, vsync: this);
    if (userPhoneNo == null) userPhoneNo = "XXXXX-XXXXX";
    // String userPhoneNo = "XXXXX-XXXXX";
    // if( SharedPrefs().adminId != "" &&
    //     FireBase.auth.currentUser == null ) {
    //   userPhoneNo = await dbConnection.getUserPhoneNo(
    //       product.id.split("#")[0]);
    // }
    String price1 = currencyFormat.format(30*100*product.noOfPlants);
    String price2 = currencyFormat.format(30*150*product.noOfPlants);
    product.description =
        getTranslated(context, (product.category.toLowerCase() + "_category_key")).toUpperCase() + ": " +
            getTranslated(context, "product_description_key_1") + getTranslated(context, (product.category.toLowerCase() + "_category_key")).toUpperCase() +
            getTranslated(context, "product_description_key_2");
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TabBar(
            controller: tabController,
            tabs: <Widget>[
              Tab(
                child: Text(
                  getTranslated(context, "description_key").toUpperCase(),
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  getTranslated(context, "owner_key").toUpperCase(),
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            height: 120.0,
            child: TabBarView(
              controller: tabController,
              children: <Widget>[
                Text(
                  product.description == null
                      ? toBeginningOfSentenceCase(getTranslated(context, "details_unavailable_key"))
                      : product.description,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      product.owner,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      getTranslated(context, "contact_key") + ": " +userPhoneNo,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildStyleNoteHeader() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 12.0,
      ),
      child: Text(
        getTranslated(context, "location_key").toUpperCase(),
        style: TextStyle(
          color: Colors.grey[800],
        ),
      ),
    );
  }

  _buildStyleNoteData() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 12.0,
      ),
      child: Text(
        product.location,
        style: TextStyle(
          color: Colors.grey[600],
        ),
      ),
    );
  }

  _buildMoreInfoHeader() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 12.0,
      ),
      child: Text(
        getTranslated(context, "more_info_key").toUpperCase(),
        style: TextStyle(
          color: Colors.grey[800],
        ),
      ),
    );
  }

  _buildMoreInfoData() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 12.0,
      ),
      child: Text(
      toBeginningOfSentenceCase(getTranslated(context, "size_key")) + ": ${prettifyDouble(product.size)} " + toBeginningOfSentenceCase(getTranslated(context, "bigha_key")),
        style: TextStyle(
          color: Colors.grey[600],
        ),
      ),
    );
  }

  _buildBottomNavigationBar() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: priceDropDownList(),
          ),

          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: RaisedButton(
              onPressed: () { placeBid(); },
              color: Colors.green,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      CupertinoIcons.hammer_fill,
                      //color: Colors.green,
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      getTranslated(context, "place_bid_key").toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }


  List<String> priceList(double currentPrice)
  {
    List<String> prList = [];
    double price = currentPrice;

    int count = 0;
    while( count < 10 )
      {
        price = price + bid.priceIncrement;
       // if( bid.bidVal.length > 0 && price > bid.bidVal[0]) {
          prList.add(price.toString());
          count++;
        //}
        // else if( bid.bidVal.length == 0 ) {
        //   prList.add(price.toString());
        //   count++;
        // }
      }
    return prList;
  }

  String selectedPrice;
  Widget priceDropDownList()
  {
    double currentPrice = bid.basePrice;
    if( bid.bidVal.length > 0 && currentPrice < bid.bidVal[0])
      currentPrice = bid.bidVal[0];
    return DropdownButton<String>(
      value: selectedPrice,
      //elevation: 5,
      style: TextStyle(color: Colors.black),

      items: priceList(currentPrice).map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(currencyFormat.format(double.parse(value))),
        );
      }).toList(),
      hint: Text(
        toBeginningOfSentenceCase(getTranslated(context, "choose_amount_key")),
        style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600),
      ),
      onChanged: (String value) {
        setState(() {
          selectedPrice = value;
        });
      },
    );
  }

  callDbPlaceBid()
  {
    dbConnection
        .updateBidder(bid.id, loggedUser.uid, loggedUser.Name,
            double.parse(selectedPrice), product.id)
        .then((value) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text(toBeginningOfSentenceCase(
                    getTranslated(context, "alert_dialog_key"))),
                content: Text(
                    "Bid placed successfully with amount $selectedPrice !!!"),
                actions: <Widget>[
                  FlatButton(
                    child: Text(getTranslated(context, "ok_key").toUpperCase()),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ]);
          });
    }).catchError((errorMsg) =>
            print("Place bid database operation failed with msg : $errorMsg"));
  }

  placeBid() async
  {
    bool verificationStatus = await dbConnection.getVerificationStatus(loggedUser.uid);
    if( verificationStatus ) {  // Only Verified Users must be allowed to place bids
      // currentPrice is to populate price list in UI & currentBidPrice is for runtime check to avoid conflict in buyers placing same bids TODO: stream listener for prices
      double currentPrice = bid.basePrice;
      if( bid.bidVal.length > 0 && currentPrice < bid.bidVal[0])
        currentPrice = bid.bidVal[0];
      List<String> validPrices = priceList(currentPrice);
      if (validPrices.contains(selectedPrice)) {  // Amount selected from list UI check
        Bid currentBid = await dbConnection.getBid(bid.id);  // GET CURRENT BID PRICE FROM DB AT RUNTIME
        double currentBidPrice = currentBid.basePrice;
        if( currentBid.bidVal.length > 0 )
          currentBidPrice = currentBid.bidVal[0];
        print("Current price of this bid is $currentBidPrice");

        if( currentBidPrice >= double.parse(selectedPrice) ) // CHECK IF OTHER BIDDER HAS ALREADY AUCTIONED FOR THIS BID AT RUNTIME
          {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: Text(toBeginningOfSentenceCase(
                          getTranslated(context, "alert_dialog_key"))),
                      content: Text(
                          getTranslated(context, "bid_already_placed_key") +
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
        else {
          showDialog(  // Confirm bid placement from user
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                    title: Text(toBeginningOfSentenceCase(
                        getTranslated(context, "alert_dialog_key"))),
                    content: Text(
                        getTranslated(context, "price_bid_confirm_key_1") +
                            " $selectedPrice " +
                            getTranslated(context, "price_bid_confirm_key_2")),
                    actions: <Widget>[
                      FlatButton(
                          child: Text(toBeginningOfSentenceCase(
                              getTranslated(context, "yes_key"))),
                          onPressed: () {
                            Navigator.of(context).pop();
                            callDbPlaceBid();
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
      }
      else {
        showDialog( // Bid amount not selected from dropdown list
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  title: Text(toBeginningOfSentenceCase(
                      getTranslated(context, "alert_dialog_key"))),
                  content: Text(
                      getTranslated(context, "choose_amount_alert_key") +
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
    else {  // If buyer is not verified
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text(toBeginningOfSentenceCase(
                    getTranslated(context, "alert_dialog_key"))),
                content: Text(
                    "Your account is not verified!! Contact support to get verification done" +
                        " !!") ,  //TODO: Hindi Text
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
}