class User {

  String uid;
  String Name;
  String HouseNo;
  String Village;
  String District;
  String Pincode;
  int type; //0 for new user, 1 for buyer, 2 for seller

  User({ this.uid, this.Name, this.HouseNo, this.Village, this.District, this.Pincode, this.type });

}