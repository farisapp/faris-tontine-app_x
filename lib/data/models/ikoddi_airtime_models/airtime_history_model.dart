class BuyAirtimeHistoryModel {
  String createdAt;
  int id;
  String? payment_number;
  String? receiver_number;
  String? operatorr;
  num? amount;
  num? fees;
  String? description;
  String? title;

  BuyAirtimeHistoryModel({
    required this.id,
    this.title,
    required this.createdAt,
    this.fees,
    this.amount,
    this.operatorr,
    this.description,
    this.receiver_number,
    this.payment_number,
  });

  factory BuyAirtimeHistoryModel.fromJson(Map<String, dynamic> json) {
    return BuyAirtimeHistoryModel(
      id: json['id'],
      title: json['title'],
      fees: json['fees'],
      createdAt: json['created_at'],
      amount: json['amount'],
      operatorr: json['operator'],
      description: json['description'],
      payment_number: json['payment_number'],
      receiver_number: json['receiver_number'],
    );
  }

  @override
  String toString() {
    return 'Forfait{id: $id,createdAt: $createdAt title: $title, fees: $fees, montant: $amount, operator: $operatorr,  description: $description,receiver_number: $receiver_number,payment_number: $payment_number ';
  }
}
