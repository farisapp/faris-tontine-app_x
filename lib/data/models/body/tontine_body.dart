class TontineBody {
  String? type;
  String? libelle;
  bool? isPublic;
  int? nbre_personne;
  int? nbre_periode;
  String? periodicite;
  double? montant_tontine;
  double? montant_tontine_frais;
  double? frais;
  String? date_debut;
  String? date_fin;
  String? description;



  TontineBody({
    this.type,
    this.libelle,
    this.isPublic,
    this.nbre_personne,
    this.nbre_periode,
    this.periodicite,
    this.montant_tontine,
    this.montant_tontine_frais,
    this.frais,
    this.date_debut,
    this.date_fin,
    this.description
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["type"] = this.type;
    data["libelle"] = this.libelle;
    data["isPublic"] = this.isPublic;
    data["nbre_personne"] = this.nbre_personne;
    data["nbre_periode"] = this.nbre_periode;
    data["periodicite"] = this.periodicite;
    data["montant_tontine"] = this.montant_tontine;
    data["montant_tontine_frais"] = this.montant_tontine_frais;
    data["frais"] = this.frais;
    data["date_debut"] = this.date_debut;
    data["date_fin"] = this.date_fin;
    data["description"] = this.description;
    return data;
  }

}

