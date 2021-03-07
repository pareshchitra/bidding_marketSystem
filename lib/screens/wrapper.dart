import 'package:bidding_market/models/user.dart';
import 'package:bidding_market/screens/authenticate/authenticate.dart';
import 'package:bidding_market/screens/authenticate/registerDetails.dart';
import 'package:bidding_market/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bidding_market/main.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);

    // return either the Home or Authenticate widget
    if (user == null){
      return Authenticate();
    } else {
      if(loggedUser.type == 0) //New User
      {
        return RegisterDetails();
      }
      else //Registered User
        {
        return Home();
      }
    }

  }
}