import 'package:bidding_market/main.dart';
import 'package:bidding_market/screens/authenticate/sign_in.dart';
import 'package:bidding_market/screens/home/home.dart';
import 'package:bidding_market/services/language_constants.dart';
import 'package:bidding_market/shared/loading.dart';
import 'package:bidding_market/shared/sharedPrefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';



class AdminLoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: new BoxDecoration(
              gradient: new LinearGradient(
                colors : [Colors.pink, Colors.lightGreenAccent],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp
              )
            ),
          ),
        //backgroundColor: Colors.green[700],
        elevation: 0.0,
        title: Center(child: Text(toBeginningOfSentenceCase(getTranslated(context, "admin_login_key")), textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Signatra'),)),
        ),
      body: AdminLoginScreen(),
    );
  }
}

class AdminLoginScreen extends StatefulWidget {
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final formKey = new GlobalKey<FormState>();
  final _adminIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;

    label(String title) => Text(title);

    InputDecoration buildInputDecoration(String hintText, IconData icon) {
      return InputDecoration(
        prefixIcon: Icon(icon, color: Color.fromRGBO(50, 62, 72, 1.0)),
        // hintText: hintText,
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
      );
    }

    var appLogo = Container(
      alignment: Alignment.bottomCenter,
      child: Image.asset(
        "assets/images/appLogo.jpg",
          scale: 0.8,
      ),
    );

    final adminIdField = TextFormField(
      autofocus: false,
      validator: (value) => value.isEmpty ? toBeginningOfSentenceCase(getTranslated(context, "enter_id_key")) : null,
      controller: _adminIdController,
      decoration: buildInputDecoration(toBeginningOfSentenceCase(getTranslated(context, "confirm_password_key")), Icons.person),
    );

    final passwordField = TextFormField(
      autofocus: false,
      obscureText: true,
      validator: (value) => value.isEmpty ? toBeginningOfSentenceCase(getTranslated(context, "enter_password_key")) : null,
      controller: _passwordController,
      decoration: buildInputDecoration(toBeginningOfSentenceCase(getTranslated(context, "confirm_password_key")), Icons.lock_outline),
    );

    var loading = Center(child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
        Text(toBeginningOfSentenceCase(getTranslated(context, "auth_wait_key")) + "...")
      ],
    ));

    var adminLabel = Center( child: Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
          toBeginningOfSentenceCase(getTranslated(context, "admin_key")),
          style:  TextStyle(color : Colors.deepOrange, fontSize: 28.0, fontWeight: FontWeight.bold)
      ),
    ));

    var loginButton = Center(child :RaisedButton(
        onPressed: () {
          final form = formKey.currentState;

          if (form.validate()) {
            form.save();
            loginAdmin();
          }
          else {
            print("form is invalid");
          }
        },

        color : Colors.green,
        child : Text(toBeginningOfSentenceCase(getTranslated(context, "login_key")) , style: TextStyle(color: Colors.white))
    ));

    var horizontalLine = Container(
      height : 4.0,
      width : _screenWidth * 0.8,
      color: Colors.green
    );

    var nonAdminLoginButton = Center( child: FlatButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignIn())),
        icon: (Icon(Icons.nature_people, color : Colors.green)),
        label: Text(toBeginningOfSentenceCase(getTranslated(context, "not_admin_info_key")) , style: TextStyle(color: Colors.green , fontSize: 20.0, fontWeight: FontWeight.bold),)
    ));

    return (isLoading == true) ? loading : SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(40.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50.0),
              appLogo,
              SizedBox(height: 80.0),
              adminLabel,
              SizedBox(height: 30.0),
              label(toBeginningOfSentenceCase(getTranslated(context, "admin_id_key"))),
              SizedBox(height: 5.0),
              adminIdField,
              SizedBox(height: 20.0),
              label(toBeginningOfSentenceCase(getTranslated(context, "password_key"))),
              SizedBox(height: 5.0),
              passwordField,
              SizedBox(height: 20.0),
              loginButton,
              SizedBox(height: 25.0),
              horizontalLine,
              SizedBox(height: 20),
              nonAdminLoginButton

            ],
          ),
        ),
      ),
    );

  }

  loginAdmin()
  {
    setState(() {
      isLoading = true;
    });


    bool isIdCorrect = false , isPwdCorrect = false;
    FirebaseFirestore.instance.collection("admins").get().then((snapshot){
      snapshot.docs.forEach((result) {
        if(result.data()['id'] == _adminIdController.text.trim())
        {
          isIdCorrect = true;
          if(result.data()["password"] == _passwordController.text.trim())
          {
            isPwdCorrect = true;
            Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(toBeginningOfSentenceCase(getTranslated(context, "welcome_admin_key")) + ", " + result.data()["name"])));

            SharedPrefs().adminId = result.data()['id'];
            loggedUser.Name = result.data()['name'];
            loggedUser.type = 3; // FOR ADMIN
            Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => Home()
            ));
            setState(() {
              isLoading = false;
              _adminIdController.text = "";
              _passwordController.text = "";
            });
          }
          //Scaffold.of(context).showSnackBar(SnackBar(content : Text("Id Incorrect") ));
        }
      });
      if( isIdCorrect == false)
        Scaffold.of(context).showSnackBar(SnackBar(content : Text(getTranslated(context, "id_incorrect_key")) ));
      else if( isPwdCorrect == false)
        Scaffold.of(context).showSnackBar(SnackBar(content : Text(getTranslated(context, "password_incorrect_key")) ));
      setState(() {
        isLoading = false;
      });
    });

  }

}