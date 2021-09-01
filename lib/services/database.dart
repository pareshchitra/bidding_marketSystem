import 'dart:ffi';

import 'package:bidding_market/main.dart';
import 'package:bidding_market/models/bid.dart';
import 'package:bidding_market/models/brew.dart';
import 'package:bidding_market/models/buyerModel.dart';
import 'package:bidding_market/models/products.dart';
import 'package:bidding_market/models/user.dart';
import 'package:bidding_market/screens/registeration/BuyerForm.dart';
import 'package:bidding_market/shared/sharedPrefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:bidding_market/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'language_constants.dart';

class ProgressDialogBar extends StatefulWidget {
  UploadTask storageTask;
  File Image;
  String imageName;

  ProgressDialogBar({Key key, this.Image, this.imageName, this.storageTask}) : super(key: key);
  double progressPercent;

  @override
  _ProgressDialogBarState createState() => _ProgressDialogBarState();
}
class _ProgressDialogBarState extends State<ProgressDialogBar> {

  void _startUpload() {
    setState(() {
      Reference dbFirestoreCollection = FirebaseStorage.instance.ref().child('$widget.imageName');
      widget.storageTask = dbFirestoreCollection.putFile(widget.Image);
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Entering ProgressBar widget");
    if (widget.storageTask != null) {
      return StreamBuilder(
          stream: widget.storageTask.events,
          builder: (context, snapshot) {
            var event = snapshot?.data?.snapshot;
            widget.progressPercent = event != null
                ? event.bytesTransferred / event.totalByteCount
                : 0;

            return _showDialog(context);
          }
      );
    }
    else
    {
      _startUpload();
    }
  }

  _showDialog(BuildContext context)
  {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(toBeginningOfSentenceCase(getTranslated(context, "file_upload_key"))),
            content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LinearProgressIndicator(value: widget.progressPercent),
                  Text(
                    '${(widget.progressPercent * 100).toStringAsFixed(2)} % ',
                    style:  TextStyle(fontSize: 50),
                  ),
                  //if(widget.storageTask.isComplete)
                    Text("helle",
                        style: TextStyle(
                            color: Colors.greenAccent,
                            height: 2,
                            fontSize: 30)),
                ]),);
        });
  }
}



class DatabaseService {

  final String uid;
  DatabaseService({ this.uid });

  // collection reference
  //FirebaseFirestore db = FirebaseFirestore.instance;
  final CollectionReference dbSellerCollection = FirebaseFirestore.instance.collection('Seller');
  final CollectionReference dbBuyerCollection = FirebaseFirestore.instance.collection('Buyer');
  final CollectionReference dbPhoneCollection = FirebaseFirestore.instance.collection('PhoneNo');
  final CollectionReference dbProductCollection = FirebaseFirestore.instance.collection('Product');
  final CollectionReference dbBidCollection = FirebaseFirestore.instance.collection('Bid');



  // //Shared_preference Object
  // Future<void> _initSharedPreference() async {
  //   SharedPreferences _prefs = await SharedPreferences.getInstance();
  //   prefs = await _prefs;
  // }


  Future<String> uploadImage(File Image, String imageName) async{
    print("Entering uploadImage");
    String value = "";
    //AlertDialog progressDialog = new AlertDialog();
    UploadTask uploadTask;

    //ProgressDialogBar(Image: Image, imageName: imageName,storageTask: uploadTask);
    Reference dbFirestoreCollection = FirebaseStorage.instance.ref().child('$imageName');
    uploadTask = dbFirestoreCollection.putFile(Image);

    //dialogBar.createState();
    //TaskSnapshot taskSnapshot = await uploadTask.onComplete;
    value = await (await uploadTask).ref.getDownloadURL().then((value) {
      print("Done: $value");
      return value;
    });
    return value;
  }

  Future <void> updatePhoneData(String Phone, String uid, int type) async {
    if(type == 1)
      {
        //SharedPreference Update
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // //prefs = await _prefs;
        // prefs.setString('PhoneNo', Phone);
        // prefs.setInt('RegisterState', 1);
        // prefs.commit();
        SharedPrefs().phoneNo = Phone;
        SharedPrefs().registerState = 1;
      }
    else if(type == 2)
      {
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // prefs.setInt('RegisterState', 2);
        // prefs.commit();
        SharedPrefs().registerState = 2;

        return await dbPhoneCollection.document(Phone).setData({
          'Uid': uid
        });
      }
  }

