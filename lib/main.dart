import 'package:flutter/material.dart';
import 'package:bidding_market/screens/wrapper.dart';
import 'package:bidding_market/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:bidding_market/models/user.dart';

User loggedUser = User(type:0);

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(debugShowCheckedModeBanner: false,
        home: Wrapper(),
      ),
    );
  }
}


