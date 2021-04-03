import 'dart:io';
import 'package:bidding_market/screens/authenticate/phone_auth.dart';
import 'package:bidding_market/screens/authenticate/sign_in.dart';
import 'package:bidding_market/services/database.dart';
import 'package:flutter/material.dart';
import 'package:bidding_market/screens/wrapper.dart';
import 'package:bidding_market/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:bidding_market/models/user.dart';

User loggedUser = User(type:0, PhoneNo: "NA");


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return StreamProvider<User>.value(
      value: PhoneAuthDataProvider().user,
      child: MaterialApp(debugShowCheckedModeBanner: false,
        home: Wrapper(),
      ),
    );

    // return MultiProvider(
    //   providers: [
    //
    //     ChangeNotifierProvider(
    //       create: (context) => PhoneAuthDataProvider(),
    //     ),
    //   ],
    //
    //   child: MaterialApp(
    //     home: Wrapper(),
    //     debugShowCheckedModeBanner: false,
    //   ),
    // );
  }
}


