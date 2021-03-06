import 'dart:io';

import 'package:bidding_market/screens/authenticate/registerDetails.dart';
import 'package:bidding_market/services/auth.dart';
import 'package:bidding_market/services/database.dart';
import 'package:bidding_market/shared/constants.dart';
import 'package:bidding_market/shared/loading.dart';
import 'package:flutter/material.dart';

import 'BuyerForm.dart';
import 'SellerForm.dart';

class Register extends StatefulWidget {

  final Function toggleView;
  Register({ this.toggleView });

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;
  DatabaseService dbConnection = DatabaseService();

  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0.0,
        title: Text('Sign up to Bidding Market'),
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.person),
            label: Text('Sign In'),
            onPressed: () => widget.toggleView(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Register", style: TextStyle(color: Colors.green[500], fontSize: 36, fontWeight: FontWeight.w500),),

                SizedBox(height: 16,),

                TextFormField(
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[200])
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey[300])
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      hintText: "Mobile Number"

                  ),
                  controller: _phoneController,
                ),

                SizedBox(height: 16,),


                Container(
                  width: double.infinity,
                  child: FlatButton(
                    child: Text("Register"),
                    textColor: Colors.white,
                    padding: EdgeInsets.all(16),
                    onPressed: () async {
                      setState(() => loading = true);
                      final phone = _phoneController.text.trim();

                      await dbConnection.checkIfPhoneExists(phone);
                      //sleep(const Duration(seconds: 1));
                      dynamic result = await _auth.signInWithMobileNumber(phone , context);
                      if(result == null) {
                        setState(() {
                          loading = false;
                          error = 'Could not sign in with those credentials';
                        });
                      }
                    },
                    color: Colors.green[400],
                  ),
                ),

                SizedBox(height: 12.0),
                Text(
                  error,
                  style: TextStyle(color: Colors.red, fontSize: 14.0),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}