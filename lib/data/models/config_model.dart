
class Config {
  String? companyName;
  String? logo;
  String? adresse;
  String? telephoneFixe;
  String? telephoneMobile;
  String? email;
  String? urlSiteweb;
  String? termsAndConditions;
  String? privacyPolicy;
  String? aboutUs;
  String? tuto;
  String? faq;
  String? pays;
  String? syntaxeOrange;
  String? syntaxeMoov;
  String? appUrlAndroid;
  int? appMinimumVersionAndroid;
  bool? maintenanceMode;
  double? tauxTontine;
  double? tauxPay;
  int? minAmount;
  int? maxAmount;
  Commission? commission;

  Config(
      {this.companyName,
        this.logo,
        this.adresse,
        this.telephoneFixe,
        this.telephoneMobile,
        this.email,
        this.termsAndConditions,
        this.privacyPolicy,
        this.aboutUs,
        this.tuto,
        this.faq,
        this.pays,
        this.syntaxeOrange,
        this.syntaxeMoov,
        this.appUrlAndroid,
        this.appMinimumVersionAndroid,
        this.maintenanceMode,
        this.tauxTontine,
        this.tauxPay,
        this.urlSiteweb,
        this.minAmount,
        this.maxAmount,
      this.commission});

  Config.fromJson(Map<String, dynamic> json) {
    companyName = json['company_name'];
    logo = json['logo'];
    adresse = json['adresse'];
    telephoneFixe = json['telephone_fixe'];
    telephoneMobile = json['telephone_mobile'];
    email = json['email'];
    termsAndConditions = json['terms_and_conditions'];
    privacyPolicy = json['privacy_policy'];
    aboutUs = json['about_us'];
    tuto = json['tuto'];
    faq = json['faq'];
    pays = json['pays'];
    syntaxeOrange = json['syntaxe_orange'];
    syntaxeMoov = json['syntaxe_moov'];
    appUrlAndroid = json['app_url_android'];
    appMinimumVersionAndroid = json['app_minimum_version_android'];
    maintenanceMode = json['maintenance_mode'];
    tauxTontine = json['taux_tontine'] != null ? double.parse(json['taux_tontine'].toString()) : 0.0 ;
    tauxPay = json['taux_pay'] != null ? double.parse(json['taux_pay'].toString()) : 0.0;
    minAmount = json['min_amount'] != null ? int.parse(json['min_amount'].toString()) : 0;
    maxAmount = json['max_amount'] != null ? int.parse(json['max_amount'].toString()) : 0;
    urlSiteweb = json['url_siteweb'];
    commission = json['commission'] != null ? Commission.fromJson(json['commission']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['company_name'] = this.companyName;
    data['logo'] = this.logo;
    data['adresse'] = this.adresse;
    data['telephone_fixe'] = this.telephoneFixe;
    data['telephone_mobile'] = this.telephoneMobile;
    data['email'] = this.email;
    data['terms_and_conditions'] = this.termsAndConditions;
    data['privacy_policy'] = this.privacyPolicy;
    data['about_us'] = this.aboutUs;
    data['tuto'] = this.tuto;
    data['faq'] = this.faq;
    data['pays'] = this.pays;
    data['syntaxe_orange'] = this.syntaxeOrange;
    data['syntaxe_moov'] = this.syntaxeMoov;
    data['app_url_android'] = this.appUrlAndroid;
    data['app_minimum_version_android'] = this.appMinimumVersionAndroid;
    data['maintenance_mode'] = this.maintenanceMode;
    data['taux_tontine'] = this.tauxTontine;
    data['taux_pay'] = this.tauxPay;
    data['min_amount'] = this.minAmount;
    data['max_amount'] = this.maxAmount;
    data['url_siteweb'] = this.urlSiteweb;
    data['commissiom'] = this.commission;
    return data;
  }
}

class Commission{
  String? plageUn;
  double? tauxUn;
  String? plageDeux;
  double? tauxDeux;
  String? plageTrois;
  double? tauxTrois;
  String? plageQuatre;
  double? tauxQuatre;

  Commission(
      {this.plageUn,
      this.tauxUn,
      this.plageDeux,
      this.tauxDeux,
      this.plageTrois,
      this.tauxTrois,
      this.plageQuatre,
      this.tauxQuatre});

  Commission.fromJson(Map<String, dynamic> json) {
    plageUn = json['plage_un'];
    tauxUn = json['taux_un'] != null ? double.parse(json['taux_un'].toString()) : 0.0;
    plageDeux = json['plage_deux'];
    tauxDeux = json['taux_deux'] != null ? double.parse(json['taux_deux'].toString()) : 0.0;
    plageTrois = json['plage_trois'];
    tauxTrois = json['taux_trois'] != null ? double.parse(json['taux_trois'].toString()) : 0.0;
    plageQuatre = json['plage_quatre'];
    tauxQuatre = json['taux_quatre'] != null ? double.parse(json['taux_quatre'].toString()) : 0.0;

  }
}