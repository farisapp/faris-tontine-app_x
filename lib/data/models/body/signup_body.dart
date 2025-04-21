class SignUpBody {
  String? nom;
  String? prenom;
  String? telephone;
  String? email;
  String? password;
  String? cm_firebase_token;

  SignUpBody({
    this.nom,
    this.prenom,
    this.email,
    this.telephone,
    this.password,
    this.cm_firebase_token
  });


  SignUpBody.fromJson(Map<String, dynamic> json){
    nom = json['nom'];
    prenom = json['prenom'];
    email = json['email'];
    telephone = json['telephone'];
    password = json['password'];
    cm_firebase_token = json['cm_firebase_token'];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["nom"] = this.nom;
    data["prenom"] = this.prenom;
    data["telephone"] = this.telephone;
    data["email"] = this.email;
    data["password"] = this.password;
    data["cm_firebase_token"] = this.cm_firebase_token;
    return data;
  }

  @override
  String toString() {
    return 'SignUpBody{nom: $nom, prenom: $prenom, telephone: $telephone, email: $email, password: $password, cm_firebase_token: $cm_firebase_token}';
  }
}

