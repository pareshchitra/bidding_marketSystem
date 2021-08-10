import 'package:bidding_market/main.dart';
import 'package:bidding_market/models/language.dart';
import 'package:bidding_market/screens/home/home.dart';
import 'package:bidding_market/services/language_constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bidding_market/shared/nav-drawer.dart';
import 'package:bidding_market/services/auth.dart';
import 'package:bidding_market/screens/authenticate/authenticate.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  final AuthService _auth = AuthService();

  void _changeLanguage(Language language) async {
    selectedLanguage = language.languageCode;
    Locale _locale = await setLocale(language.languageCode);
    MyApp.setLocale(context, _locale);
    //_getTranslatedString(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavDrawer(),
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(toBeginningOfSentenceCase(getTranslated(context, "settings_key"))),
          backgroundColor: Colors.green[700],
          elevation: 0.0,
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.person),
              label: Text(getTranslated(context, "logout_key")),
              onPressed: () async {
                //Navigator.of(context).pop();
                await _auth.signOut();
                Navigator.of(context)
                    .pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => Authenticate() ), (Route<dynamic> route) => false
                );
                //PhoneAuthDataProvider().signOut();
              },
            ),
          ],
        ),
        body: Column(

      children: [
          SizedBox(height: 40.0),
        Container(
            alignment: Alignment.center,
            child: Column(
                children: <Widget>[
                  DropdownButton<Language>(
                    underline: SizedBox(),
                    iconEnabledColor: Colors.green,
                    hint: Text(getTranslated(context, 'language_key'),
                        style: TextStyle(color: Colors.green, fontSize: 20)),
                    onChanged: (Language language) {
                      _changeLanguage(language);
                      // Navigator.of(context).pop();
                      // Navigator.push(context, MaterialPageRoute(
                      //     builder: (context) => Home()));
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
        ),
      ]
      )
    );
  }
  }





