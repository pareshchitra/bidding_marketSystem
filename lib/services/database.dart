import 'package:bidding_market/main.dart';
import 'package:bidding_market/models/brew.dart';
import 'package:bidding_market/models/buyerModel.dart';
import 'package:bidding_market/models/products.dart';
import 'package:bidding_market/models/user.dart';
import 'package:bidding_market/screens/registeration/BuyerForm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:bidding_market/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:shared_preferences/shared_preferences.dart';

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
            title: Text('File Upload'),
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



  // //Shared_preference Object
  // Future<void> _initSharedPreference() async {
  //   SharedPreferences _prefs = await SharedPreferences.getInstance();
  //   prefs = await _prefs;
  // }


  Future<String> uploadImage(File Image, String imageName) async{
    print("Entering uploadImage");
    String value = "File not uploaded";
    //AlertDialog progressDialog = new AlertDialog();
    UploadTask uploadTask;

    //ProgressDialogBar(Image: Image, imageName: imageName,storageTask: uploadTask);
    Reference dbFirestoreCollection = FirebaseStorage.instance.ref().child('$imageName');
    uploadTask = dbFirestoreCollection.putFile(Image);

    //dialogBar.createState();
    // TaskSnapshot taskSnapshot = await uploadTask.onComplete;
    // value = await taskSnapshot.ref.getDownloadURL().then((value) {
    //   print("Done: $value");
    //   return value;
    // });
    return value;
  }

  Future <void> updatePhoneData(String Phone, String uid, int type) async {
    if(type == 1)
      {
        //SharedPreference Update
        SharedPreferences prefs = await SharedPreferences.getInstance();
        //prefs = await _prefs;
        prefs.setString('PhoneNo', Phone);
        prefs.setInt('RegisterState', 1);
        prefs.commit();
      }
    else if(type == 2)
      {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('RegisterState', 2);
        prefs.commit();
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

  Future<void> updateSellerData(User seller, File photo) async {
    print("Entering UpdateSellerData");
    loggedUser.type = 2;
    print(seller.uid);
    print(seller.Name);
    print(seller.Village);
    print(seller.District);
    print(seller.State);
    print(seller.Pincode);
    print(loggedUser.PhoneNo);

    // loggedUser.PhoneNo = "0000";
    // print(loggedUser.PhoneNo);
    String PhotoUrl = "";

    String PhotoFileName = "seller/${seller.uid}/Photo";
    if(photo != null) {
      PhotoUrl = await uploadImage(photo, PhotoFileName);
    }
    print("PhotoUrl value is $PhotoUrl");
    if(loggedUser.PhoneNo == "NA")
      {
      SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs = await _prefs;
        String Phone = prefs.getString('PhoneNo');
        loggedUser.PhoneNo = Phone;
      }
    print(loggedUser.PhoneNo);

    await updatePhoneData(loggedUser.PhoneNo, seller.uid, 2);
    return await dbSellerCollection.document(seller.uid).setData({
      'Name': seller.Name,
      'Village': seller.Village,
      'District': seller.District,
      'State': seller.State,
      'Pincode': seller.Pincode,
      'Photo': PhotoUrl,
    });
  }

  Future<void> updateBuyerData(BuyerModel buyer, File aadharFront, File aadharBack) async {
    print("Entering UpdateBuyerData");
    loggedUser.type = 1;
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
    });
  }

  Future<void> updateProductData(Product  product, File productPhoto1, File productPhoto2, File productPhoto3) async {
    print("Entering UpdateProductData");

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
      loggedUser.uid = documentId;
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
        loggedUser.uid = documentId;
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
        p.size = result.data()['Size'] ?? '';
        p.location = result.data()['Location'] ?? '';
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
          //p.isVerfied = result.data['IsVerfied'] ?? '';
          p.reservePrice = res.data()['ReservePrice'] ?? '';
          p.noOfPlants = res.data()['NoOfPlants'] ?? '';
          p.size = res.data()['Size'] ?? '';
          p.location = res.data()['Location'] ?? '';
          p.lastUpdatedOn = res.data()['LastUpdatedOn'] .toDate() ?? '';
          productList.add(p);
        });
      }
    }).catchError((e) => print("error fetching data: $e"));

    return productList;
  }

  final CollectionReference brewCollection = Firestore.instance.collection('brews');

  Future<void> updateUserData(String sugars, String name, int strength) async {
    return await brewCollection.document(uid).setData({
      'sugars': sugars,
      'name': name,
      'strength': strength,
    });
  }

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