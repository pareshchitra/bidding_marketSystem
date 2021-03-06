import 'package:bidding_market/models/user.dart';
import 'package:flutter/material.dart';
import 'package:bidding_market/services/database.dart';

class sellerForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  User seller = User();
  DatabaseService dbConnection = DatabaseService();

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
                onChanged: (String value) {},
                onSaved: (String value) {
                  seller.Name = value;
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
                  seller.HouseNo = value;
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
                  seller.Village = value;
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
                  seller.District = value;
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
                  seller.Pincode = value;
                },
              ),
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
                onPressed: () {
                  if(_formKey.currentState.validate())
                    {
                      _formKey.currentState.save();
                      seller.uid = "1";
                      dbConnection.updateSellerData(seller);
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
