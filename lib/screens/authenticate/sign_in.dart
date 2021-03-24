import 'package:bidding_market/screens/home/home.dart';
import 'package:bidding_market/services/auth.dart';
import 'package:bidding_market/services/database.dart';
import 'package:bidding_market/shared/constants.dart';
import 'package:bidding_market/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignIn extends StatefulWidget {

  final Function toggleView;
  SignIn({ this.toggleView });

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;
  DatabaseService dbConnection = DatabaseService();

  // text field state
  final _phoneController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0.0,
        title: Text('Sign In'),
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.person),
            label: Text('Register'),
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
                  Container(
                  height: 200.0,
                  width: 200.0,
                    alignment: Alignment.bottomRight,
                    child:Image.asset('assets/images/appLogo.png'),
                  ),
                  Text("Login", style: TextStyle(color: Colors.green[500], fontSize: 36, fontWeight: FontWeight.w500),),

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
                    child: Text("LOGIN"),
                    textColor: Colors.white,
                    padding: EdgeInsets.all(16),
                    onPressed: () async {
                      setState(() => loading = true);
                      final phone = _phoneController.text.trim();

                      await dbConnection.checkIfPhoneExists(phone); //Workaround needed to bypass home after user authentication
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
      )
    );
  }
}