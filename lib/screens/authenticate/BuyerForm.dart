import 'dart:io';
import 'package:bidding_market/models/buyerModel.dart';
import 'package:bidding_market/services/database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class buyerForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  BuyerModel buyerModel = BuyerModel();
  DatabaseService dbConnection = DatabaseService();
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
          Text("Choose Photo Source",
              style: TextStyle(fontSize: 20.0
      )),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton.icon(
                label: Text("Camera"),
                  onPressed: () {
                    retreiveImage(ImageSource.camera, imageNumber);
              },
                  icon: Icon(Icons.camera_alt)
              ),
              FlatButton.icon(
                label: Text("Gallery"),
                  onPressed: () {
    retreiveImage(ImageSource.gallery, imageNumber);}, icon: Icon(Icons.image)),
            ],
          )
        ],
      ),

    );
  }

  void retreiveImage(ImageSource source, int imageNumber) async {
 final pickedFile = await _picker.getImage(imageQuality: 75,source: source);
 File _imageFile = File(pickedFile.path);
 if(imageNumber == 1)
   {
     _AadharFront = _imageFile;
   }
 else if(imageNumber == 2)
   {
     _AadharBack = _imageFile;
   }
}

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
        key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 10.0),
              TextFormField(
                maxLength: 20,
                decoration: new InputDecoration(
                  labelText: "Name",
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
                validator: (val) {
                  if (val.length == 0) {
                    return "Name cannot be empty";
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.name,
                onSaved: (String value) {
                  buyerModel.Name = value;
                },
              ),
              SizedBox(height: 10.0),
              Text(
                'Address',
                style: TextStyle(
                  fontSize: 15.0,
                  fontFamily: "Georgia",
                ),
              ),
              SizedBox(height: 10.0),
              TextFormField(
                maxLength: 20,
                decoration: new InputDecoration(
                  labelText: "House Number",
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
                validator: (val) {
                  if (val.length == 0) {
                    return "House Number cannot be empty";
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.text,
                onChanged: (val) {},
                onSaved: (String value) {
                  buyerModel.HouseNo = value;
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                maxLength: 20,
                decoration: new InputDecoration(
                  labelText: "Village/City",
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
                validator: (val) {
                  if (val.length == 0) {
                    return "Village or city cannot be empty";
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.text,
                onChanged: (val) {},
                onSaved: (String value) {
                  buyerModel.Village = value;
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                maxLength: 20,
                decoration: new InputDecoration(
                  labelText: "District",
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
                validator: (val) {
                  if (val.length == 0) {
                    return "District cannot be empty";
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.text,
                onChanged: (val) {},
                onSaved: (String value) {
                  buyerModel.District = value;
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                maxLength: 6,
                decoration: new InputDecoration(
                  labelText: "Pincode",
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
                validator: (val) {
                  if (val.length < 6) {
                    return "Pincode cannot be less than 6 digits";
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.number,
                onChanged: (val) {},
                onSaved: (String value) {
                  buyerModel.Pincode = value;
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                maxLength: 12,
                decoration: new InputDecoration(
                  labelText: "Aadhar Number",
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
                validator: (val) {
                  if (val.length < 12) {
                    return "Aadhaar cannot be less than 12 digits";
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.number,
                onChanged: (val) {},
                onSaved: (String value) {
                  buyerModel.AadharNo = value;
                },
              ),
              // _AadharFront == null ?
              //     Image.file(_AadharFront) :
              //     SizedBox(height:10),
              RaisedButton(
                color: Colors.green[700],
                  child: Text('Aadhar Front'),
                  onPressed: () {
                    showModalBottomSheet(context: context,
                        builder: ((builder) => imageSourceSelector(context, 1)));
                  }
              ),
              RaisedButton(
                  color: Colors.green[700],
                  child: Text('Aadhar Back'),
                  onPressed: () {
                    showModalBottomSheet(context: context,
                        builder: ((builder) => imageSourceSelector(context, 2)));
                  }
              ),
              RaisedButton(
                onPressed: () async {
                  if(_formKey.currentState.validate())
                  {
                    _formKey.currentState.save();
                    buyerModel.uid = "1";
                    await dbConnection.updateBuyerData(buyerModel, _AadharFront, _AadharBack);
                  }
                },
                color: Colors.green[700],
                child: Text('Register'),
              ),
            ],
          )),
    );
  }
}
