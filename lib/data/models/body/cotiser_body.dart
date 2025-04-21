class CotiserBody {
  int? tontine;
  int? periode;
  double? montant;
  String? provider;
  String? telephone;
  String? code_otp;
  String? trans_id;
  String? request_id;


  CotiserBody({
    this.tontine,
    this.periode,
    this.montant,
    this.provider,
    this.telephone,
    this.code_otp,
    this.trans_id,
    this.request_id,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["tontine"] = this.tontine;
    data["periode"] = this.periode;
    data["montant"] = this.montant;
    data["provider"] = this.provider;
    data["telephone"] = this.telephone;
    data["code_otp"] = this.code_otp;
    data["trans_id"] = this.trans_id;
    data["request_id"] = this.request_id;
    return data;
  }

}
