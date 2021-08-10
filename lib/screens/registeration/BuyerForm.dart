import 'dart:io';
import 'package:bidding_market/main.dart';
import 'package:bidding_market/models/buyerModel.dart';
import 'package:bidding_market/models/user.dart';
import 'package:bidding_market/screens/home/home.dart';
import 'package:bidding_market/screens/viewProfile.dart';
import 'package:bidding_market/services/database.dart';
import 'package:bidding_market/services/language_constants.dart';
import 'package:bidding_market/services/pincode_fetch.dart';
import 'package:bidding_market/shared/constants.dart';
import 'package:bidding_market/shared/loading.dart';
import 'package:bidding_market/shared/regFunctions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class buyerForm extends StatefulWidget {
  final User user;  // <--- generates the error, "Field doesn't override an inherited getter or setter"
  buyerForm({
    User user
  }): this.user = user;

  @override
  _buyerFormState createState() => _buyerFormState(user);
}

class _buyerFormState extends State<buyerForm> {
  final User user;
  _buyerFormState(this.user);

  final _formKey = GlobalKey<FormState>();

  User buyer = User();

  DatabaseService dbConnection = DatabaseService();
  PincodeFetch pincodeFetchObj = PincodeFetch();
  bool loading = false;

  File _AadharFront;

  File _AadharBack;

  final ImagePicker _picker = ImagePicker();

