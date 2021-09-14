import 'package:bidding_market/screens/authenticate/authenticate.dart';
import 'package:bidding_market/services/auth.dart';
import 'package:bidding_market/services/language_constants.dart';
import 'package:bidding_market/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:bidding_market/services/database.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:countup/countup.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'nav-drawer.dart';

class Dashboard extends StatelessWidget {
  //const Dashboard({Key? key}) : super(key: key);

  DatabaseService dbConnection = DatabaseService();
  final AuthService _auth = AuthService();

  Material listTiles(String heading, int count, int color) {
    return Material(
      color: new Color(color),
      elevation: 14.0,
      shadowColor: Color(0x802196F3),
      borderRadius: BorderRadius.circular(24.0.sp),
      child: Padding(
        padding: EdgeInsets.all(8.0.sp),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0.sp),
                      child: Text(heading,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 35.sp,
                      ),),
                    ),
                  ),
      ]
    ),
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
                  //Counter
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0.sp),
                      child: Countup(
                        begin: 0,
                        end: count.toDouble(),
                        duration: Duration(seconds: 1),
                        separator: ',',
                        style: TextStyle(
                          fontSize: 40.sp,
                          color: Colors.white,
                        ),
                      )
                    ),
                  )
                ],
              ),
            ],
          )
        ),
      ),
    );
  }

  Widget showGridView() {
    List<dynamic> counterDetails = List.filled(4, 0);
    return FutureBuilder(
        future: dbConnection.getCounterDetails(),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if(!snapshot.hasData)
          {
            return Loading();
          }
          else if(snapshot.hasData)
            {
              print("Length of snapshot data is ${snapshot.data.length}");
              print("snapshot- ${snapshot.data}");
              //counterDetails.fillRange(0, 3, snapshot.data);
              counterDetails[0] = snapshot.data[0];
              counterDetails[1] = snapshot.data[1];
              counterDetails[2] = snapshot.data[2];
              counterDetails[3] = snapshot.data[3];
            }
          return StaggeredGridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12.0.w,
              mainAxisSpacing: 8.0.h,
            padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 8.0.h),
            children: <Widget>[
              listTiles(toBeginningOfSentenceCase(getTranslated(context, "product_key")), counterDetails[0], 0xffed622b),
              listTiles(toBeginningOfSentenceCase(getTranslated(context, "buyer_key")), counterDetails[1], 0xff26cbc3),
              listTiles(toBeginningOfSentenceCase(getTranslated(context, "farmer_key")), counterDetails[2], 0xffff3266),
              listTiles(toBeginningOfSentenceCase(getTranslated(context, "live_bids_key")), counterDetails[3], 0xff3399fe)
            ],
          staggeredTiles: [
            StaggeredTile.extent(2, 250.0.h),
            StaggeredTile.extent(1, 250.0.h),
          StaggeredTile.extent(1, 250.0.h),
          StaggeredTile.extent(2, 250.0.h),
          ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavDrawer(),
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
              toBeginningOfSentenceCase(getTranslated(context, "dashboard_key"))),
          backgroundColor: Colors.green[700],
          elevation: 0.0,
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.person),
              label: Text(getTranslated(context, "logout_key")),
              onPressed: () async {
                //Navigator.of(context).pop();
                await _auth.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) => Authenticate()),
                    (Route<dynamic> route) => false);
                //PhoneAuthDataProvider().signOut();
              },
            ),
          ],
        ),
        body: showGridView());
  }
}
