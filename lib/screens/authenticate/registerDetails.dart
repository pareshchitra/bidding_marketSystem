import 'package:bidding_market/services/auth.dart';
import 'package:bidding_market/shared/constants.dart';
import 'package:bidding_market/shared/loading.dart';
import 'package:flutter/material.dart';

import 'BuyerForm.dart';
import 'SellerForm.dart';

class RegisterDetails extends StatefulWidget {

  final Function toggleView;
  RegisterDetails({ this.toggleView });

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<RegisterDetails> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;

  // text field state
  String email = '';
  String password = '';

  int clickedButton = 1;

  void toggleForm(int value) {
    setState(() {
      clickedButton = value;
      print(clickedButton);
      //showBuyer = !showBuyer;
    });
  }

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
        scrollDirection: Axis.vertical,
        child: Container(
            margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            child: Column(children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    'I am ',
                    style: TextStyle(fontSize: 25.0, fontFamily: "Georgia"),
                  ),
                  Radio(
                      value: 1,
                      groupValue: clickedButton,
                      onChanged: (value) {
                        print("Buyer Clicked");
                        toggleForm(value);
                      }),
                  Text(
                    'Buyer',
                    style: TextStyle(fontSize: 25.0, fontFamily: "Georgia"),
                  ),
                  Radio(
                      value: 2,
                      groupValue: clickedButton,
                      onChanged: (value) {
                        print("Seller Clicked");
                        toggleForm(value);
                      }),
                  Text(
                    'Seller',
                    style: TextStyle(fontSize: 25.0, fontFamily: "Georgia"),
                  ),
                ],
              ),
              Container(
                child: clickedButton == 1 ? buyerForm() : sellerForm(),
              )
            ])),
      ),
      // body: Container(
      //   padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
      //   child: Form(
      //     key: _formKey,
      //     child: Column(
      //       children: <Widget>[
      //         SizedBox(height: 20.0),
      //         TextFormField(
      //           decoration: textInputDecoration.copyWith(hintText: 'email'),
      //           validator: (val) => val.isEmpty ? 'Enter an email' : null,
      //           onChanged: (val) {
      //             setState(() => email = val);
      //           },
      //         ),
      //         SizedBox(height: 20.0),
      //         TextFormField(
      //           decoration: textInputDecoration.copyWith(hintText: 'password'),
      //           obscureText: true,
      //           validator: (val) => val.length < 6 ? 'Enter a password 6+ chars long' : null,
      //           onChanged: (val) {
      //             setState(() => password = val);
      //           },
      //         ),
      //         SizedBox(height: 20.0),
      //         RaisedButton(
      //             color: Colors.pink[400],
      //             child: Text(
      //               'Register',
      //               style: TextStyle(color: Colors.white),
      //             ),
      //             onPressed: () async {
      //               if(_formKey.currentState.validate()){
      //                 setState(() => loading = true);
      //                 dynamic result = await _auth.registerWithEmailAndPassword(email, password);
      //                 if(result == null) {
      //                   setState(() {
      //                     loading = false;
      //                     error = 'Please supply a valid email';
      //                   });
      //                 }
      //               }
      //             }
      //         ),
      //         SizedBox(height: 12.0),
      //         Text(
      //           error,
      //           style: TextStyle(color: Colors.red, fontSize: 14.0),
      //         )
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}