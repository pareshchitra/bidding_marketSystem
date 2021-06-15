import 'package:bidding_market/screens/authenticate/sign_in.dart';
import 'package:bidding_market/screens/home/home.dart';
import 'package:bidding_market/shared/loading.dart';
import 'package:bidding_market/shared/sharedPrefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';



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
        title: Center(child: Text('Admin Login', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Signatra'),)),
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
      validator: (value) => value.isEmpty ? "Please enter your id" : null,
      controller: _adminIdController,
      decoration: buildInputDecoration("Confirm password", Icons.person),
    );

    final passwordField = TextFormField(
      autofocus: false,
      obscureText: true,
      validator: (value) => value.isEmpty ? "Please enter password" : null,
      controller: _passwordController,
      decoration: buildInputDecoration("Confirm password", Icons.lock_outline),
    );

    var loading = Center(child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
        Text(" Authenticating ... Please wait")
      ],
    ));

    var adminLabel = Center( child: Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
          "Admin",
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
        child : Text("Login" , style: TextStyle(color: Colors.white))
    ));

    var horizontalLine = Container(
      height : 4.0,
      width : _screenWidth * 0.8,
      color: Colors.green
    );

    var nonAdminLoginButton = Center( child: FlatButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignIn())),
        icon: (Icon(Icons.nature_people, color : Colors.green)),
        label: Text("I'm Not an Admin" , style: TextStyle(color: Colors.green , fontSize: 20.0, fontWeight: FontWeight.bold),)
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
              label("Admin ID"),
              SizedBox(height: 5.0),
              adminIdField,
              SizedBox(height: 20.0),
              label("Password"),
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
                content: Text("Welcome Dear Admin, " + result.data()["name"])));

            SharedPrefs().adminId = result.data()['id'];
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
        Scaffold.of(context).showSnackBar(SnackBar(content : Text("Id Incorrect") ));
      else if( isPwdCorrect == false)
        Scaffold.of(context).showSnackBar(SnackBar(content : Text("Password Incorrect") ));
      setState(() {
        isLoading = false;
      });
    });

  }

}