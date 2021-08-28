
String camelCasingFields(String value)
{
  value = value.trim();
  String correctedString;
  if( value.length < 1) {
    correctedString = value[0].toUpperCase();
    return correctedString;
  }
  else if(!value.contains(" ")){
    correctedString = value[0].toUpperCase() + value.substring(1).toLowerCase();
    return correctedString;
  }
  else{
    int spaceIndex = value.indexOf(" ");
    correctedString = value[0].toUpperCase() + value.substring(1,spaceIndex).toLowerCase()
        + " " + value[spaceIndex+1].toUpperCase() ;
    if (value.length > spaceIndex+1) {
      correctedString = correctedString + value.substring(spaceIndex+2).toLowerCase();
    }
    return correctedString;
  }
}

String prettifyDouble(double realNo) =>
  realNo.toStringAsFixed(1).replaceFirst(RegExp(r'\.?0*$'), '');