class User {

  String uid;
  String Name;
  String State;
  String Village;
  String District;
  String Pincode;
  String PhoneNo;
  int type = 0; //0 for new user, 1 for buyer, 2 for seller

  User({ this.uid, this.Name, this.State, this.Village, this.District, this.Pincode, this.PhoneNo,this.type });

}