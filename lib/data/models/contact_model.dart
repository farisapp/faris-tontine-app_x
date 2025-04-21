
class ContactModel {
  String? id;
  String? nom;
  String prenom;
  String? avatar;
  String telephone;

  ContactModel({this.id, this.nom, required this.prenom, this.avatar, required this.telephone});


}