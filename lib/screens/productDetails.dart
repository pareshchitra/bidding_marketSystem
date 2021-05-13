import 'package:bidding_market/models/products.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class ProductDetails extends StatefulWidget {
  final Product product;

  ProductDetails({this.product});

  @override
  _ProductDetails createState() => _ProductDetails(product);
}

class _ProductDetails extends State<ProductDetails>
    with TickerProviderStateMixin {
  final Product product;

  _ProductDetails(this.product);


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
          "FARM DETAIL",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: _buildProductDetailsPage(context),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
                SizedBox(height: 20.0),
                _buildMoreInfoHeader(),
                SizedBox(height: 6.0),
                _buildDivider(screenSize),
                SizedBox(height: 4.0),
                _buildMoreInfoData(),
                SizedBox(height: 24.0),
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
                      return (image != null) ? Image.network(
                        image,
                      ) : Container(alignment: Alignment.center,child: Text("No Image Available !! \nPlease Update Farm Photos"));
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
          product.category + " - " + product.size.toString() + " Bheega - " + product.location,
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
            "\u{20B9}${product.reservePrice}",
            style: TextStyle(fontSize: 16.0, color: Colors.black),
          ),
          SizedBox(
            width: 8.0,
          ),
          Text(
            "\u{20B9}${product.reservePrice}",
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
            "Tap to get further info",
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
                "Size",
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          Text(
            "SIZE CHART",
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
                  "DESCRIPTION",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "OWNER",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            height: 60.0,
            child: TabBarView(
              controller: tabController,
              children: <Widget>[
                Text(
                  product.description == null
                      ? "Details unavailable"
                      : product.description,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                Text(
                  product.owner,
                  style: TextStyle(
                    color: Colors.black,
                  ),
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
        "LOCATION",
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
        "MORE INFO",
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
        "Product Code: ${product
            .id}\nSize: ${product.size} Bheega",
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
            child: RaisedButton(
              onPressed: () {},
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
                      "PLACE A BID",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Flexible(
          //   flex: 2,
          //   child: RaisedButton(
          //     onPressed: () {},
          //     color: Colors.greenAccent,
          //     child: Center(
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: <Widget>[
          //           Icon(
          //             Icons.card_travel,
          //             color: Colors.white,
          //           ),
          //           SizedBox(
          //             width: 4.0,
          //           ),
          //           Text(
          //             "ADD TO BAG",
          //             style: TextStyle(color: Colors.white),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}