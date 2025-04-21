
class PaymentBody {
  double? montant;
  String? provider;
  String? telephone;
  String? code_otp;
  String? provider_trans_id;

  PaymentBody({
    this.montant,
    this.provider,
    this.telephone,
    this.code_otp,
    this.provider_trans_id,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["montant"] = this.montant;
    data["provider"] = this.provider;
    data["telephone"] = this.telephone;
    data["code_otp"] = this.code_otp;
    data["provider_trans_id"] = this.provider_trans_id;
    return data;
  }

  @override
  String toString() {
    return 'PaymentBody{montant: $montant, provider: $provider, telephone: $telephone, code_otp: $code_otp, provider_trans_id: $provider_trans_id}';
  }
}