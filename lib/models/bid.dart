
class Bid {

  String id;
  String type; // highest price or buyer
  String productId;
  List<String> bidders; // Max of 3
  List<double> bidVal; // Max of 3
  DateTime startTime;
  DateTime endTime;
  double priceIncrement;
  double basePrice;
  String status; // Active/Closed
  String bidWinner;
  double finalBidPrice;


  Bid({ this.id, this.type, this.productId, this.bidders, this.bidVal, this.startTime,
        this.endTime, this.priceIncrement, this.basePrice, this.status, this.bidWinner, this.finalBidPrice });

}