
class UserTontineEtat {

  int? id;
  String? libelle;
  int? paidByUser;

  UserTontineEtat(
      {this.id, this.libelle, this.paidByUser});


  UserTontineEtat.fromJson(Map<String, dynamic> json) {
    this.id = json['id'];
    this.libelle = json['libelle'];
    this.paidByUser = json['paidByUser'] != null ? int.parse(json['paidByUser'].toString()) : 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'libelle': this.libelle,
      'paidByUser': this.paidByUser,
    };
  }

  @override
  String toString() {
    return 'UserTontineEtat{id: $id, libelle: $libelle, paidByUser: $paidByUser}';
  }
}

List<UserTontineEtat> userTontineEtatFromJson(List<dynamic> maps) =>
    List.generate(maps.length, (i){
      return UserTontineEtat.fromJson(maps[i]);
    });