import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:translator/translator.dart';
//import 'package:google_ml_kit/google_ml_kit.dart';

class LanguageServices {
  LanguageServices(this.locale);

  //final _languageModelManager = GoogleMlKit.nlp.translateLanguageModelManager();


  final Locale locale;
  static LanguageServices of(BuildContext context) {
    return Localizations.of<LanguageServices>(context, LanguageServices);
  }

  Map<String, String> _localizedValues;

  Future<void> load() async {

    // await _languageModelManager.downloadModel('en');
    // await _languageModelManager.downloadModel('hi');

    String jsonStringValues =
    await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
    Map<String, dynamic> mappedJson = json.decode(jsonStringValues);
    _localizedValues =
        mappedJson.map((key, value) => MapEntry(key, value.toString()));
  }

  String translate(String key) {
    return _localizedValues[key];
  }

  Future<String> translateOnline(String text, String languageCode) async {
    //print("Entered translateOnline locale.languagecode= ${locale.languageCode}");
    if((languageCode == "0" && locale.languageCode == "hi") || (languageCode == "hi" && locale.languageCode == "en"))
      {
        // final _onDeviceTranslator = GoogleMlKit.nlp.onDeviceTranslator(
        //     sourceLanguage: TranslateLanguage.ENGLISH,
        //     targetLanguage: TranslateLanguage.HINDI);
        // var result = await _onDeviceTranslator.translateText(text);
        //print("entered hindi with ${text}");
        GoogleTranslator translator = new GoogleTranslator();
        var result = await translator.translate(text,from: 'en', to: 'hi');
        print('${text} -> ${result.text}');
        //     result = value.toString();
        // });
        return result.text;
        //return translator.translate(text, from: 'en', to: 'hi');
      }
    else
      {
        return text;
      }
  }

  // static member to have simple access to the delegate from Material App
  static const LocalizationsDelegate<LanguageServices> delegate =
  _LanguageServicessDelegate();
}

class _LanguageServicessDelegate
    extends LocalizationsDelegate<LanguageServices> {
  const _LanguageServicessDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<LanguageServices> load(Locale locale) async {
    LanguageServices localization = new LanguageServices(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(LocalizationsDelegate<LanguageServices> old) => false;
}