  Future<void> initialLoggedUserCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs = await _prefs;
    bool _userState = prefs.containsKey('PhoneNo');
    if(_userState == true)
      {
        int _state = prefs.getInt('RegisterState');
       loggedUser.type = _state - 1;
        print(_state);
      }
    else
      {
        loggedUser.type = 0; //NewUser
      }
  }

  Future<void> checkIfPhoneExists(String Phone) async {
  DocumentSnapshot ds;
  ds = await dbPhoneCollection.document(Phone).get();
  print('Phone Number exists: ${ds.exists}');
  if(ds.exists == true)
  {
  loggedUser.type = 1; //Default to move to homePage
  }
  else
    {
      loggedUser.type = 0; //Not Found Data
    }
}

  Future<void> addSellerData(User seller, File photo) async {
    print("Entering addSellerData");
    loggedUser.type = 2;
    seller.type = 2;
    print(seller.uid);
    print(seller.Name);
    print(seller.Village);
    print(seller.District);
    print(seller.State);
    print(seller.Pincode);
    print(loggedUser.PhoneNo);

    // loggedUser.PhoneNo = "0000";
    // print(loggedUser.PhoneNo);
    seller.photo = "";

    String PhotoFileName = "seller/${seller.uid}/Photo";
    if(photo != null) {
      seller.photo = await uploadImage(photo, PhotoFileName);
    }
    print("PhotoUrl value is $seller.photo");
    if(loggedUser.PhoneNo == "NA")
      {
      SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs = await _prefs;
        String Phone = prefs.getString('PhoneNo');
        loggedUser.PhoneNo = Phone;
        seller.PhoneNo = Phone;
      }
    print(loggedUser.PhoneNo);

    await updatePhoneData(loggedUser.PhoneNo, seller.uid, 2);
    return await dbSellerCollection.document(seller.uid).setData({
      'Name': seller.Name,
      'Village': seller.Village,
      'District': seller.District,
      'State': seller.State,
      'Pincode': seller.Pincode,
      'Photo': seller.photo,
    }).then((value) => loggedUser = seller).
    catchError((error){
      print("Database addition failed with error msg $error");
    });
  }

  Future<void> addBuyerData(User buyer, File aadharFront, File aadharBack) async {
    print("Entering addBuyerData");
    loggedUser.type = 1;
    buyer.type = 1;
    print(buyer.uid);
    print(buyer.Name);
    print(buyer.HouseNo);
    print(buyer.Village);
    print(buyer.District);
    print(buyer.State);
    print(buyer.Pincode);
    print(buyer.AadharNo);
    // await dbBuyerCollection.document(buyer.uid).setData({
    //   'Name': buyer.Name,
    //   'HouseNo': buyer.HouseNo,
    //   'Village': buyer.Village,
    //   'District': buyer.District,
    //   'Pincode': buyer.Pincode,
    //   'AadharNo': buyer.AadharNo,
    // });

    String IdFrontUrl = "";
    String IdBackUrl = "";

    String IdFrontFileName = "buyer/${buyer.uid}/IdFront";
    String IdBackFileName = "buyer/${buyer.uid}/IdBack";
    if(aadharFront != null) {
      IdFrontUrl = await uploadImage(aadharFront, IdFrontFileName);
    }
    print("IdFrontUrl value is $IdFrontUrl");

    if(aadharBack != null) {
      IdBackUrl = await uploadImage(aadharBack, IdBackFileName);
    }
    print("IdBackUrl value is $IdBackUrl");

    // final FirebaseAuth auth = FirebaseAuth.instance;
    //
    // FirebaseUser user = await auth.currentUser();
    // String phoneNumber = user.get();
    if(loggedUser.PhoneNo == "NA")
    {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      //prefs = await _prefs;
      String Phone = await prefs.getString('PhoneNo') ?? 0;
      buyer.PhoneNo = Phone;
      loggedUser.PhoneNo = Phone;
    }

    await updatePhoneData(loggedUser.PhoneNo, buyer.uid, 2) ;
    return await dbBuyerCollection.document(buyer.uid).setData({
      'Name': buyer.Name,
      'HouseNo': buyer.HouseNo,
      'Village': buyer.Village,
      'District': buyer.District,
      'State': buyer.State,
      'Pincode': buyer.Pincode,
      'AadharNo': buyer.AadharNo,
      'IdFrontUrl': IdFrontUrl,
      'IdBackUrl': IdBackUrl
    }).then((value) => loggedUser = buyer).
    catchError((error){
      print("Database addition failed with error msg $error");
    });
  }



  Future<void> updateUserData(User  orgUser, User updatedUser, File photo)
  async {
    print("Entering updateUserData");
    User oldUser = new User(Name: orgUser.Name , Village: orgUser.Village , District: orgUser.District, State: orgUser.State) ;
    print(updatedUser.uid);
    print(updatedUser.Name);
    print(updatedUser.Village);
    print(updatedUser.District);
    print(updatedUser.State);
    print(updatedUser.Pincode);
    print(loggedUser.PhoneNo);

    // loggedUser.PhoneNo = "0000";
    // print(loggedUser.PhoneNo);
    String PhotoUrl = "";

    String PhotoFileName = "seller/${orgUser.uid}/Photo";
    if(photo != null) {
      PhotoUrl = await uploadImage(photo, PhotoFileName);
    }
    print("PhotoUrl value is $PhotoUrl");

    //print(loggedUser.PhoneNo);
//TODO: to update user phone number
    //await updatePhoneData(loggedUser.PhoneNo, seller.uid, 2);
    print("${updatedUser.Village}  ${orgUser.Village}");
    if( updatedUser.type == 2) {
      await dbSellerCollection.doc(orgUser.uid).update({
        if(orgUser.Name != updatedUser.Name) 'Name': updatedUser.Name,
        if(orgUser.Village != updatedUser.Village) 'Village': updatedUser.Village,
        if(orgUser.District != updatedUser.District) 'District': updatedUser.District,
        if(orgUser.State != updatedUser.State) 'State': updatedUser.State,
        if(orgUser.Pincode != updatedUser.Pincode) 'Pincode': updatedUser.Pincode,
        if(PhotoUrl != '') 'Photo': PhotoUrl,
      }).then((value) {
        loggedUser.Name = updatedUser.Name;
        loggedUser.Village = updatedUser.Village;
        loggedUser.District = updatedUser.District;
        loggedUser.State = updatedUser.State;
        loggedUser.Pincode = updatedUser.Pincode;
        if(PhotoUrl != '') loggedUser.photo = PhotoUrl;
      });
    }
    else {
      await dbBuyerCollection.doc(orgUser.uid).update({
        if(orgUser.Name != updatedUser.Name) 'Name': updatedUser.Name,
        if(orgUser.Village != updatedUser.Village) 'Village': updatedUser.Village,
        if(orgUser.District != updatedUser.District) 'District': updatedUser.District,
        if(orgUser.State != updatedUser.State) 'State': updatedUser.State,
        if(orgUser.Pincode != updatedUser.Pincode) 'Pincode': updatedUser.Pincode,
        if(orgUser.HouseNo != updatedUser.HouseNo) 'HouseNo': updatedUser.HouseNo,
        if(orgUser.AadharNo != updatedUser.AadharNo) 'AadharNo': updatedUser.AadharNo,
        if(PhotoUrl != '') 'Photo': PhotoUrl,
      }).then((value) {
        loggedUser.Name = updatedUser.Name;
        loggedUser.Village = updatedUser.Village;
        loggedUser.District = updatedUser.District;
        loggedUser.State = updatedUser.State;
        loggedUser.Pincode = updatedUser.Pincode;
        if(PhotoUrl != '') loggedUser.photo = PhotoUrl;
      });
    }

    print("to update myproducts");
    print("${updatedUser.Village}  ${oldUser.Village}");
    //TODO :: Both updates in a single transaction
    if( oldUser.Name != updatedUser.Name || oldUser.Village != updatedUser.Village )
      {
        print("Entering update Product data");
        var documents =  dbProductCollection.where("Owner" , isEqualTo: oldUser.Name).get();
        await documents.then((event) {
          if (event.docs.isNotEmpty) {
            event.docs.forEach((doc) {
              doc.reference.update({
                if(oldUser.Name != updatedUser.Name) 'Owner': updatedUser.Name,
                if(oldUser.Village != updatedUser.Village) 'Location': updatedUser.Village,
              });
            });
            }


        });

      }
  }






  Future<void> addProductData(Product  product, File productPhoto1, File productPhoto2, File productPhoto3) async {
    print("Entering addProductData");

    print(product.id);
    print(product.category);
    print(product.description);
    print(product.rating);
    print(product.owner);
    print(product.location);
    print(product.age);
    print(product.reservePrice);
    print(product.lastUpdatedOn);
    print(product.lastUpdatedBy);
    print(productPhoto1);
    print(productPhoto2);

    if( product.id == null)
      product.id = "1234";
    String photo1 = "product/${product.id}/Photo1";
    String photo2 = "product/${product.id}/Photo2";
    String photo3 = "product/${product.id}/Photo3";
    String photo1Url='';
    String photo2Url='';
    String photo3Url= '';


    if(productPhoto1 != null) {
      photo1Url = await uploadImage(productPhoto1, photo1);
    }
    print("photo1Url value is $photo1Url");

    if(productPhoto2 != null) {
      photo2Url = await uploadImage(productPhoto2, photo2);

    }
    print("photo2Url value is $photo2Url");

    if(productPhoto3 != null ) {
      photo3Url = await uploadImage(productPhoto3, photo3);
    }
    print("photo3Url value is $photo3Url");

    return await dbProductCollection.document(product.id).setData({
      'ID': product.id,
      'Category': product.category,
      'Description': product.description,
      'Rating': product.rating,
      'Owner': product.owner,
      'Location': product.location,
      'Age': product.age,
      'Size': product.size,
      'NoOfPlants': product.noOfPlants,
      'ReservePrice': product.reservePrice,
      'LastUpdatedOn': product.lastUpdatedOn,
      'LastUpdatedBy': product.lastUpdatedBy,
      'Image1': photo1Url,
      'Image2': photo2Url,
      'Image3': photo3Url

    });
  }



  Future<void> updateProductData(Product  orgProduct, Product updatedProduct, File productPhoto1, File productPhoto2, File productPhoto3) async {
    print("Entering UpdateProductData");

    print("ID : ${updatedProduct.id}"); // UpdatedProductID has not been set to originalProductID as ProductID will never change
    print("Category : ${updatedProduct.category}");
    print("Description : ${updatedProduct.description}");
    print("Rating : ${updatedProduct.rating}");
    //print(updatedProduct.owner);
    //print(updatedProduct.location);
    print("Age : ${updatedProduct.age}");
    print("Price :  ${updatedProduct.reservePrice}");
    //print(updatedProduct.lastUpdatedOn);
    //print(updatedProduct.lastUpdatedBy);
    print("Photo1 : $productPhoto1");
    print("Photo2 : $productPhoto2");


    String photo1 = "product/${orgProduct.id}/Photo1";
    String photo2 = "product/${orgProduct.id}/Photo2";
    String photo3 = "product/${orgProduct.id}/Photo3";
    String photo1Url='';
    String photo2Url='';
    String photo3Url= '';


    if(productPhoto1 != null) {
      photo1Url = await uploadImage(productPhoto1, photo1);
    }
    print("photo1Url value is $photo1Url");

    if(productPhoto2 != null) {
      photo2Url = await uploadImage(productPhoto2, photo2);

    }
    print("photo2Url value is $photo2Url");

    if(productPhoto3 != null ) {
      photo3Url = await uploadImage(productPhoto3, photo3);
    }
    print("photo3Url value is $photo3Url");

    return await dbProductCollection.doc(orgProduct.id).update({
      if(updatedProduct.category != null && orgProduct.category != updatedProduct.category) 'Category': updatedProduct.category,
      //'Description': product.description,
      if(updatedProduct.age != null && orgProduct.age != updatedProduct.age) 'Age': updatedProduct.age,
      if(orgProduct.size != updatedProduct.size) 'Size': updatedProduct.size,
      if(orgProduct.noOfPlants != updatedProduct.noOfPlants) 'NoOfPlants': updatedProduct.noOfPlants,
      if(orgProduct.reservePrice != updatedProduct.reservePrice) 'ReservePrice': updatedProduct.reservePrice,
      'LastUpdatedOn': updatedProduct.lastUpdatedOn,
      'LastUpdatedBy': updatedProduct.lastUpdatedBy,
      if( photo1Url != '') 'Image1': photo1Url,
      if( photo2Url != '') 'Image2': photo2Url,
      if( photo3Url != '') 'Image3': photo3Url

    });
  }

  Future<void> deleteProduct(Product p)  async{
    Reference firestoreStorageRef = FirebaseStorage.instance.ref().child("product/${p.id}/Photo1");
    await firestoreStorageRef.delete().then((value) {
      print("Product images deleted successfully from Storage");
      dbProductCollection.doc(p.id).delete();
    }).catchError((onError)
    {
      print("Error in deleting product images from Storage with errorCode $onError");
    });
    //await dbProductCollection.doc(p.id).delete();
  }

  Future<int> checkIfUserExists(String documentId/*documentId is uid of user*/) async {


    DocumentSnapshot ds;
    ds = await dbSellerCollection.document(documentId).get();
    print('Document in Seller: ${ds.exists}');
    if(ds.exists == true)
    {
      loggedUser.Name = ds.data()["Name"];
      loggedUser.District = ds.data()["District"];
      loggedUser.State = ds.data()["State"];
      loggedUser.Village = ds.data()["Village"];
      loggedUser.Pincode = ds.data()["Pincode"];
      loggedUser.uid = documentId;
      loggedUser.type = 2;
      loggedUser.photo = ds.data()["Photo"];
      print("Logged User is " + loggedUser.Name);
      return 2; //Seller

    }

    ds = await dbBuyerCollection.document(documentId).get();

    print('Document in Buyer: ${ds.exists}');
    if(ds.exists == true)
      {
        loggedUser.Name = ds.data()["Name"];
        loggedUser.District = ds.data()["District"];
        loggedUser.State = ds.data()["State"];
        loggedUser.Village = ds.data()["Village"];
        loggedUser.Pincode = ds.data()["Pincode"];
        loggedUser.uid = documentId;
        //TODO : PHOTO OF BUYER
        loggedUser.photo = ds.data()["IdFrontUrl"];
        loggedUser.type = 1;
        loggedUser.HouseNo = ds.data()["HouseNo"];
        loggedUser.AadharNo = ds.data()["AadharNo"];
        return 1; //Buyer
      }
    else
      {
        return 0; //New User
      }
  }


  // Future<List<Product>> getposts2() async {
  //   var eachdocument = await dbProductCollection.getDocuments();
  //   List<Product> posts = [];
  //   for (var document in eachdocument.documents) {
  //     DocumentSnapshot myposts = await generalreference
  //         .document(document.documentID)
  //         .collection("posts")
  //         .document("post2")
  //         .get();
  //     print(myposts['Pic']);
  //     Post2 post = Post2(myposts['Pic']);
  //     posts.add(post);
  //   }
  //   return posts;
  // }



  //Pagination approach to get Products list
  List<Product> products = new List<Product>();
  bool hasMore = true; // flag for more products available or not
  int documentLimit = 10; // documents to be fetched per request
  DocumentSnapshot lastDocument; // flag for last document from where next 10 records to be fetched

  Future<List<Product>> getProducts() async {
    print("getProducts called");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('RegisterState', 2);
    prefs.commit();

    QuerySnapshot querySnapshot;
    if (lastDocument == null) {
      querySnapshot = await dbProductCollection.orderBy('LastUpdatedOn', descending: true)
          .limit(documentLimit)
          .get();
    } else {
      querySnapshot = await dbProductCollection.orderBy('LastUpdatedOn', descending: true).startAfterDocument(lastDocument)
          .limit(documentLimit)
          .get();
      print(1);
      print("Query is ${querySnapshot.docs}");
      //print("QuerySnapshot data is ${querySnapshot.docs.last.data()}");
      print("Length of querySnapshot is ${querySnapshot.docs.length}");
    }
    if (querySnapshot.docs.length < documentLimit) {
      hasMore = false;
    }
    if (querySnapshot.docs.length == 0) {
      hasMore = false;
      return new List();//empty list
    }
    lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    return querySnapshot.docs.map((document) => new Product(
      id : document['ID'] ?? '',
        category : document['Category'] ?? '',
        owner : document['Owner'] ?? '',
    location : document['Location'] ?? '',
        age : document['Age'] .toDate() ?? '',
    image1 : document['Image1'] ?? '',
    image2 : document['Image2'] ?? '',
    image3 : document['Image3'] ?? '',
    reservePrice : document['ReservePrice'] ?? '',
    noOfPlants : document['NoOfPlants'] ?? '',
    size : double.parse(document['Size'].toString()) ?? '',  // Conversion is required for data before 23/08/21 when size was int
    lastUpdatedOn : document['LastUpdatedOn'] .toDate() ?? ''
    )).toList();

  }



  // product list from snapshot
  Future<List<Product>> productListFromSnapshot() async{

    SharedPreferences prefs =  await SharedPreferences.getInstance();
    prefs.setInt('RegisterState', 2);
    prefs.commit();

    List<Product> productList = new List<Product>();
    productList= [];
    print("Entering productList database func");


    // dbProductCollection.get().addOnCompleteListener(new OnCompleteListener<QuerySnapshot>() {
    // @Override
    // public void onComplete(@NonNull Task<QuerySnapshot> task) {
    // if (task.isSuccessful()) {
    // for (QueryDocumentSnapshot document : task.getResult()) {
    // Log.d(TAG, document.getId() + " => " + document.getData());
    // }
    // } else {
    // Log.d(TAG, "Error getting documents: ", task.getException());
    // }
    // }
    // });
    var documents =  dbProductCollection.get();

    await documents.then((snapshot) {
      snapshot.docs.forEach((result) {


        //print(result.data(['category']);
        Product p = new Product();
        p.id = result.data()['ID'] ?? '';
        print("ID " + result.data()['ID']);
        p.category = result.data()['Category'] ?? '';
        print("Category " + result.data()['Category']);
        //p.description = result.data['Description'] ?? '';
        //print("Description " + result.data['Description']);
        //p.rating = result.data['Rating'] ?? '';
        p.owner = result.data()['Owner'] ?? '';
        print("Owner " + result.data()['Owner']);
        p.location = result.data()['Location'] ?? '';
        //print("Location " + result.data['Location']);
        print("Age " + result.data()['Age'].toString());
        p.age = result.data()['Age'] .toDate() ?? '';
        p.image1 = result.data()['Image1'] ?? '';
        print("Image1 " + result.data()['Image1']);
        //p.isVerfied = result.data['IsVerfied'] ?? '';
        p.reservePrice = result.data()['ReservePrice'] ?? '';
        p.noOfPlants = result.data()['NoOfPlants'] ?? '';
        p.size = double.parse(result.data()['Size'].toString()) ?? '';// Conversion is required for data before 23/08/21 when size was int
        p.lastUpdatedOn = result.data()['LastUpdatedOn'] .toDate() ?? '';

        //p.lastUpdatedOn = result.data['LastUpdatedOn'] ?? '';
        //print("LastUpdatedOn " + result.data['LastUpdatedOn']);
        //p.lastUpdatedBy = result.data['LastUpdateBy'] ?? '';
        //print("lastUpdatedBy " + result.data['LastUpdateBy']);
        productList.add(p);
        print("The products fetched from database are $p");
      });
  });
    return productList;
        }

  Future<void> deletePhoneData(String phone) async {
    await dbPhoneCollection.document(phone).delete();
  }


  // product list from snapshot
  Future<List<Product>> myProducts (User currentUser) async{

    //SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.setInt('RegisterState', 2);
    //prefs.commit();

    List<Product> productList = new List<Product>();
    productList= [];
    print("Entering myProducts database func with currentUserName " + currentUser.Name);
    var documents =  dbProductCollection.where("Owner" , isEqualTo: currentUser.Name).get();

    await documents.then((event) {
      if (event.docs.isNotEmpty) {
        event.docs.forEach((res) {
          print(res.data());
          Product p = new Product();
          p.id = res.data()['ID'] ?? '';
          print("ID " + res.data()['ID']);
          p.category = res.data()['Category'] ?? '';
          print("Category " + res.data()['Category']);
          //p.description = result.data['Description'] ?? '';
          //print("Description " + result.data['Description']);
          //p.rating = result.data['Rating'] ?? '';
          p.owner = res.data()['Owner'] ?? '';
          print("Owner " + res.data()['Owner']);
          p.location = res.data()['Location'] ?? '';
          //print("Location " + result.data['Location']);
          print("Age " + res.data()['Age'].toString());
          p.age = res.data()['Age'].toDate() ?? '';
          p.image1 = res.data()['Image1'] ?? '';
          print("Image1 " + res.data()['Image1']);
          p.image2 = res.data()['Image2'];
          p.image3 = res.data()['Image3'];
          //p.isVerfied = result.data['IsVerfied'] ?? '';
          p.reservePrice = res.data()['ReservePrice'] ?? '';
          p.noOfPlants = res.data()['NoOfPlants'] ?? '';
          p.size = double.parse(res.data()['Size'].toString()) ?? ''; // Conversion is required for data before 23/08/21 when size was int
          p.location = res.data()['Location'] ?? '';
          p.lastUpdatedOn = res.data()['LastUpdatedOn'] .toDate() ?? '';
          productList.add(p);
        });
      }
    }).catchError((e) => print("error fetching data: $e"));

    return productList;
  }

  Future<Product> getProduct(String productId) async {
    DocumentSnapshot ds;
    ds = await dbProductCollection.doc(productId).get();

    if(ds.exists == true)
    {
      Product product = new Product();
      product.id = ds.data()['ID'] ?? '';
      print("ID " + ds.data()['ID']);
      product.category = ds.data()['Category'] ?? '';
      print("Category " + ds.data()['Category']);
      //p.description = result.data['Description'] ?? '';
      //print("Description " + result.data['Description']);
      //p.rating = result.data['Rating'] ?? '';
      product.owner = ds.data()['Owner'] ?? '';
      print("Owner " + ds.data()['Owner']);
      product.location = ds.data()['Location'] ?? '';
      //print("Location " + result.data['Location']);
      print("Age " + ds.data()['Age'].toString());
      product.age = ds.data()['Age'].toDate() ?? '';
      product.image1 = ds.data()['Image1'] ?? '';
      print("Image1 " + ds.data()['Image1']);
      product.image2 = ds.data()['Image2'];
      product.image3 = ds.data()['Image3'];
      //p.isVerfied = result.data['IsVerfied'] ?? '';
      product.reservePrice = ds.data()['ReservePrice'] ?? '';
      product.noOfPlants = ds.data()['NoOfPlants'] ?? '';
      product.size = double.parse(ds.data()['Size'].toString()) ?? ''; // Conversion is required for data before 23/08/21 when size was int
      product.location = ds.data()['Location'] ?? '';
      product.lastUpdatedOn = ds.data()['LastUpdatedOn'] .toDate() ?? '';
      return product;
    }
    else
    {
      print("Product with Id $productId does not exists");
      return null;
    }
  }


  Future<void> addNewBid(Bid bid) async {
    print("Entering addNewBid");
    print(bid.productId);
    print(bid.startTime);
    print(bid.basePrice);
    print(bid.endTime);

    bid.id = bid.productId;
    bid.status = "Active";
    bid.priceIncrement = bid.basePrice * 0.1;

    List<Map<String,String>> bidders = [];

    for( int i = 0; i < 3; i++ ) {
      Map<String, String> bidMap = {
        'id': null,
        'name': null,
        'price': null
      };
      bidders.add(bidMap);
    }
    return await dbBidCollection.doc(bid.id).set({
      'ProductId': bid.productId,
      'StartTime': bid.startTime,
      'EndTime': bid.endTime,
      'BasePrice': bid.basePrice,
      'Status' : bid.status,
      'Type' : bid.type,
      'Bids' : FieldValue.arrayUnion(bidders),
      //'PriceIncrement' : bid.priceIncrement,
    });
  }

  Future<Bid> getBid(String bidId) async {
    DocumentSnapshot ds;
    ds = await dbBidCollection.doc(bidId).get();

    if(ds.exists == true)
    {
      Bid bid = new Bid();
      bid.id = bidId;
      bid.productId = ds.data()['ProductId'];
      bid.startTime = ds.data()['StartTime'].toDate();
      bid.endTime = ds.data()['EndTime'].toDate();
      bid.basePrice = ds.data()['BasePrice'];
      bid.status = ds.data()['Status'];
      bid.type = ds.data()['Type'];
      List bidders = ds.data()['Bids'];
      bid.bidders = [];
      bid.bidVal = [];
      for(var bidder in bidders)
      {
        if( bidder['name'] != null )
          bid.bidders.add(bidder['name']);
        if( bidder['price'] != null )
          bid.bidVal.add(double.parse(bidder['price']));
      }
      print("Bidders are $bidders");
      bid.priceIncrement = bid.basePrice * 0.1;
      return bid;
    }
    else
    {
      print("Bid with Id $bidId does not exists");
      return null;
    }
  }

  Future<void> deleteBid(String bidId)  async{
    await dbBidCollection.doc(bidId).delete();
  }

