
import 'package:faris/data/models/membre_model.dart';

class Periodicite {
  int? id;
  String? libelle;
  int? tontine;
  int? montantCotisation;
  Membre? preneur;
  int? isBegin;
  int? isEnd;
  int? isPaid;
  int? statut;

  Periodicite({
    this.id,
    this.libelle,
    this.tontine,
    this.preneur,
    this.isBegin,
    this.isEnd,
    this.isPaid,
    this.statut,
  });

  Periodicite.fromJson(Map<String, dynamic> json){
    this.id = json['id'];
    this.libelle = json['libelle'];
    this.tontine = json['tontine'] != null ? int.parse(json['tontine'].toString()) : 0;
    this.montantCotisation = json['montantCotisation'] != null ? int.parse(json['montantCotisation'].toString()) : 0;
    this.preneur = json['preneur'] != null ? Membre.fromJson(json['preneur']) : null;
    this.isBegin = json['isBegin'] != null ? int.parse(json['isBegin'].toString()) : 0;
    this.isEnd = json['isEnd'] != null ? int.parse(json['isEnd'].toString()) : 0;
    this.isPaid = json['isPaid'] != null ? int.parse(json['isPaid'].toString()) : 0;
    this.statut = json['statut'] != null ? int.parse(json['statut'].toString()) : 0 ;
  }

  toJson(){
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['libelle'] = this.libelle;
    data['tontine'] = this.tontine;
    data['montantCotisation'] = this.montantCotisation;
    data['preneur'] = this.preneur;
    data['isBegin'] = this.isBegin;
    data['isEnd'] = this.isEnd;
    data['isPaid'] = this.isPaid;
    data['statut'] = this.statut;
    return data;
  }

  @override
  String toString() {
    return 'Periodicite{id: $id, libelle: $libelle, tontine: $tontine, montantCotisation: $montantCotisation, preneur: $preneur, isBegin: $isBegin, isEnd: $isEnd, isPaid: $isPaid, statut: $statut}';
  }
}

List<Periodicite> periodicitesFromJson(List<dynamic> maps) =>
    List.generate(maps.length, (i){
      return Periodicite.fromJson(maps[i]);
    });