import 'package:bidding_market/main.dart';
import 'package:bidding_market/screens/authenticate/phone_auth.dart';
import 'package:bidding_market/screens/authenticate/verify.dart';
import 'package:bidding_market/screens/home/home.dart';
import 'package:bidding_market/services/auth.dart';
import 'package:bidding_market/services/database.dart';
import 'package:bidding_market/shared/constants.dart';
import 'package:bidding_market/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
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


  @override
  Widget build(BuildContext context) {
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
                              text: 'We will send ',
                              style: TextStyle(
                                  color: Colors.green, fontWeight: FontWeight.w400)),
                          TextSpan(
                              text: 'One Time Password',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w700)),
                          TextSpan(
                              text: ' to this mobile number',
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
                    child: Text("LOGIN"),
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
      _showSnackBar("Oops! Number seems invaild");
      return;
    }
  }
}
