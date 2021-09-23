
class Bid {

  String id;
  String type; // highest price or buyer
  String productId;
  List<String> bidders; // Max of ANY - NO LIMIT
  List<double> bidVal; // Max of ANY - NO LIMIT
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