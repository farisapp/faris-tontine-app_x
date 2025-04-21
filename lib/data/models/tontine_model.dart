import 'package:faris/data/models/membre_model.dart';

class TontineModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<Tontine>? tontines;

  TontineModel({this.totalSize, this.limit, this.offset, this.tontines});

  TontineModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['tontines'] != null) {
      tontines = List<Tontine>.from(
        json['tontines'].map((tontine) => Tontine.fromJson(tontine)),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'total_size': totalSize,
      'limit': limit,
      'offset': offset,
      'tontines': tontines?.map((tontine) => tontine.toJson()).toList(),
    };
  }
}

class Tontine {
  int? id;
  String? numero;
  String? libelle;
  bool isPublic;
  String? type;
  String? periodicite;
  int nbrePersonne;
  int nbrePeriode;
  int totalPeriod;
  int montantTotalTontine;
  int montantTontine;
  int montantTontineFrais;
  int totalMontantCotise;
  int totalMontantRamassage;
  int totalMontantRestant;
  int frais;
  int montantRetire; // 👈 Nouveau champ ajouté
  String? description;
  DateTime? createdAt;
  DateTime? dateDebut;
  DateTime? dateFin;
  Membre? createur;
  List<Membre>? membres;
  int? hasPayment;
  String? statut;
  bool isBlocked;

  Tontine({
    this.id,
    this.libelle,
    this.numero,
    this.isPublic = false,
    this.type,
    this.periodicite,
    this.nbrePersonne = 0,
    this.nbrePeriode = 0,
    this.totalPeriod = 0,
    this.montantTotalTontine = 0,
    this.montantTontine = 0,
    this.montantTontineFrais = 0,
    this.totalMontantCotise = 0,
    this.totalMontantRamassage = 0,
    this.totalMontantRestant = 0,
    this.frais = 0,
    this.montantRetire = 0, // initialisation locale par défaut à zéro
    this.description,
    this.createdAt,
    this.dateDebut,
    this.dateFin,
    this.createur,
    this.membres,
    this.hasPayment,
    this.statut,
    this.isBlocked = false, // ✅ valeur par défaut
  });

  Tontine.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        numero = json['numero'],
        libelle = json['libelle'],
        isPublic = json['isPublic'] == true || json['isPublic'] == 1,
        type = json['type'],
        periodicite = json['periodicite'],
        nbrePersonne = (json['nbrePersonne'] ?? 0) as int,
        nbrePeriode = (json['nbrePeriode'] ?? 0) as int,
        totalPeriod = (json['totalPeriod'] ?? 0) as int,
        montantTotalTontine = (json['montantTotalTontine'] ?? 0) as int,
        montantTontine = (json['montantTontine'] ?? 0) as int,
        montantTontineFrais = (json['montantTontineFrais'] ?? 0) as int,
        totalMontantCotise = (json['totalMontantCotise'] ?? 0) as int,
        totalMontantRamassage = (json['totalMontantRamassage'] ?? 0) as int,
        isBlocked = json['isBlocked'] == true || json['isBlocked'] == 1,
      totalMontantRestant = (json['totalMontantRestant'] ?? 0) as int,
        frais = (json['frais'] ?? 0) as int,
        montantRetire = (json['montantRetire'] ?? 0) as int,
        description = json['description'],
        createdAt = json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        dateDebut = json['dateDebut'] != null
            ? DateTime.parse(json['dateDebut'])
            : null,
        dateFin =
        json['dateFin'] != null ? DateTime.parse(json['dateFin']) : null,
        createur = json['createur'] != null
            ? Membre.fromJson(json['createur'])
            : null,
        membres = json['membres'] != null
            ? List<Membre>.from(
          json['membres'].map((membre) => Membre.fromJson(membre)),
        )
            : null,
        hasPayment = (json['hasPayment'] ?? 0) as int,
        statut = json['statut'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero': numero,
      'libelle': libelle,
      'isPublic': isPublic,
      'type': type,
      'periodicite': periodicite,
      'nbrePersonne': nbrePersonne,
      'nbrePeriode': nbrePeriode,
      'totalPeriod': totalPeriod,
      'montantTotalTontine': montantTotalTontine,
      'montantTontine': montantTontine,
      'montantTontineFrais': montantTontineFrais,
      'totalMontantCotise': totalMontantCotise,
      'totalMontantRamassage': totalMontantRamassage,
      'isBlocked': isBlocked,
      'totalMontantRestant': totalMontantRestant,
      'frais': frais,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'dateDebut': dateDebut?.toIso8601String(),
      'dateFin': dateFin?.toIso8601String(),
      'createur': createur?.toJson(),
      'membres': membres?.map((membre) => membre.toJson()).toList(),
      'hasPayment': hasPayment,
      'statut': statut,
    };
  }

  @override
  String toString() {
    return 'Tontine{id: $id, numero: $numero, libelle: $libelle, isPublic: $isPublic, type: $type, periodicite: $periodicite, nbrePersonne: $nbrePersonne, totalPeriod: $totalPeriod, montantTotalTontine: $montantTotalTontine, montantTontine: $montantTontine, montantTontineFrais: $montantTontineFrais, totalMontantCotise: $totalMontantCotise, totalMontantRamassage: $totalMontantRamassage, totalMontantRestant: $totalMontantRestant, frais: $frais, description: $description, createdAt: $createdAt, dateDebut: $dateDebut, dateFin: $dateFin, createur: $createur, membres: $membres, hasPayment: $hasPayment, statut: $statut}';
  }
}

// Fonction pour convertir une liste de JSON en liste de Tontines
List<Tontine> tontinesFromJson(List<dynamic> maps) {
  return List<Tontine>.from(
    maps.map((map) => Tontine.fromJson(map)),
  );
}