// This function assumes that a bidder can place a bid lesser than the current highest , so sorting has been done
  Future<void> updateBidder(String bidId, String bidderId, String bidderName, double bidPrice, String productId) async {
    print("Entering updateBidder");
    print("Bidder Id is " + bidderId);
    print("Bid Price is " + bidPrice.toString());

    DocumentSnapshot ds = await dbBidCollection.doc(bidId).get();

    if( ds.exists == true )
      {
        List bidders = ds.data()["Bids"] ?? '';

        if( bidders.length < 3 )
          {
            Map<String,String> bidMap = {
              'id': bidderId,
              'name': bidderName,
              'price': bidPrice.toString()
            };

            if( bidders[0]['name'] == null ) // NO BIDDER IS PRESENT YET
              {
                bidders[0] = bidMap;
              }
            else {
              print("Bidders name is ${bidders[0]['name']}");
              bidders.add(bidMap);
              bidders.sort((a, b) =>
              (double.parse(a['price']) > (double.parse(b['price']))) ? -1 : 1);
              }
            }

        else {
          for (Map<String, String> bidder in bidders) {
            //bidderId.add(bidder['id']);
            //bidderName.add(bidder['name']);
            if (bidPrice > double.parse(bidder['price'])) {
              bidder['id'] = bidderId;
              bidder['name'] = bidderName;
              bidder['price'] = bidPrice.toString();
              break;
            }
          }
        }

        Map<String,String> buyerBidInfo = {
          'ProductId' : productId,
          'Price' : bidPrice.toString(),
        };
        DocumentSnapshot buyerDoc = await dbBuyerCollection.doc(bidderId).get();
        bool buyerBidListExists = (buyerDoc.data()['ProductBids'] != null) ? true : false;

        if(buyerBidListExists == true) {
          await dbBuyerCollection.doc(bidderId).update({
            'ProductBids': FieldValue.arrayUnion([buyerBidInfo]),
          });
        }
        else {
          await dbBuyerCollection.doc(bidderId).set({
            'ProductBids': FieldValue.arrayUnion([buyerBidInfo]),
          }, SetOptions(merge: true));
        }

        return await dbBidCollection.doc(bidId).update({
          'Bids': bidders,
          //'PriceIncrement' : bid.priceIncrement,
        });
      }
    else
      {
        print("BidId Not found for this product in Database !!! Bidding has not yet started");
      }

  }

  Future<void> updateBidStatus(String bidId, String status) async {
    print("Entering updateBidStatus");

    DocumentSnapshot ds = await dbBidCollection.doc(bidId).get();
    if( ds.exists == true )
    {
      return await dbBidCollection.doc(bidId).update({
        'Status': status,
        //'PriceIncrement' : bid.priceIncrement,
      });
    }
    else
    {
      print("BidId Not found for this product in Database !!! Bidding has not yet started");
    }

  }

  closeBid(String bidId)
  {
    updateBidStatus(bidId, "Closed");
  }

  //OPTIMIZATION : KEEP BID IDs IN PLACE OF PRODUCT IDs in Buyer Table
  Future<List<dynamic>> myBids (User currentUser) async{

    List<Map<String,dynamic>> productBidList = new List();
    productBidList = [];
    print("Entering myBids database func with currentUserName " + currentUser.Name);

    await dbBuyerCollection.doc(currentUser.uid).get().then((value) async{
      List bids = value.data()['ProductBids'];
      for(var bid in bids)
        {
          Product product = await getProduct(bid['ProductId']);
          Bid bidInfo = await getBid(bid['ProductId']);
          Map<String,dynamic> userPriceProductMap =
          {
            'Product' : product,
            'QuotePrice' : bid['Price'],
            'Bid' : bidInfo,
          };
          productBidList.add(userPriceProductMap);
        }
    }).catchError((e) => print("error fetching data: $e"));

    return productBidList;
  }


  //Pagination approach to get Bids List
  List<Bid> bids = new List<Bid>();
  bool bidHasMore = true; // flag for more products available or not
  int bidDocumentLimit = 10; // documents to be fetched per request
  DocumentSnapshot bidLastDocument; // flag for last document from where next 10 records to be fetched

  Future<List<Bid>> getAllBids(String status) async {
    print("getBids called");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('RegisterState', 2);
    prefs.commit();

    QuerySnapshot querySnapshot;

    if (bidLastDocument == null) {
      querySnapshot = await dbBidCollection.where( 'Status' , isEqualTo: status).orderBy('EndTime')
          .limit(bidDocumentLimit)
          .get();
    } else {
      querySnapshot = await dbBidCollection.where( 'Status' , isEqualTo: status).orderBy('EndTime').startAfterDocument(bidLastDocument)
          .limit(bidDocumentLimit)
          .get();
      print(1);
      print("Query is ${querySnapshot.docs}");
      //print("QuerySnapshot data is ${querySnapshot.docs.last.data()}");
      print("Length of querySnapshot is ${querySnapshot.docs.length}");
    }
    if (querySnapshot.docs.length < bidDocumentLimit) {
      bidHasMore = false;
    }
    if (querySnapshot.docs.length == 0) {
      bidHasMore = false;
      return new List();//empty list
    }
    bidLastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];

    List<Bid> bidListPagination = new List();
    bidListPagination = [];
    for( QueryDocumentSnapshot doc in querySnapshot.docs )
      {
        Bid bid = new Bid();
        bid.id = doc.id;
        bid.productId = doc['ProductId'] ?? '';
        bid.startTime = doc['StartTime'].toDate() ?? '';
        bid.endTime = doc['EndTime'].toDate() ?? '';
        bid.basePrice = doc['BasePrice'] ?? '';
        bid.status = doc['Status'] ?? '';
        bid.type = doc['Type'] ?? '';
        List bidders = doc['Bids'] ?? '';
        bid.bidders = [];
        bid.bidVal = [];
        for(var bidder in bidders)
        {
          if( bidder['name'] != null )
            bid.bidders.add(bidder['name']);
          if( bidder['price'] != null )
            bid.bidVal.add(double.parse(bidder['price']));
        }
        print("Bidders are $bidders");
        bid.priceIncrement = bid.basePrice * 0.1;

        bidListPagination.add(bid);
      }

    return bidListPagination;

  }

  // DELETE PRODUCT should be preceded with delete from bid data & if any buyer has placed bid on that product
  dbDeleteProduct(Product p) async{
    print("deleteProduct called");

    await FirebaseFirestore.instance.runTransaction((transaction) async{
    String bidId = p.id; // BidId is same as ProductId
    DocumentReference bidRef = dbBidCollection.doc(bidId);

    DocumentSnapshot ds = await transaction.get(bidRef);
    if (ds.exists == true) // This Product is in the bids collection
    {
      print("Product with id ${p.id} found in bids collection");
      List bidders = [];
      List bidData = ds.data()['Bids'];  // TODO: Only max 3 buyers will be taken from this data. Find all the buyers who have placed bids on this product and delete entried from there

      for (var bid in bidData) {
        if (bid['id'] != null) {
          print("Bidder for this product has id ${bid['id']} ");
          bidders.add(bid['id']);
        }
      }
      if (bidders.length != 0) // This Bid is having some buyers
      {
        for(var buyerId in bidders) {
          print("Finding buyer info with id $buyerId ");
          DocumentReference buyerRef = dbBuyerCollection.doc(buyerId);
          DocumentSnapshot buyerDoc = await transaction.get(buyerRef);
          List buyerBidList = buyerDoc.data()['ProductBids'];
          List updatedBuyerBidList = [];

          for(var buyerBid in buyerBidList)
          {
            String productId = buyerBid['ProductId'];
            if( productId != p.id ){
              print("Updated Bid list of the buyer contains productId $productId");
              updatedBuyerBidList.add(buyerBid);
            }
          }
          
          // TRANSACTION STARTS
          await transaction.update(buyerRef,{
            'ProductBids': updatedBuyerBidList,
          });

        }
        await transaction.delete(bidRef);
        DocumentReference productRef = dbProductCollection.doc(p.id);
        Reference firestoreStorageRef = FirebaseStorage.instance.ref().child("product/${p.id}/Photo1");
        await firestoreStorageRef.delete().then((value) {
          print("Product images deleted successfully from Storage");
          print("Deleting Product from Products Collection");
          transaction.delete(productRef);
        }).catchError((onError)
        {
          print("Error in deleting product images from Storage with errorCode $onError");
        });
        // TRANSACTION ENDS
      }
      else{ // This bid is not having any buyer
        print("This product bid with id $bidId is not having any buyer, Deleting.....");
        print("Deleting Bid from Bids Collection");
        await transaction.delete(bidRef);
        DocumentReference productRef = dbProductCollection.doc(p.id);
        Reference firestoreStorageRef = FirebaseStorage.instance.ref().child("product/${p.id}/Photo1");
        await firestoreStorageRef.delete().then((value) {
          print("Product images deleted successfully from Storage");
          print("Deleting Product from Products Collection");
          transaction.delete(productRef);
        }).catchError((onError)
        {
          print("Error in deleting product images from Storage with errorCode $onError");
        });

      }
    } else // Not in Bids Collection , can be deleted safely
      {
      print("Product with id ${p.id} not found in bids collection");
      await deleteProduct(p);
    }
  }, timeout: Duration(seconds: 10));
        }

  Future<String> getUserPhoneNo(String userUid) async
  {
    var phoneDocuments =  dbPhoneCollection.get();
    String phoneNo = "";
    await phoneDocuments.then((snapshot) {
      snapshot.docs.forEach((result) {
        //print(result.data(['category']);

        String uid = result.data()['Uid'] ?? '';
        print("Uid " + uid);
        if (uid == userUid) {
          phoneNo = result.id;
          print("PhoneNo " + phoneNo);
          //return phoneNo;
        }
      });
    });
    if( phoneNo == "" ) print("No matching given uid $userUid found in database");
    return phoneNo;
  }


  final CollectionReference brewCollection = Firestore.instance.collection('brews');

  // Future<void> updateUserData(String sugars, String name, int strength) async {
  //   return await brewCollection.document(uid).setData({
  //     'sugars': sugars,
  //     'name': name,
  //     'strength': strength,
  //   });
  // }

  // brew list from snapshot
  List<Brew> _brewListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc){
      //print(doc.data);
      return Brew(
          name: doc.data()['name'] ?? '',
          strength: doc.data()['strength'] ?? 0,
          sugars: doc.data()['sugars'] ?? '0'
      );
    }).toList();
  }

  // get brews stream
  Stream<List<Brew>> get brews {
    return brewCollection.snapshots()
        .map(_brewListFromSnapshot);
  }

}