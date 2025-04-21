
class User {
  int? id;
  String? nom;
  String? prenom;
  String? telephone;
  String? displayName;
  String? avatar;
  String? email;
  String? password;
  int? isMemberCount;
  int? hasTontineCount;
  int? farisPayCount;
  DateTime? createdAt;

  User({
      this.id,
      this.nom,
      this.prenom,
      this.telephone,
      this.displayName,
      this.avatar,
      this.email,
      this.isMemberCount,
      this.hasTontineCount,
      this.farisPayCount,
      this.createdAt,
      });

  User.fromJson(Map<String, dynamic> json){
    this.id = json['id'];
    this.nom = json['nom'];
    this.prenom = json['prenom'];
    this.telephone = json['telephone'];
    this.displayName = json['displayName'];
    this.avatar = json['avatar'];
    this.email = json['email'];
    this.isMemberCount = json['isMemberCount'] != null ? int.parse(json['isMemberCount'].toString()) : 0;
    this.hasTontineCount = json['hasTontineCount']  != null ? int.parse(json['hasTontineCount'].toString()) : 0;
    this.farisPayCount = json['farisPayCount']  != null ? int.parse(json['farisPayCount'].toString()) : 0;
    this.createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
  }

  toJson(){
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nom'] = this.nom;
    data['prenom'] = this.prenom;
    data['telephone'] = this.telephone;
    data['displayName'] = this.displayName;
    data['avatar'] = this.avatar;
    data['email'] = this.email;
    data['isMemberCount'] = this.isMemberCount;
    data['hasTontineCount'] = this.hasTontineCount;
    data['farisPayCount'] = this.farisPayCount;
    data['createdAt'] = this.createdAt;
    return data;
  }


  @override
  String toString() {
    return 'User{id: $id, nom: $nom, prenom: $prenom, telephone: $telephone, displayName: $displayName, avatar: $avatar, email: $email, password: $password, isMemberCount: $isMemberCount, hasTontineCount: $hasTontineCount, farisPayCount: $farisPayCount, createdAt: $createdAt}';
  }

  List<User> usersFromJson(List<dynamic> maps) =>
      List.generate(maps.length, (i){
        return User.fromJson(maps[i]);
      });
}