class IkoddiForfaitModel {
  String id;
  List<dynamic>? bonusDays;
  String? title;
  String? forfaitDocumentPath;
  num? feeFactor;
  String? amount;
  String? forfaitId;
  String? operatorr;
  List<dynamic> allowedAmounts;
  String? allowedMinAmount;
  int? allowedMaxAmount;
  String? description;
  bool isAvailable;
  num? bonusFactor;
  bool? isAmountEditable;
  List<dynamic> availableDays;

  IkoddiForfaitModel({
    required this.id,
    required this.title,
    required this.bonusDays,
    this.forfaitDocumentPath,
    this.feeFactor,
    this.amount,
    required this.operatorr,
    this.bonusFactor,
    required this.allowedAmounts,
    this.allowedMinAmount,
    this.allowedMaxAmount,
    this.forfaitId,
    required this.description,
    required this.isAvailable,
    this.isAmountEditable,
    required this.availableDays,
  });

  factory IkoddiForfaitModel.fromJson(Map<String, dynamic> json) {
    return IkoddiForfaitModel(
      id: json['id'],
      forfaitId: json['forfaitId'],
      title: json['title'],
      bonusDays: json['bonusDays'],
      forfaitDocumentPath: json['forfaitDocumentPath'],
      feeFactor: json['feeFactor'],
      amount: json['amount'],
      operatorr: json['operator'],
      bonusFactor: json['bonusFactor'],
      allowedAmounts: json['allowedAmounts'] ?? [],
      allowedMinAmount: json['allowedMinAmount'],
      allowedMaxAmount: json['allowedMaxAmount'],
      description: json['description'],
      isAvailable: json['isAvailable'] == true || json['isAvailable'] == 1,
      isAmountEditable:
          json['isAmountEditable'] == true || json['isAmountEditable'] == 1,
      availableDays: json['availableDays'] ?? [],
    );
  }

  @override
  String toString() {
    return 'Forfait{forfaitId: $forfaitId,id: $id, title: $title,bonusFactor: $bonusFactor, bonusDays: $bonusDays, feeFactor: $feeFactor, montant: $amount, allowedAmounts: $allowedAmounts, allowedMinAmount: $allowedMinAmount, allowedMaxAmount: $allowedMaxAmount, operator: $operatorr  description: $description, isAvailable: $isAvailable, isAmountEditable: $isAmountEditable, availableDays: $availableDays}';
  }
}
