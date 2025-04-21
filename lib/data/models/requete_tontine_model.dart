
import 'package:faris/data/models/membre_model.dart';
import 'package:faris/data/models/tontine_model.dart';

class RequeteTontine {

  int? id;
  Membre? user;
  Tontine? tontine;
  String? statut;
  DateTime? createdAt;

  RequeteTontine(
      {this.id, this.user, this.tontine, this.statut, this.createdAt});


  RequeteTontine.fromJson(Map<String, dynamic> json) {
    this.id = json['id'];
    this.user = json['user'] != null ? Membre.fromJson(json['user']) : null;
    this.tontine = json['tontine'] != null ? Tontine.fromJson(json['tontine']) : null;
    this.statut = json['statut'];
    this.createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'user': this.user,
      'tontine': this.tontine,
      'statut': this.statut,
    };
  }

  @override
  String toString() {
    return 'RequeteTontine{id: $id, user: $user, tontine: $tontine, statut: $statut, createdAt: $createdAt}';
  }
}

List<RequeteTontine> requetesFromJson(List<dynamic> maps) =>
    List.generate(maps.length, (i){
      return RequeteTontine.fromJson(maps[i]);
    });

