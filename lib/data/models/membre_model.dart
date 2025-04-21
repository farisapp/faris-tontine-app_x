
class Membre {
  int? id;
  String? telephone;
  String? displayName;
  int? ordre;
  String? avatar;
  bool selected = false;
  DateTime? createdAt;

  Membre({
    this.id,
    this.telephone,
    this.displayName,
    this.ordre,
    this.avatar,
    this.selected = false,
    this.createdAt,
  });

  Membre.fromJson(Map<String, dynamic> json){
    this.id = json['id'];
    this.telephone = json['telephone'];
    this.displayName = json['displayName'];
    this.ordre = json['ordre'] != null ? int.parse(json['ordre'].toString()) : 0;
    this.avatar = json['avatar'];
    this.selected = json['selected'] != null ? json['selected'] : false;
    this.createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
  }

  toJson(){
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['telephone'] = this.telephone;
    data['displayName'] = this.displayName;
    data['ordre'] = this.ordre;
    data['avatar'] = this.avatar;
    data['createdAt'] = this.createdAt;
    return data;
  }

  @override
  String toString() {
    return 'Membre{id: $id, telephone: $telephone, displayName: $displayName, ordre: $ordre, avatar: $avatar, selected: $selected, createdAt: $createdAt}';
  }
}

List<Membre> membresFromJson(List<dynamic> maps) =>
    List.generate(maps.length, (i){
      return Membre.fromJson(maps[i]);
    });