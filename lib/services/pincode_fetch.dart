import 'package:http/http.dart';
import 'dart:convert';

class PincodeFetch {
  Future<List<String>> getPincodeDetails(String pincode) async {
    List<String> stateData = [];
    final url = Uri.parse('https://api.postalpincode.in/pincode/$pincode');
    Response response = await get(url);
    print('Status code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');
    List<dynamic> detail = jsonDecode(response.body);
    if (detail[0]['Status'] == 'Error') {
      stateData.add('Error');
    } else if (detail[0]['Status'] == 'Success'){
      Set<String> districtSet = {};
      Map<String, dynamic> postOfficeDetail =  detail[0]['PostOffice'][0];
      stateData.add(postOfficeDetail['State']);
      var length = (detail[0]['PostOffice'] as List<dynamic>).length;
      for(var i = 0; i< length; i++) {
        postOfficeDetail = detail[0]['PostOffice'][i];
        districtSet.add(postOfficeDetail['District']);
      }
      stateData.addAll(districtSet);
    }
    print(stateData);
    return stateData;
  }
}