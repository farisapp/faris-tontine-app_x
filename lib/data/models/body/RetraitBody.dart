class RetraitBody {
  int? tontine;
  int? montant;
  String? operateur;
  String? numero;
  String? nomCompte;


  RetraitBody({
    this.tontine,
    this.montant,
    this.operateur,
    this.numero,
    this.nomCompte
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["tontine"] = this.tontine;
    data["montant"] = this.montant;
    data["operateur"] = this.operateur;
    data["numero"] = this.numero;
    data["nom_compte"] = this.nomCompte;
    return data;
  }

}
