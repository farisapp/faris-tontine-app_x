
import 'package:faris/data/models/membre_model.dart';
import 'package:faris/data/models/periodicite_model.dart';

class Cotisation {
  int? id;
  String? transId;
  String? provider;
  String? providerTransId;
  String? telephone;
  int? tontine;
  Membre? membre;
  Periodicite? periode;
  int? montant;
  String? statut;
  DateTime? createdAt;

  Cotisation({
    this.id,
    this.transId,
    this.provider,
    this.providerTransId,
    this.telephone,
    this.tontine,
    this.membre,
    this.periode,
    this.montant,
    this.statut,
    this.createdAt,
  });

  Cotisation.fromJson(Map<String, dynamic> json){
    this.id = json['id'];
    this.transId = json['transId'];
    this.provider = json['provider'];
    this.providerTransId = json['providerTransId'];
    this.telephone = json['telephone'];
    this.tontine = json['tontine'] != null ? int.parse(json['tontine'].toString()) : 0;
    this.membre = json['membre'] != null ? Membre.fromJson(json['membre']) : null;
    this.periode = json['periode'] != null ? Periodicite.fromJson(json['periode']) : null;
    this.montant = json['montant'] != null ? int.parse(json['montant'].toString()) : 0;
    this.statut = json['statut'];
    this.createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
  }

  toJson(){
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['transId'] = this.transId;
    data['provider'] = this.provider;
    data['providerTransId'] = this.providerTransId;
    data['telephone'] = this.telephone;
    data['tontine'] = this.tontine;
    data['membre'] = this.membre;
    data['periode'] = this.periode;
    data['montant'] = this.montant;
    data['statut'] = this.statut;
    data['createdAt'] = this.createdAt;
    return data;
  }

  @override
  String toString() {
    return 'Cotisation{id: $id, transId: $transId, provider: $provider, providerTransId: $providerTransId, telephone: $telephone, tontine: $tontine, membre: $membre, periode: $periode, montant: $montant, statut: $statut, createdAt: $createdAt}';
  }
}

List<Cotisation> cotisationsFromJson(List<dynamic> maps) =>
    List.generate(maps.length, (i){
      return Cotisation.fromJson(maps[i]);
    });