import 'dart:io';
import 'package:bidding_market/main.dart';
import 'package:bidding_market/models/buyerModel.dart';
import 'package:bidding_market/models/products.dart';
import 'package:bidding_market/screens/home/home.dart';
import 'package:bidding_market/screens/myProducts.dart';
import 'package:bidding_market/services/database.dart';
import 'package:bidding_market/models/user.dart';
import 'package:bidding_market/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:date_field/date_field.dart';
import 'package:intl/intl.dart';


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
    _ProductRegisterFormState p = new _ProductRegisterFormState(null);
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
  final Product prod;  // <--- generates the error, "Field doesn't override an inherited getter or setter"
  ProductRegisterForm({
    Product p
  }): this.prod = p;

  @override
  _ProductRegisterFormState createState() => _ProductRegisterFormState(prod);
}

class _ProductRegisterFormState extends State<ProductRegisterForm> {
  final Product prod;
  _ProductRegisterFormState(this.prod);


  final _formKey = GlobalKey<FormState>();

  Product product = Product();

  DatabaseService dbConnection = DatabaseService();

  File productPhoto1 , productPhoto2 , productPhoto3;

  final ImagePicker _picker = ImagePicker();
  static List<String> imagesList = [null];
  bool loading = false;

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
                    retreiveImage(ImageSource.camera, imageNumber, context);
                  },
                  icon: Icon(Icons.camera_alt)
              ),
              FlatButton.icon(
                  label: Text("Gallery"),
                  onPressed: () {
                    retreiveImage(ImageSource.gallery, imageNumber, context);}, icon: Icon(Icons.image)),
            ],
          )
        ],
      ),

    );
  }

  void retreiveImage(ImageSource source, int imageNumber ,BuildContext context) async {
    final pickedFile = await _picker.getImage(imageQuality: 25,source: source);
    File _imageFile = File(pickedFile.path);
    Navigator.pop(context);
    setState(() {
      if (imageNumber == 1) {
        productPhoto1 = _imageFile;
      }
      else if (imageNumber == 2) {
        productPhoto2 = _imageFile;
      }
      else if (imageNumber == 3) {
        productPhoto3 = _imageFile;
      }
    });
  }

  //TODO :: GUI change in Add image buttons
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
    String _category;
    final dateController = TextEditingController(text : (prod != null) ? prod.age.year.toString() : '');

    return  loading ? Loading() : Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0.0,
        title: (prod != null) ? Text('Update Your Farm') : Text('Add Your Farm'),
        ),

        body:  SingleChildScrollView(
           scrollDirection: Axis.vertical,
           child:Container(
           child: Form(
            key: _formKey,
            child: Column(
              children:[
                SizedBox(height: 15.0),
                // TextFormField(
                //   maxLength: 20,
                //   decoration: new InputDecoration(
                //     labelText: "Category",
                //     fillColor: Colors.white,
                //     border: new OutlineInputBorder(
                //       borderRadius: new BorderRadius.circular(25.0),
                //       borderSide: new BorderSide(),
                //     ),
                //     //fillColor: Colors.green
                //   ),
                //   validator: (val) {
                //     if (val.length == 0) {
                //       return "Category cannot be empty";
                //     } else {
                //       return null;
                //     }
                //   },
                //   keyboardType: TextInputType.name,
                //   onSaved: (String value) {
                //     product.category = value;
                //   },
                // ),
                DropdownButtonFormField<String>(
                  decoration: new InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: "Category",
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: new BorderSide(),
                    ),
                    //fillColor: Colors.green
                  ),
                  value: _category,
                  items: ['GUAVA' , 'PAPAYA' , 'AMLA']
                      .map((label) => DropdownMenuItem(
                    child: Text(label.toString()),
                    value: label,
                  ))
                      .toList(),
                  hint: Text( (prod != null) ? prod.category : 'Category'),
                  onChanged: (value) {
                    setState(() {
                      _category = value;
                    });
                  },
                  onSaved: (String value){
                    product.category = value;
                    },
                ),
//TODO : Location API
                SizedBox(height: 10.0),
                // TextFormField(
                //   maxLength: 20,
                //   decoration: new InputDecoration(
                //     labelText: "Location",
                //     fillColor: Colors.white,
                //     border: new OutlineInputBorder(
                //       borderRadius: new BorderRadius.circular(25.0),
                //       borderSide: new BorderSide(),
                //     ),
                //     //fillColor: Colors.green
                //   ),
                //   validator: (val) {
                //     if (val.length == 0) {
                //       return "Location cannot be empty";
                //     } else {
                //       return null;
                //     }
                //   },
                //   keyboardType: TextInputType.text,
                //   onChanged: (val) {},
                //   onSaved: (String value) {
                //     product.location = value;
                //   },
                // ),

                // SizedBox(height: 2.0),
                // TextFormField(
                //   maxLength: 20,
                //   decoration: new InputDecoration(
                //     labelText: "Owner",
                //     fillColor: Colors.white,
                //     border: new OutlineInputBorder(
                //       borderRadius: new BorderRadius.circular(25.0),
                //       borderSide: new BorderSide(),
                //     ),
                //     //fillColor: Colors.green
                //   ),
                //   validator: (val) {
                //     if (val.length == 0) {
                //       return "Owner name cannot be empty";
                //     } else {
                //       return null;
                //     }
                //   },
                //   keyboardType: TextInputType.text,
                //   onChanged: (val) {},
                //   onSaved: (String value) {
                //     product.owner = value;
                //   },
                // ),

                SizedBox(height: 2.0),
                // TextFormField(
                //   maxLength: 20,
                //   decoration: new InputDecoration(
                //     labelText: "Age/Years Old",
                //     fillColor: Colors.white,
                //     border: new OutlineInputBorder(
                //       borderRadius: new BorderRadius.circular(25.0),
                //       borderSide: new BorderSide(),
                //     ),
                //     //fillColor: Colors.green
                //   ),
                //   validator: (val) {
                //     if (val.length == 0) {
                //       return "Age cannot be empty";
                //     } else {
                //       return null;
                //     }
                //   },
                //   keyboardType: TextInputType.number,
                //   onChanged: (val) {},
                //   onSaved: (String value) {
                //     product.age = int.parse(value);
                //   },
                // ),

               // TextFormField(
               //   readOnly: true,
               //   controller: dateController,
               //   //initialValue : prod !=null ? prod.age.year.toString() : 'Age/Years Old',
               //   decoration: InputDecoration(
               //     hintText: prod !=null ? prod.age.year.toString() : 'Age/Years Old',
               //     labelText: 'Age/Years Old',
               //     fillColor: Colors.white,
               //     border: new OutlineInputBorder(
               //         borderRadius: new BorderRadius.circular(25.0),
               //         borderSide: new BorderSide()
               //         ),
               //   ),
               //   onTap: () async {
               //     var date =  await showDatePicker(
               //         context: context,
               //         initialDate:DateTime.now(),
               //         firstDate:DateTime(1900),
               //         lastDate: DateTime(2100));
               //    dateController.text = date.toString().substring(0,10);
               //     product.age = date;
               //     //if(date != null) setState(() => dateController.text = date.toString());
               //   },
               //
               //   onSaved: (String value) {
               //     product.age = DateTime( int.parse(dateController.text.substring(0,4)) , int.parse(dateController.text.substring(5,7)),
               //                              int.parse(dateController.text.substring(8,10)));
               //   },
               // ),

               DateField(
                 onDateSelected: (DateTime value) {
                   setState(() {
                     product.age = value;
                   });
                 },
                 decoration: new InputDecoration(
                   labelText:  "Age/Years Old",
                   fillColor: Colors.white,
                   border: new OutlineInputBorder(
                     borderRadius: new BorderRadius.circular(25.0),
                     borderSide: new BorderSide(),
                   ),
                 ),
                 label: (prod!=null ) ? prod.age.year.toString() : "Age/Years Old",
                 dateFormat: DateFormat.yMd(),
                 firstDate: DateTime(1980, 1, 1),
                 lastDate: DateTime.now(),
                 selectedDate: product.age,
               ),

                SizedBox(height: 10.0),
                TextFormField(
                  initialValue: prod !=null ? prod.size.toString() : "",
                  maxLength: 6,
                  decoration: new InputDecoration(
                    labelText: "Bheega",
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: new BorderSide(),
                    ),
                    //fillColor: Colors.green
                  ),
                  validator: (val) {
                    if (val.length < 1) {
                      return "Bheega cannot be less than 1 digit";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.number,
                  onChanged: (val) {},
                  onSaved: (String value) {
                    product.size = int.parse(value);
                  },
                ),

                SizedBox(height: 2.0),
                TextFormField(
                  initialValue: prod !=null ? prod.noOfPlants.toString() : "",
                  maxLength: 6,
                  decoration: new InputDecoration(
                    labelText: "Number of Plants",
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: new BorderSide(),
                    ),
                    //fillColor: Colors.green
                  ),
                  validator: (val) {
                    if (val.length < 0) {
                      return "Number of Plants cannot be less than 0";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.number,
                  onChanged: (val) {},
                  onSaved: (String value) {
                    product.noOfPlants = int.parse(value);
                  },
                ),

                SizedBox(height: 2.0),
                TextFormField(
                  initialValue: prod !=null ? prod.reservePrice.toString() : "",
                  maxLength: 8,
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
                SizedBox(height: 2.0),



                Text('Add Images',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 5.0),


                RaisedButton(
                    color: Colors.green[700],
                    child: Text('Upload Farm Profile Image1'),
                    onPressed: () {
                      showModalBottomSheet(context: context,
                          builder: ((builder) => imageSourceSelector(context, 1)));
                    }
                ),
                productPhoto1 != null ? Container(height: 200, child: Image.file(productPhoto1)) : SizedBox(height: 5.0),

                RaisedButton(
                    color: Colors.green[700],
                    child: Text('Upload Farm Profile Image2'),
                    onPressed: () {
                      showModalBottomSheet(context: context,
                          builder: ((builder) => imageSourceSelector(context, 2)));
                    }
                ),
                productPhoto2 != null ? Container(height: 200, child: Image.file(productPhoto2)) : SizedBox(height: 5.0),

                RaisedButton(
                    color: Colors.green[700],
                    child: Text('Upload Farm Profile Image3'),
                    onPressed: () {
                      showModalBottomSheet(context: context,
                          builder: ((builder) => imageSourceSelector(context, 3)));
                    }
                ),
                productPhoto3 != null ? Container(height: 200, child: Image.file(productPhoto3)) : SizedBox(height: 5.0),

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
                      setState(() => loading = true);
                      _formKey.currentState.save();

                      if( prod == null ) // ADDITION OF PRODUCT
                          {
                        //Filing out productId by first counting number of products already added by same user

                        product.id = user.uid;
                        var documents = dbConnection.dbProductCollection
                            .getDocuments();
                        int currentProductNo = 1;
                        await documents.then((snapshot) {
                          snapshot.documents.forEach((result) {
                            String productUid = result.data()['ID']
                                .toString()
                                .split('#')[0];
                            int productNum = int.parse(
                                result.data()['ID'].toString().split('#')[1]
                                    .substring(1));
                            print("Product Uid is $productUid");
                            print(productNum);
                            if (productUid.compareTo(user.uid) == 0 &&
                                productNum >= currentProductNo) {
                              currentProductNo = productNum + 1;
                              print("CurrentProduct is $currentProductNo");
                            }
                          });
                        });
                        product.id =
                            user.uid + "#p" + currentProductNo.toString();

                        //TODO :: change owner field to user name
                        //Owner Name will be displayed only if the product is added by Seller Login
                        await dbConnection.dbSellerCollection.document(user.uid)
                            .get()
                            .then((DocumentSnapshot documentSnapshot) {
                          if (documentSnapshot.exists) {
                            product.owner = documentSnapshot['Name'];
                            product.location = documentSnapshot['Village'];
                          }
                          else
                            product.owner = user.uid;
                        });
                        product.lastUpdatedOn = DateTime.now();
                        product.lastUpdatedBy = user.uid;
                        await dbConnection.addProductData(
                            product, productPhoto1, productPhoto2,
                            productPhoto3);

                        setState(() {
                          loading = false;
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => Home()
                          ));
                        });
                      }
                      else  // UPDATION OF PRODUCT
                        {
                          product.lastUpdatedOn = DateTime.now();
                          product.lastUpdatedBy = user.uid;
                          await dbConnection.updateProductData(
                            prod, product, productPhoto1, productPhoto2,
                            productPhoto3);

                          setState(() {
                            loading = false;
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => MyProducts()
                            ));
                          });
                        }


                    }
                  },
                  color: Colors.green[700],
                  child: (prod != null) ? Text('UPDATE') : Text('ADD'),
                ),
              ],
            ),

        ),
      ),
        )
    );
  }
}
