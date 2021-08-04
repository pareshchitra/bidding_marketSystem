import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  contentPadding: EdgeInsets.all(12.0),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.pink, width: 2.0),
  ),
);

var currencyFormat = NumberFormat.currency(locale: 'gu', symbol: '\u{20B9}');

const int imageQuality = 75;

 const Map<String, List<String>> states = {
    'Rajasthan': ['Sawai Madhopur', 'Dausa']
 };

