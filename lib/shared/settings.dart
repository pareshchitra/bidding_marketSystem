import 'package:bidding_market/main.dart';
import 'package:bidding_market/models/language.dart';
import 'package:bidding_market/screens/home/home.dart';
import 'package:bidding_market/services/language_constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  void _changeLanguage(Language language) async {
    selectedLanguage = language.languageCode;
    Locale _locale = await setLocale(language.languageCode);
    MyApp.setLocale(context, _locale);
    //_getTranslatedString(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: 40.0,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.white,
        title: Text(
          toBeginningOfSentenceCase(getTranslated(context, "settings_key")),
          style: TextStyle(
            color: Colors.black,
          ),
        ),
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