  Widget imageSourceSelector(BuildContext context, int imageNumber) {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 20.0,vertical: 20.0),
      child: Column (
        children: <Widget>[
          Text(toBeginningOfSentenceCase(getTranslated(context, "choose_photo_key")),
              style: TextStyle(fontSize: 20.0
      )),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton.icon(
                label: Text(toBeginningOfSentenceCase(getTranslated(context, "camera_key"))),
                  onPressed: () {
                    retreiveImage(ImageSource.camera, imageNumber);
              },
                  icon: Icon(Icons.camera_alt)
              ),
              FlatButton.icon(
                label: Text(toBeginningOfSentenceCase(getTranslated(context, "gallery_key"))),
                  onPressed: () {
    retreiveImage(ImageSource.gallery, imageNumber);}, icon: Icon(Icons.image)),
            ],
          )
        ],
      ),

    );
  }

  void retreiveImage(ImageSource source, int imageNumber) async {
      final pickedFile = await _picker.getImage(imageQuality: imageQuality,source: source);
      File _imageFile = File(pickedFile.path);
      Navigator.pop(context);
      setState(() {
        if(imageNumber == 1)
        {
          _AadharFront = _imageFile;
        }
        else if(imageNumber == 2)
        {
          _AadharBack = _imageFile;
        }
      });
}

  String _state, _district;
  List<String> _districtList = [];
  TextEditingController _stateController = new TextEditingController();


  @override
  // ignore: must_call_super
  void didChangeDependencies() async{
    //super.initState();
    if( user != null )
    {
      loading = true;
      await pincodeFetchObj.getPincodeDetails(user.Pincode).then((value) {
        loading = false;
        if(value[0] == 'Error')
        {
          setState(() {
            _stateController.text = "";
            if(_districtList.isNotEmpty) {
              _districtList.clear();
            }
            _district = null;
            _districtList = null;
            _districtList = [];
          });
          return toBeginningOfSentenceCase(getTranslated(context, "pincode_non_empty_key"));
        }
        else {
          setState(() {
            _stateController.text = "";
            _stateController.text = value[0];
            value.removeAt(0);
            if(_districtList.isNotEmpty) {
              _districtList.clear();
            }
            _district = null;
            _districtList = null;
            _districtList = [];
            _districtList.addAll(value);
            buyer.State = _stateController.text;
            print('Inside set state ${_stateController.text}');
            print('Inside set state $_districtList');
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userStream = Provider.of<User>(context);
    return loading ? Container( height: 700, child:Loading()) :Container(
      child: Form(
        key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 10.0),
              TextFormField(
                initialValue: (user != null) ? user.Name : buyer.Name,
                maxLength: 20,
                decoration: new InputDecoration(
                  labelText: toBeginningOfSentenceCase(getTranslated(context, "name_key")),
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
                validator: (val) {
                  if (val.length == 0) {
                    return toBeginningOfSentenceCase(getTranslated(context, "name_non_empty_key"));
                  } else {
                    return null;
                  }
                },
                onChanged: (String value) {
                  buyer.Name = camelCasingFields(value);
                },
                keyboardType: TextInputType.name,
                onSaved: (String value) {
                  buyer.Name = camelCasingFields(value);
                },
              ),
              SizedBox(height: 10.0),
              Text(
                toBeginningOfSentenceCase(getTranslated(context, "address_key")),
                style: TextStyle(
                  fontSize: 20.0,
                  fontFamily: "Georgia",
                ),
              ),
              SizedBox(height: 10.0),
              TextFormField(
                initialValue: (user != null) ? user.HouseNo : buyer.HouseNo,
                maxLength: 20,
                decoration: new InputDecoration(
                  labelText: toBeginningOfSentenceCase(getTranslated(context, "house_key")),
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
                validator: (val) {
                  if (val.length == 0) {
                    return toBeginningOfSentenceCase(getTranslated(context, "house_non_empty_key"));
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.text,
                onChanged: (val) {
                  buyer.HouseNo = val;
                },
                onSaved: (String value) {
                  buyer.HouseNo = value;
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                initialValue: (user != null) ? user.Village : buyer.Village,
                maxLength: 20,
                decoration: new InputDecoration(
                  labelText: getTranslated(context, "village_key"),
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
                validator: (val) {
                  if (val.length == 0) {
                    return toBeginningOfSentenceCase(getTranslated(context, "village_non_empty_key"));
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.text,
                onChanged: (val) {
                  buyer.Village = camelCasingFields(val);
                },
                onSaved: (String value) {
                  buyer.Village = camelCasingFields(value);
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                initialValue: (user != null) ? user.Pincode : buyer.Pincode,
                maxLength: 6,
                decoration: new InputDecoration(
                  labelText: toBeginningOfSentenceCase(getTranslated(context, "pincode_key")),
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
                validator: (val) {
                  if (val.length < 6) {
                    return toBeginningOfSentenceCase(getTranslated(context, "pincode_non_empty_key"));
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.number,
                onChanged: (val) async {
                  if(int.parse(val) >= 110000)
                  {
                    FocusScope.of(context).unfocus();
                    buyer.Pincode = val;
                    loading = true;
                    //toDo Call StateGet Function here
                    await pincodeFetchObj.getPincodeDetails(val).then((value) {
                      loading = false;
                      if(value[0] == 'Error')
                      {
                        setState(() {
                          _stateController.text = "";
                          if(_districtList.isNotEmpty) {
                            _districtList.clear();
                          }
                          _district = null;
                          _districtList = null;
                          _districtList = [];
                        });
                        return toBeginningOfSentenceCase(getTranslated(context, "pincode_non_empty_key"));
                      }
                      else {
                        setState(() {
                          _stateController.text = "";
                          _stateController.text = value[0];
                          value.removeAt(0);
                          if(_districtList.isNotEmpty) {
                            _districtList.clear();
                          }
                          _district = null;
                          _districtList = null;
                          _districtList = [];
                          _districtList.addAll(value);
                          buyer.State = _stateController.text;
                          print('Inside set state ${_stateController.text}');
                          print('Inside set state $_districtList');
                        });
                      }
                    });
                  }
                  else {
                    _district = null;
                    _stateController.text = "";
                    _districtList.clear();
                    return toBeginningOfSentenceCase(getTranslated(context, "pincode_non_empty_key"));
                  }
                },
                onSaved: (String value) {
                  buyer.Pincode = value;
                },
              ),
              SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                decoration: new InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: toBeginningOfSentenceCase(getTranslated(context, "district_key")),
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
                value: _district,
                items: _districtList.map((label) => DropdownMenuItem(
                  child: new Text(label),
                  value: label,
                ))
                    .toList(),
                hint: Text( (user != null) ? user.District : (_districtList.isEmpty) ? getTranslated(context, "no_district_key") : getTranslated(context, "select_district_key")),
                onChanged: (value) {
                  setState(() {
                    _district = value;
                    buyer.District = value;
                  });
                },
                validator: (val) {
                  if ( val == null ) {
                    return toBeginningOfSentenceCase(getTranslated(context, "district_non_empty_key"));
                  } else {
                    return null;
                  }
                },
                onSaved: (String value){
                  buyer.District = value;
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                //key: Key(_stateData.toString()),
                enabled: false,
                //readOnly: true,
                controller: _stateController,
                //initialValue: "",
                maxLength: 20,
                decoration: new InputDecoration(
                  //enabled: false,
                  labelText: getTranslated(context, "state_key"),
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
                //initialValue: (user != null) ? user.State : '',
                validator: (val) {
                  if (val.length == 0) {
                    return toBeginningOfSentenceCase(getTranslated(context, "state_non_empty_key"));
                  } else {
                    return null;
                  }
                },
                //keyboardType: TextInputType.text,
                //onChanged: (val) {},
                onSaved: (String value) {
                  buyer.State = _stateController.text;
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                initialValue: (user != null) ? user.AadharNo : buyer.AadharNo,
                maxLength: 12,
                decoration: new InputDecoration(
                  labelText: toBeginningOfSentenceCase(getTranslated(context, "aadhar_key")),
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
                validator: (val) {
                  if (val.length < 12) {
                    return toBeginningOfSentenceCase(getTranslated(context, "aadhar_non_empty_key"));
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  buyer.AadharNo = val;
                },
                onSaved: (String value) {
                  buyer.AadharNo = value;
                },
              ),
              // _AadharFront == null ?
              //     Image.file(_AadharFront) :
              //     SizedBox(height:10),
              RaisedButton(
                color: Colors.green[700],
                  child: Text(toBeginningOfSentenceCase(getTranslated(context, "aadhar_front_key"))),
                  onPressed: () {
                    showModalBottomSheet(context: context,
                        builder: ((builder) => imageSourceSelector(context, 1)));
                  }
              ),
              _AadharFront != null ? Container(height: 200, child: Image.file(_AadharFront)) : SizedBox(height: 5.0),
              RaisedButton(
                  color: Colors.green[700],
                  child: Text(toBeginningOfSentenceCase(getTranslated(context, "aadhar_back_key"))),
                  onPressed: () {
                    showModalBottomSheet(context: context,
                        builder: ((builder) => imageSourceSelector(context, 2)));
                  }
              ),
              _AadharBack != null ? Container(height: 200, child: Image.file(_AadharBack)) : SizedBox(height: 5.0),
              RaisedButton(
                onPressed: () async {

                  if(_formKey.currentState.validate())
                  {
                    setState(() => loading = true);
                    _formKey.currentState.save();
                    buyer.uid = userStream.uid;
                  if( user == null ) {
                    await dbConnection.addBuyerData(
                        buyer, _AadharFront, _AadharBack);
                    setState(() {
                      loading = false;
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => Home()
                      ));
                    });
                  }
                  else // UPDATION OF PROFILE
                      {
                        buyer.type = 1;
                    await dbConnection.updateUserData(user, buyer, _AadharFront); // CHANGE PROFILE PHOTO HERE
                    setState(() {
                      loading = false;
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => Profile(loggedUser)
                      ));
                    });
                  }
                    // Navigator.push(context, MaterialPageRoute(
                    //     builder: (context) => Home()
                    // ));
                  }
                },
                color: Colors.green[700],
                child: (user != null ) ? Text(getTranslated(context, "update_key").toUpperCase()) : Text(toBeginningOfSentenceCase(getTranslated(context, "register_key"))),
              ),
            ],
          )),
    );
  }
}
