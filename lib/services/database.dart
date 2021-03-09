import 'package:bidding_market/main.dart';
import 'package:bidding_market/models/brew.dart';
import 'package:bidding_market/models/buyerModel.dart';
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

  Future<String> uploadImage(File Image, String imageName) async{
    print("Entering uploadImage");
    StorageReference dbFirestoreCollection = FirebaseStorage.instance.ref().child('$imageName');
    StorageUploadTask uploadTask = dbFirestoreCollection.putFile(Image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    taskSnapshot.ref.getDownloadURL().then((value) {
      print("Done: $value");
      return value;
    });
    return "File not uploaded";
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
    String IdBackUrl = await uploadImage(aadharBack, IdBackFileName);
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