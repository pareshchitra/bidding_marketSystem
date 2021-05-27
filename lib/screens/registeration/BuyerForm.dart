import 'dart:io';
import 'package:bidding_market/main.dart';
import 'package:bidding_market/models/buyerModel.dart';
import 'package:bidding_market/models/user.dart';
import 'package:bidding_market/screens/home/home.dart';
import 'package:bidding_market/screens/viewProfile.dart';
import 'package:bidding_market/services/database.dart';
import 'package:bidding_market/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
      final pickedFile = await _picker.getImage(imageQuality: 25,source: source, maxWidth: 250.0 , maxHeight: 200.0);
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
                initialValue: (user != null) ? user.Name : '',
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
                  buyer.Name = value;
                },
              ),
              SizedBox(height: 10.0),
              Text(
                'Address',
                style: TextStyle(
                  fontSize: 20.0,
                  fontFamily: "Georgia",
                ),
              ),
              SizedBox(height: 10.0),
              TextFormField(
                initialValue: (user != null) ? buyer.HouseNo : '',
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
                  buyer.HouseNo = value;
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                initialValue: (user != null) ? user.Village : '',
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
                  buyer.Village = value;
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                initialValue: (user != null) ? user.District : '',
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
                  buyer.District = value;
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                initialValue: (user != null) ? user.State : '',
                maxLength: 30,
                decoration: new InputDecoration(
                  labelText: "State",
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
                validator: (val) {
                  if (val.length == 0) {
                    return "State cannot be empty";
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.text,
                onChanged: (val) {},
                onSaved: (String value) {
                  buyer.State = value;
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                initialValue: (user != null) ? user.Pincode : '',
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
                  buyer.Pincode = value;
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                initialValue: (user != null) ? user.AadharNo : '',
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
                  buyer.AadharNo = value;
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
              _AadharFront != null ? Container(height: 200, child: Image.file(_AadharFront)) : SizedBox(height: 5.0),
              RaisedButton(
                  color: Colors.green[700],
                  child: Text('Aadhar Back'),
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
                child: (user != null ) ? Text('UPDATE') : Text('Register'),
              ),
            ],
          )),
    );
  }
}
