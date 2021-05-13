import 'dart:io';
import 'package:bidding_market/main.dart';
import 'package:bidding_market/models/user.dart';
import 'package:bidding_market/screens/home/home.dart';
import 'package:bidding_market/screens/viewProfile.dart';
import 'package:bidding_market/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:bidding_market/services/database.dart';
import 'package:image_picker/image_picker.dart';
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
    final pickedFile = await _picker.getImage(imageQuality: 5,source: source, maxWidth: 10.0 , maxHeight: 10.0);
    File _imageFile = File(pickedFile.path);
    Navigator.pop(context);
    setState(() {
      if(imageNumber == 1)
      {
        _Photo = _imageFile;
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
                onChanged: (String value) {},
                onSaved: (String value) {
                  seller.Name = value;
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
                  seller.Village = value;
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
                  seller.District = value;
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
                  seller.State = value;
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
                  seller.Pincode = value;
                },
              ),
              SizedBox(height: 10.0),
              RaisedButton(
                  color: Colors.green[700],
                  child: Text('Photo'),
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
                child: (user != null ) ? Text('UPDATE') : Text('Register'),
              ),
            ],
          )),
    );
  }
}
