class Product {

  String id;
  String category;
  String description;
  double rating;
  String owner;
  String location;
  DateTime age;
  double size;
  int noOfPlants;
  String image1; //URL
  String image2;
  String image3;
  bool isVerified;
  double reservePrice;
  DateTime lastUpdatedOn;
  String lastUpdatedBy;

  Product({ this.id , this.category , this.description , this.rating , this.owner , this.location , this.age ,
            this.size , this.noOfPlants , this.image1 , this.image2 , this.image3, this.reservePrice , this.lastUpdatedOn , this.lastUpdatedBy});

}