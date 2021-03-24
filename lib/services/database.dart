import 'package:bidding_market/main.dart';
import 'package:bidding_market/models/brew.dart';
import 'package:bidding_market/models/buyerModel.dart';
import 'package:bidding_market/models/products.dart';
import 'package:bidding_market/models/user.dart';
import 'package:bidding_market/screens/authenticate/BuyerForm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:bidding_market/services/auth.dart';

class DatabaseService {

  final String uid;
  DatabaseService({ this.uid });

  // collection reference
  final CollectionReference dbSellerCollection = Firestore.instance.collection('Seller');
  final CollectionReference dbBuyerCollection = Firestore.instance.collection('Buyer');
  final CollectionReference dbPhoneCollection = Firestore.instance.collection('PhoneNo');
  final CollectionReference dbProductCollection = Firestore.instance.collection('Product');

  Future<String> uploadImage(File Image, String imageName) async{
    print("Entering uploadImage");
    String value = "File not uploaded";
    StorageReference dbFirestoreCollection = FirebaseStorage.instance.ref().child('$imageName');
    StorageUploadTask uploadTask = dbFirestoreCollection.putFile(Image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    value = await taskSnapshot.ref.getDownloadURL().then((value) {
      print("Done: $value");
      return value;
    });
    return value;
  }

  Future <void> updatePhoneData(String Phone, String uid) async {
    return await dbPhoneCollection.document(Phone).setData({
      'Uid': uid
    });
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

  Future<void> updateSellerData(User seller) async {
    print("Entering UpdateSellerData");
    loggedUser.type = 2;
    print(seller.uid);
    print(seller.Name);
    print(seller.HouseNo);
    print(seller.Village);
    print(seller.District);
    print(seller.Pincode);
    return await dbSellerCollection.document(seller.uid).setData({
      'Name': seller.Name,
      'HouseNo': seller.HouseNo,
      'Village': seller.Village,
      'District': seller.District,
      'Pincode': seller.Pincode,
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
    String IdFrontFileName = "buyer/${buyer.uid}/IdFront";
    String IdBackFileName = "buyer/${buyer.uid}/IdBack";
    String IdFrontUrl = await uploadImage(aadharFront, IdFrontFileName);
    print("IdFrontUrl value is $IdFrontUrl");
    String IdBackUrl = await uploadImage(aadharBack, IdBackFileName);
    print("IdBackUrl value is $IdBackUrl");
    return await dbBuyerCollection.document(buyer.uid).setData({
      'Name': buyer.Name,
      'HouseNo': buyer.HouseNo,
      'Village': buyer.Village,
      'District': buyer.District,
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

    photo1Url = await uploadImage(productPhoto1, photo1);
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
      return 2; //Seller
    }

    ds = await dbBuyerCollection.document(documentId).get();

    print('Document in Buyer: ${ds.exists}');
    if(ds.exists == true)
      {
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
    List<Product> productList = new List<Product>();
    productList= [];
    print("Entering productList database func");
    var documents =  dbProductCollection.getDocuments();

    await documents.then((snapshot) {
      snapshot.documents.forEach((result) {


        //print(result.data['category']);
        Product p = new Product();
        p.id = result.data['ID'] ?? '';
        print("ID " + result.data['ID']);
        p.category = result.data['Category'] ?? '';
        print("Category " + result.data['Category']);
        //p.description = result.data['Description'] ?? '';
        //print("Description " + result.data['Description']);
        //p.rating = result.data['Rating'] ?? '';
        p.owner = result.data['Owner'] ?? '';
        print("Owner " + result.data['Owner']);
        p.location = result.data['Location'] ?? '';
        //print("Location " + result.data['Location']);
        print("Age " + result.data['Age'].toString());
        p.age = result.data['Age'] .toDate()?? '';
        p.image1 = result.data['Image1'] ?? '';
        print("Image1 " + result.data['Image1']);
        //p.isVerfied = result.data['IsVerfied'] ?? '';
        p.reservePrice = result.data['ReservePrice'] ?? '';
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
          name: doc.data['name'] ?? '',
          strength: doc.data['strength'] ?? 0,
          sugars: doc.data['sugars'] ?? '0'
      );
    }).toList();
  }

  // get brews stream
  Stream<List<Brew>> get brews {
    return brewCollection.snapshots()
        .map(_brewListFromSnapshot);
  }

}