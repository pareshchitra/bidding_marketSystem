import 'dart:io';
import 'package:bidding_market/models/buyerModel.dart';
import 'package:bidding_market/screens/authenticate/phone_auth.dart';
import 'package:bidding_market/screens/authenticate/sign_in.dart';
import 'package:bidding_market/services/database.dart';
import 'package:bidding_market/shared/sharedPrefs.dart';
import 'package:bidding_market/services/language_constants.dart';
import 'package:bidding_market/services/language_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:bidding_market/screens/wrapper.dart';
import 'package:bidding_market/services/auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:bidding_market/models/user.dart';

User loggedUser = User(type:0, PhoneNo: "NA");
String selectedLanguage = "en";

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SharedPrefs().init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  const MyApp({Key key}) : super(key: key);
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(newLocale);
  }

  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale;
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
        selectedLanguage = locale.languageCode;
      });
    });
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {

    // final provider = Provider.of<PhoneAuthDataProvider>(context , listen:false );
    // return ChangeNotifierProvider<PhoneAuthDataProvider>.value(
    //   value: provider,
    //   child: MaterialApp(debugShowCheckedModeBanner: false,
    //     home: Wrapper(),
    //   ),
    // );
    if (this._locale == null) {
      return Container(color: Colors.white,
        child: Center(
          child: CircularProgressIndicator(
              //backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green[400])),
        ),
      );
    } else {
      return MultiProvider(
        providers: [

        ChangeNotifierProvider(
          create: (context) => PhoneAuthDataProvider(),
        ),

        StreamProvider<User>.value(
          value: PhoneAuthDataProvider().user,
        )
      ],

        child: MaterialApp(
          home: Wrapper(),
          debugShowCheckedModeBanner: false,
          locale: _locale,
          supportedLocales: [
            Locale("en", "US"),
            Locale("hi", "IN")
          ],
          localizationsDelegates: [
            LanguageServices.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode &&
                  supportedLocale.countryCode == locale.countryCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
        ),
      );
    }
  }
}


