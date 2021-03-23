import 'dart:io';
import 'package:bidding_market/main.dart';
import 'package:bidding_market/models/buyerModel.dart';
import 'package:bidding_market/models/products.dart';
import 'package:bidding_market/screens/home/home.dart';
import 'package:bidding_market/services/database.dart';
import 'package:bidding_market/models/user.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';


class UploadImagesFields extends StatefulWidget {
  final int index;
  UploadImagesFields(this.index);
  @override
  _UploadImagesFieldsState createState() => _UploadImagesFieldsState();
}
class _UploadImagesFieldsState extends State<UploadImagesFields> {
  TextEditingController _nameController;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    _ProductRegisterFormState p = new _ProductRegisterFormState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _nameController.text = _ProductRegisterFormState.imagesList[widget.index]
          ?? '';
    });
    print("Widget Index for imageSource is");
    print(widget.index);
    return RaisedButton(
        color: Colors.green[700],
        child: Text('Upload Image'),
        onPressed: () {
          showModalBottomSheet(context: context,
              builder: ((builder) => p.imageSourceSelector(context, widget.index+1)));
        }
    );
  }
}


class ProductRegisterForm extends StatefulWidget {


  @override
  _ProductRegisterFormState createState() => _ProductRegisterFormState();
}

class _ProductRegisterFormState extends State<ProductRegisterForm> {
  final _formKey = GlobalKey<FormState>();

  Product product = Product();

  DatabaseService dbConnection = DatabaseService();

  File productPhoto1 , productPhoto2;

  final ImagePicker _picker = ImagePicker();
  static List<String> imagesList = [null];

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
    final pickedFile = await _picker.getImage(imageQuality: 25,source: source);
    File _imageFile = File(pickedFile.path);
    if(imageNumber == 1)
    {
      productPhoto1 = _imageFile;
    }
    else if(imageNumber == 2)
    {
      productPhoto2 = _imageFile;
    }
  }

  List<Widget> _getImages(){
    List<Widget> uploadImagesFieldsList = [];
    for(int i=0; i<imagesList.length; i++){
      uploadImagesFieldsList.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UploadImagesFields(i),
                SizedBox(width: 16,),
                // we need add button at last friends row only
                _addRemoveButton(i == imagesList.length-1, i),
              ],
            ),
          )
      );
    }
    return uploadImagesFieldsList;
  }

  Widget _addRemoveButton(bool add, int index){
    return InkWell(
      onTap: (){
        if(add){
          // add new text-fields at the top of all friends textfields
          imagesList.insert(0, null);
        }
        else imagesList.removeAt(index);
        setState((){});
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: (add) ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          (add) ? Icons.add : Icons.remove, color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return  Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0.0,
        title: Text('Add Your Product'),
        ),

        body:  SingleChildScrollView(
           scrollDirection: Axis.vertical,
           child:Container(
           child: Form(
            key: _formKey,
            child: Column(
              children:[
                SizedBox(height: 2.0),
                TextFormField(
                  maxLength: 20,
                  decoration: new InputDecoration(
                    labelText: "Category",
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: new BorderSide(),
                    ),
                    //fillColor: Colors.green
                  ),
                  validator: (val) {
                    if (val.length == 0) {
                      return "Category cannot be empty";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.name,
                  onSaved: (String value) {
                    product.category = value;
                  },
                ),

                SizedBox(height: 2.0),
                TextFormField(
                  maxLength: 20,
                  decoration: new InputDecoration(
                    labelText: "Location",
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: new BorderSide(),
                    ),
                    //fillColor: Colors.green
                  ),
                  validator: (val) {
                    if (val.length == 0) {
                      return "Location cannot be empty";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.text,
                  onChanged: (val) {},
                  onSaved: (String value) {
                    product.location = value;
                  },
                ),
                SizedBox(height: 2.0),
                TextFormField(
                  maxLength: 20,
                  decoration: new InputDecoration(
                    labelText: "Owner",
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: new BorderSide(),
                    ),
                    //fillColor: Colors.green
                  ),
                  validator: (val) {
                    if (val.length == 0) {
                      return "Owner name cannot be empty";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.text,
                  onChanged: (val) {},
                  onSaved: (String value) {
                    product.owner = value;
                  },
                ),
                SizedBox(height: 2.0),
                TextFormField(
                  maxLength: 20,
                  decoration: new InputDecoration(
                    labelText: "Age/Years Old",
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: new BorderSide(),
                    ),
                    //fillColor: Colors.green
                  ),
                  validator: (val) {
                    if (val.length == 0) {
                      return "Age cannot be empty";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.number,
                  onChanged: (val) {},
                  onSaved: (String value) {
                    product.age = int.parse(value);
                  },
                ),
                SizedBox(height: 2.0),
                TextFormField(
                  maxLength: 6,
                  decoration: new InputDecoration(
                    labelText: "Reserve Price",
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: new BorderSide(),
                    ),
                    //fillColor: Colors.green
                  ),
                  validator: (val) {
                    if (val.length < 0) {
                      return "Reserve price cannot be less than 0";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.number,
                  onChanged: (val) {},
                  onSaved: (String value) {
                    product.reservePrice = double.parse(value);
                  },
                ),
                //SizedBox(height: 2.0),

                Text('Add Images',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 5.0),


                RaisedButton(
                    color: Colors.green[700],
                    child: Text('Upload Image1'),
                    onPressed: () {
                      showModalBottomSheet(context: context,
                          builder: ((builder) => imageSourceSelector(context, 1)));
                    }
                ),
                RaisedButton(
                    color: Colors.green[700],
                    child: Text('Upload Image2'),
                    onPressed: () {
                      showModalBottomSheet(context: context,
                          builder: ((builder) => imageSourceSelector(context, 2)));
                    }
                ),

                // RaisedButton(
                //   onPressed: () async {
                //     if(_formKey.currentState.validate())
                //     {
                //       _formKey.currentState.save();
                //       product.id = loggedUser.uid;
                //       product.lastUpdatedOn = DateTime.now();
                //       product.lastUpdatedBy = loggedUser.uid;
                //       await dbConnection.updateProductData(product, productPhoto1, productPhoto2);
                //       // Navigator.push(context, MaterialPageRoute(
                //       //     builder: (context) => Home()
                //       // ));
                //     }
                //   },
                //   color: Colors.green[700],
                //   child: Text('ADD'),
                // ),
                // Expanded(
                //     child: Column(
                //       children:_getImages()
                //     )
                // ),
                RaisedButton(
                  onPressed: () async {
                    if(_formKey.currentState.validate())
                    {
                      _formKey.currentState.save();
                      product.id = user.uid;
                      product.lastUpdatedOn = DateTime.now();
                      product.lastUpdatedBy = user.uid;
                      await dbConnection.updateProductData(product, productPhoto1, productPhoto2);
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => Home()
                      ));
                    }
                  },
                  color: Colors.green[700],
                  child: Text('ADD'),
                ),
              ],
            ),

        ),
      ),
        )
    );
  }
}
