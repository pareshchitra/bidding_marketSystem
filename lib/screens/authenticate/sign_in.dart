import 'dart:io';

import 'package:bidding_market/main.dart';
import 'package:bidding_market/models/language.dart';
import 'package:bidding_market/screens/admin/adminLogin.dart';
import 'package:bidding_market/screens/authenticate/phone_auth.dart';
import 'package:bidding_market/screens/authenticate/verify.dart';
import 'package:bidding_market/screens/home/home.dart';
import 'package:bidding_market/services/auth.dart';
import 'package:bidding_market/services/database.dart';
import 'package:bidding_market/services/language_constants.dart';
import 'package:bidding_market/shared/constants.dart';
import 'package:bidding_market/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

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

  final scaffoldKey = GlobalKey<ScaffoldState>(
      debugLabel: "scaffold-get-phone");

  // text field state
  final _phoneController = TextEditingController();

  void _changeLanguage(Language language) async {
    selectedLanguage = language.languageCode;
    Locale _locale = await setLocale(language.languageCode);
    MyApp.setLocale(context, _locale);
    //_getTranslatedString(0);
  }


  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;

    return loading ? Loading() : Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0.0,
        title: Center(child: Text('Farmway', textAlign: TextAlign.center)),
        // actions: <Widget>[
        //   FlatButton.icon(
        //     icon: Icon(Icons.person),
        //     label: Text('Register'),
        //     onPressed: () => widget.toggleView(),
        //   ),
        // ],
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
                  width: 600.0,
                    alignment: Alignment.center,
                    child:Image.asset(
                        'assets/images/appLogo.jpg',
                         scale: 0.6
                         ),
                  ),
                  Text(getTranslated(context, 'login_key'), style: TextStyle(color: Colors.green[500], fontSize: 36, fontWeight: FontWeight.w500),),

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
                      hintText: getTranslated(context, 'mobile_number_key'),

                  ),
                    keyboardType: TextInputType.number,
                  controller:     Provider
                      .of<PhoneAuthDataProvider>(context, listen: false)
                      .phoneNumberController ,//_phoneController,  //OTP CHANGE HERE
                ),

                SizedBox(height: 16,),


              /*
           *  Some informative text
           */
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(width: 10),
                  Icon(Icons.info, color: Colors.green, size: 20.0),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: getTranslated(context, 'OTP_send_key_1') + " ",
                              style: TextStyle(
                                  color: Colors.green, fontWeight: FontWeight.w400)),
                          TextSpan(
                              text: getTranslated(context, 'OTP_send_key_2'),
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w700)),
                          TextSpan(
                              text: " " + getTranslated(context, 'OTP_send_key_3'),
                              style: TextStyle(
                                  color: Colors.green, fontWeight: FontWeight.w400)),
                        ])),
                  ),
                  SizedBox(width: 10 ,height : 20),
            ],
              ),


                  SizedBox(height : 30),
                  Container(
                  width: double.infinity,
                  child: FlatButton(
                    child: Text(getTranslated(context, 'login_key').toUpperCase()),
                    textColor: Colors.white,
                    padding: EdgeInsets.all(16),
                    onPressed: () async {
                      // setState(() => loading = true);
                      // final phone = "+91"+ _phoneController.text.trim();
                      // //await dbConnection.deletePhoneData(phone);
                      // await dbConnection.checkIfPhoneExists(phone); //Workaround needed to bypass home after user authentication
                      // dynamic result = await _auth.signInWithMobileNumber(phone , context);
                      // if(result == null) {
                      //   print("Result received null from signIn function");
                      //   setState(() {
                      //     loading = false;
                      //     error = 'Could not sign in with those credentials';
                      //   });
                      // }
                      startPhoneAuth();//OTP CHANGE HERE
                    },
                    color: Colors.green[400],
                  ),
                ),
                  SizedBox(height: 50.0),
                Container(
                    height : 4.0,
                    width : _screenWidth * 0.8,
                    color: Colors.green
                ),
                  SizedBox(height: 20.0),
                Center(
                  child: FlatButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdminLoginPage())),
                      icon: (Icon(Icons.nature_people, color : Colors.green)),
                      label: Text(toBeginningOfSentenceCase(getTranslated(context, "admin_info_key")) , style: TextStyle(color: Colors.green , fontSize: 20.0, fontWeight: FontWeight.bold),)
                  ),
                ),

                SizedBox(height: 12.0),
                Text(
                  error,
                  style: TextStyle(color: Colors.red, fontSize: 14.0),
                ),
                  SizedBox(height: 40.0),
                  Container(
                      alignment: Alignment.center,
                      child: Column(
                          children: <Widget>[
                  DropdownButton<Language>(
                    underline: SizedBox(),
                    iconEnabledColor: Colors.green,
                    // icon: Icon(
                    //   Icons.language,
                    //   color: Colors.green,size: 40,
                    // ),
                    hint: Text(getTranslated(context, 'language_key'),
                    style: TextStyle(color: Colors.green, fontSize: 20)),
                    onChanged: (Language language) {
                      _changeLanguage(language);
                    },
                    items: Language.languageList()
                        .map<DropdownMenuItem<Language>>(
                          (e) => DropdownMenuItem<Language>(
                        value: e,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Text(e.name)
                          ],
                        ),
                      ),
                    ).toList(),
                  ),
              ]
                  )
                  )
              ],
            ),
          ),
        ),
      )
    );

  }

  _showSnackBar(String text) {
    final snackBar = SnackBar(
      content: Text('$text'),
    );
//    if (mounted) Scaffold.of(context).showSnackBar(snackBar);
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  startPhoneAuth() async {
    //setState(() => loading = true);
    final phone = "+91"+ _phoneController.text.trim();
    //await dbConnection.checkIfPhoneExists(phone);


    final phoneAuthDataProvider =
    Provider.of<PhoneAuthDataProvider>(context, listen: false);
    phoneAuthDataProvider.loading = true;
    //var countryProvider = Provider.of<CountryProvider>(context, listen: false);
    bool validPhone = await phoneAuthDataProvider.instantiate(
        dialCode: "+91",//countryProvider.selectedCountry.dialCode,
        onCodeSent: () {
          Navigator.of(context).pushReplacement(CupertinoPageRoute(
              builder: (BuildContext context) => PhoneAuthVerify()));
        },
        onVerified: (FirebaseAuth.User user, String phone) async{
          loggedUser.uid = user.uid;
          await dbConnection.updatePhoneData(phone, user.uid, 1);
        },
        onFailed: () {
          _showSnackBar(phoneAuthDataProvider.message);
        },
        onError: () {
          _showSnackBar(phoneAuthDataProvider.message);
        });
    if (!validPhone) {
      phoneAuthDataProvider.loading = false;
      _showSnackBar(getTranslated(context, "number_invalid_key"));
      return;
    }
  }
}
