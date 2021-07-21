import 'dart:io';
import 'package:bidding_market/main.dart';
import 'package:bidding_market/models/user.dart';
import 'package:bidding_market/screens/home/home.dart';
import 'package:bidding_market/screens/viewProfile.dart';
import 'package:bidding_market/services/language_constants.dart';
import 'package:bidding_market/services/pincode_fetch.dart';
import 'package:bidding_market/shared/constants.dart';
import 'package:bidding_market/shared/loading.dart';
import 'package:bidding_market/shared/regFunctions.dart';
import 'package:flutter/material.dart';
import 'package:bidding_market/services/database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class sellerForm extends StatefulWidget {
  final User user;  // <--- generates the error, "Field doesn't override an inherited getter or setter"
  sellerForm({
    User user
  }): this.user = user;

  @override
  _sellerFormState createState() => _sellerFormState(user);
}

class _sellerFormState extends State<sellerForm> {
  final User user;
  _sellerFormState(this.user);

  final _formKey = GlobalKey<FormState>();

  User seller = User();

  DatabaseService dbConnection = DatabaseService();
  PincodeFetch pincodeFetchObj = PincodeFetch();

  File _Photo;

  bool loading = false;

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
    final pickedFile = await _picker.getImage(imageQuality: 25,source: source, maxWidth: 250.0 , maxHeight: 200.0);
    File _imageFile = File(pickedFile.path);
    Navigator.pop(context);
    setState(() {
      if(imageNumber == 1)
      {
        _Photo = _imageFile;
      }
    });
  }
  String _state, _district;
  String _stateData = '';
  List<String> _districtList = [];
  TextEditingController _stateController = new TextEditingController();
  //_stateController.text = null;

  @override
  Widget build(BuildContext context) {
    final userStream = Provider.of<User>(context);

    //print("Keys are ${states.keys}");
    //if(_state!=null) print("Districts are ${states[_state]}");

    return loading ? Container( height: 700, child:Loading()) :Container(
      child: Form(
        key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 10.0),
              TextFormField(
                initialValue: (user != null) ? user.Name : seller.Name,
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
                keyboardType: TextInputType.name,
                onChanged: (String value) {
                  seller.Name = camelCasingFields(value);
                },
                onSaved: (String value) {
                  seller.Name = camelCasingFields(value);
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
                initialValue: (user != null) ? user.Village : seller.Village,
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
                  seller.Village = camelCasingFields(val);
                },
                onSaved: (String value) {
                  seller.Village = camelCasingFields(value);
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                initialValue: (user != null) ? user.Pincode : seller.Pincode,
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
                  if(int.parse(val) >= 100000)
                  {
                    FocusScope.of(context).unfocus();
                    seller.Pincode = val;
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
                          seller.State = camelCasingFields(_stateController.text);
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
                  seller.Pincode = value;
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
                hint: Text( (user != null) ? user.District : ''),
                onChanged: (value) {
                  setState(() {
                    _district = value;
                    seller.District = value;
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
                  seller.District = value;
                },
              ),
              // DropdownButtonFormField<String>(
              //   decoration: new InputDecoration(
              //     floatingLabelBehavior: FloatingLabelBehavior.always,
              //     labelText: toBeginningOfSentenceCase(getTranslated(context, "district_key")),
              //     fillColor: Colors.white,
              //     border: new OutlineInputBorder(
              //       borderRadius: new BorderRadius.circular(25.0),
              //       borderSide: new BorderSide(),
              //     ),
              //     //fillColor: Colors.green
              //   ),
              //   value: _district,
              //   items: (_districtList != null ) ? _districtList
              //       .map((label) => DropdownMenuItem(
              //     child: Text(label),
              //     value: label,
              //   ))
              //       .toList() : [],
              //   hint: Text( (user != null) ? user.District : ''),
              //   onChanged: (value) {
              //     setState(() {
              //       _district = value;
              //     });
              //   },
              //   validator: (val) {
              //     if ( val == null ) {
              //       return toBeginningOfSentenceCase(getTranslated(context, "district_non_empty_key"));
              //     } else {
              //       return null;
              //     }
              //   },
              //   onSaved: (String value){
              //     seller.District = value;
              //   },
              // ),
              // TextFormField(
              //   initialValue: (user != null) ? user.District : '',
              //   maxLength: 20,
              //   decoration: new InputDecoration(
              //     labelText: toBeginningOfSentenceCase(getTranslated(context, "district_key")),
              //     fillColor: Colors.white,
              //     border: new OutlineInputBorder(
              //       borderRadius: new BorderRadius.circular(25.0),
              //       borderSide: new BorderSide(),
              //     ),
              //     //fillColor: Colors.green
              //   ),
              //   validator: (val) {
              //     if (val.length == 0) {
              //       return toBeginningOfSentenceCase(getTranslated(context, "district_non_empty_key"));
              //     } else {
              //       return null;
              //     }
              //   },
              //   keyboardType: TextInputType.text,
              //   onChanged: (val) {},
              //   onSaved: (String value) {
              //     seller.District = value;
              //   },
              // ),
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
                  labelText: camelCasingFields(getTranslated(context, "state_key")),
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
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
                  seller.State = camelCasingFields(_stateData);
                },
              ),
              // DropdownButtonFormField<String>(
              //   decoration: new InputDecoration(
              //     floatingLabelBehavior: FloatingLabelBehavior.always,
              //     labelText: toBeginningOfSentenceCase(getTranslated(context, "state_key")),
              //     fillColor: Colors.white,
              //     border: new OutlineInputBorder(
              //       borderRadius: new BorderRadius.circular(25.0),
              //       borderSide: new BorderSide(),
              //     ),
              //     //fillColor: Colors.green
              //   ),
              //   value: _state,
              //   items: _state
              //       .map((label) => DropdownMenuItem(
              //     child: Text(label),
              //     value: label,
              //   ))
              //       .toList(),
              //   hint: Text( (user != null) ? user.State : ''),
              //   onChanged: (value) {
              //     setState(() {
              //       _state = value;
              //     });
              //   },
              //   validator: (val) {
              //     if ( val == null) {
              //       return toBeginningOfSentenceCase(getTranslated(context, "state_non_empty_key"));
              //     } else {
              //       return null;
              //     }
              //   },
              //   onSaved: (String value){
              //     seller.State = value;
              //   },
              // ),
              SizedBox(height: 10.0),
              // TextFormField(
              //   initialValue: (user != null) ? user.State : '',
              //   maxLength: 30,
              //   decoration: new InputDecoration(
              //     labelText: toBeginningOfSentenceCase(getTranslated(context, "state_key")),
              //     fillColor: Colors.white,
              //     border: new OutlineInputBorder(
              //       borderRadius: new BorderRadius.circular(25.0),
              //       borderSide: new BorderSide(),
              //     ),
              //     //fillColor: Colors.green
              //   ),
              //   validator: (val) {
              //     if (val.length == 0) {
              //       return toBeginningOfSentenceCase(getTranslated(context, "state_non_empty_key"));
              //     } else {
              //       return null;
              //     }
              //   },
              //   keyboardType: TextInputType.text,
              //   onChanged: (val) {},
              //   onSaved: (String value) {
              //     seller.State = value;
              //   },
              // ),
              //SizedBox(height: 10.0),
              RaisedButton(
                  color: Colors.green[700],
                  child: Text(toBeginningOfSentenceCase(getTranslated(context, "photo_key"))),
                  onPressed: () {
                    showModalBottomSheet(context: context,
                        builder: ((builder) => imageSourceSelector(context, 1)));
                  }
              ),
              _Photo != null ? Container(height: 200, child: Image.file(_Photo)) : SizedBox(height: 5.0),
              SizedBox(height: 10.0),
              // TextFormField(
              //   decoration: new InputDecoration(
              //     labelText: "Mobile Number",
              //     fillColor: Colors.white,
              //     border: new OutlineInputBorder(
              //       borderRadius: new BorderRadius.circular(25.0),
              //       borderSide: new BorderSide(),
              //     ),
              //     //fillColor: Colors.green
              //   ),
              //   validator: (val) {
              //     if (val.length < 10) {
              //       return "Mobile cannot be less than 10 digits";
              //     } else {
              //       return null;
              //     }
              //   },
              //   keyboardType: TextInputType.phone,
              //   onChanged: (val) {},
              // ),
              RaisedButton(
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    setState(() => loading = true);
                    _formKey.currentState.save();
                    seller.uid = userStream.uid;
                    if (user == null) {
                      await dbConnection.addSellerData(seller, _Photo);
                      setState(() {
                        loading = false;
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => Home()
                        ));
                      });
                    }

                    else // UPDATION OF PROFILE
                        {
                          seller.type = 2;

                      await dbConnection.updateUserData(user, seller, _Photo);
                      setState(() {
                        loading = false;
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => Profile(loggedUser)
                        ));
                      });
                    }
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
