import 'dart:io';

import 'package:faris/Livraison/rider_login_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter/services.dart';
import 'package:faris/controller/cotiser_controller.dart';
import 'package:faris/data/models/body/cotiser_body.dart';
import 'package:faris/controller/user_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/ussd_helper.dart';
import 'courses_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_selection_page.dart';


class FindCourierPage extends StatefulWidget {
  @override
  _FindCourierPageState createState() => _FindCourierPageState();
}

class _FindCourierPageState extends State<FindCourierPage> {
  final _formKey = GlobalKey<FormState>();
  final int _tontineId = 3161;
  final int _periodeId = 44635;
  bool _isRechercheParQuartier = false;
  double? latitude;
  double? longitude;
  List<dynamic> _livreursPayees = [];
  bool _isFromGps = false;
  String? quartierOrigineCarte;
  LatLng? positionCarte; // position sélectionnée sur la carte
  final TextEditingController _quartierOrigineController = TextEditingController();
  LatLng? positionDestinationCarte;
  String? quartierDestinationCarte;
  final TextEditingController _quartierDestinationController = TextEditingController();
  double _rayonRecherche = 15.0; // Rayon initial en km
  PageController _pageController = PageController();
  int _currentStep = 0;

// Ajoute cette variable dans ta classe _FindCourierPageState
  String? selectedTypeColis;
  final List<String> typesColis = [
    "Document",
    "Repas",
    "Petit colis",
    "Colis moyen",
    "Gros colis",
    "Gaz",
    "Pharmacie",
    "Super marché",
    "Fragile",
    "Autres courses diverses",
  ];

  // Variables pour récupérer les villes et quartiers via l'API
  List<String> villesFromApi = [];
  Map<String, List<String>> quartiersFromApi = {};
  bool isLoadingCities = true;

  // Champs du formulaire de recherche
  String? villeOrigine, quartierOrigine, villeDestination, quartierDestination;
  final descriptionController = TextEditingController();
  final TextEditingController _phonePassagerController = TextEditingController();
  bool _isLoading = false;
  List<String> quartiersOrigine = [], quartiersDestination = [];
  Position? lastKnownPosition;

  // Champs et variables pour le paiement
  final TextEditingController _paymentPhoneController = TextEditingController();
  final TextEditingController _paymentCodeController = TextEditingController();
  final List<Map<String, String>> _providers = [
    {
      "libelle": "Orange Money",
      "slug": "orange money",
      "logo": "assets/images/orange_money.png",
    },
    {
      "libelle": "Moov Money",
      "slug": "moov money",
      "logo": "assets/images/moov_money.png",
    },
  ];
  String _selectedProvider = "orange money";
  bool _isProcessingPayment = false;

  /// Montant fixe à payer pour consulter la liste
  double getPaymentAmount() {
    return 295.0;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(); // 🔥 Important
    _getCurrentPosition();
    fetchVillesQuartiers();
    final userController = Get.find<UserController>();
    final String userId = userController.userInfo?.id.toString() ?? "1";
    if (userId == null) {
      print("❌ [DEBUG] L'utilisateur n'est pas encore connecté ou userInfo est null");
    } else {
      print("✅ [DEBUG] ID utilisateur trouvé: $userId");
    }
  }
  double? getEstimatedDistanceKm() {
    if (positionCarte != null && positionDestinationCarte != null) {
      final distanceMeters = Geolocator.distanceBetween(
        positionCarte!.latitude,
        positionCarte!.longitude,
        positionDestinationCarte!.latitude,
        positionDestinationCarte!.longitude,
      );
      return distanceMeters / 1000; // en km
    }
    return null;
  }

  int? getEstimatedCostF() {
    final km = getEstimatedDistanceKm();
    if (km != null) {
      if (km <= 3) {
        return 500;
      } else if (km <= 5) {
        return 750;
      } else if (km <= 7) {
        return 1000;
      } else {
        final extraKm = km - 7;
        return 1000 + (extraKm * 100).ceil(); // Ajout de 100 F par km au-delà de 7
      }
    }
    return null;
  }
  Widget buildCenteredImageMapButton({
    required String label,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min, // important pour centrage
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<LatLng?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return null;
      }
    }

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return LatLng(position.latitude, position.longitude);
  }

  Future<Map<String, String>> getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        String city = place.locality ?? "Ville inconnue";
        // Ici, on tente de récupérer le quartier par subLocality, sinon subAdministrativeArea ou name
        String neighborhood = place.subLocality ??
            place.subAdministrativeArea ??
            place.name ??
            "Quartier inconnu";
        return {'ville': city, 'quartier': neighborhood};
      } else {
        return {'ville': "Ville inconnue", 'quartier': "Quartier inconnu"};
      }
    } catch (e) {
      print("Erreur lors de la géocodification inverse: $e");
      return {'ville': "Ville inconnue", 'quartier': "Quartier inconnu"};
    }
  }


  void _showLivreursDialog(List livreurs) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text("Livreurs disponibles", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: livreurs.length,
            itemBuilder: (_, index) {
              var livreur = livreurs[index];
              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo + statuts
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: livreur['photo_profil'] != null && livreur['photo_profil'].isNotEmpty
                                ? NetworkImage(livreur['photo_profil'])
                                : AssetImage('assets/images/default_avatar.png') as ImageProvider,
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.diamond,
                                  color: livreur['isVerified'] == 1 ? Colors.green : Colors.grey, size: 16),
                              SizedBox(width: 4),
                              Text(
                                livreur['isVerified'] == 1 ? "Vérifié" : "Non vérifié",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: livreur['isVerified'] == 1 ? Colors.green : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: livreur['status'] == 1 ? Colors.green.shade100 : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  livreur['status'] == 1 ? Icons.check_circle : Icons.cancel,
                                  color: livreur['status'] == 1 ? Colors.green : Colors.grey,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  livreur['status'] == 1 ? "Actif" : "Non Actif",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: livreur['status'] == 1 ? Colors.green : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(livreur['prenom'] ?? "Nom inconnu",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 4),
                            if (livreur['note'] != null &&
                                livreur['note'].toString().isNotEmpty &&
                                double.tryParse(livreur['note'].toString()) != null)
                              Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 18),
                                  SizedBox(width: 4),
                                  Text(
                                    "${double.parse(livreur['note'].toString()).toStringAsFixed(1)} / 5",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  Icon(Icons.star_border, color: Colors.grey, size: 18),
                                  SizedBox(width: 4),
                                  Text(
                                    "Pas encore noté",
                                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                                  ),
                                ],
                              ),
                            SizedBox(height: 4),
                            Text(
                              "${livreur['ville'] ?? 'Ville inconnue'} - ${livreur['quartiers'] ?? ''}",
                              style: TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final customId = Get.find<UserController>().userInfo?.id?.toString() ?? "PASSAGER001";
                    final originVilleSafe = villeOrigine ?? "Inconnue";
                    final originQuartierSafe = quartierOrigine ?? "Inconnu";
                    final destinationVilleSafe = villeDestination ?? "Inconnue";
                    final destinationQuartierSafe = quartierDestination?.isNotEmpty == true ? quartierDestination! : "Inconnu";
                    final sourceGps = _isFromGps;

                    if (originVilleSafe == null || originQuartierSafe == null) {
                      Get.snackbar("Erreur", "Veuillez remplir la ville et le quartier d'origine.");
                      return;
                    }

                    await createCourse(
                      customId: customId,
                      originVille: originVilleSafe,
                      originQuartier: originQuartierSafe,
                      destinationVille: destinationVilleSafe,
                      destinationQuartier: destinationQuartierSafe,
                      description: descriptionController.text,
                      isGpsBased: sourceGps,
                      latitude: positionCarte?.latitude,
                      longitude: positionCarte?.longitude,
                      latitudeDestination: positionDestinationCarte?.latitude,
                      longitudeDestination: positionDestinationCarte?.longitude,
                      typeColis: selectedTypeColis ?? "Non précisé",
                      prixEstime: getEstimatedCostF()?.toString() ?? "0",
                    );




                    await _sendNotification(livreurs);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: Size(double.infinity, 40),
                  ),
                  child: Text("Demander une course", style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    minimumSize: Size(double.infinity, 40),
                  ),
                  child: Text("Fermer", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }


  Future<Position?> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Erreur', 'La localisation est désactivée sur votre appareil.');
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Erreur', 'Permission de localisation refusée.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Erreur', 'Permission refusée définitivement.');
      return null;
    }

    lastKnownPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return lastKnownPosition;
  }


  /// Récupère les villes et les quartiers via l'API.
  Future<void> fetchVillesQuartiers() async {
    try {
      final response = await http.get(Uri.parse("https://apps.farisbusinessgroup.com/api/Livraison/get_villes_quartiers.php"));
      final data = jsonDecode(response.body);
      if (data['success']) {
        final List listData = data['data'];
        setState(() {
          villesFromApi = listData.map((v) => v['nom'].toString()).toList();

          // Option : ajouter l’élément "Autre" pour autoriser une saisie manuelle
          if (!villesFromApi.contains("Autre")) {
            villesFromApi.add("Autre");
          }

          quartiersFromApi = {
            for (var v in listData) v['nom']: List<String>.from(v['quartiers'])
          };

          // Par défaut, sélectionnez la première ville (souvent "Ouagadougou")
          if (villesFromApi.isNotEmpty) {
            villeOrigine = villesFromApi.first;
            villeDestination = villeOrigine;
            quartiersOrigine = quartiersFromApi[villeOrigine] ?? [];
            quartiersDestination = quartiersFromApi[villeOrigine] ?? [];
          }
          isLoadingCities = false;
        });
      } else {
        setState(() => isLoadingCities = false);
        print("Erreur API: ${data['message']}");
      }
    } catch (e) {
      setState(() => isLoadingCities = false);
      print("Exception: $e");
    }
  }


  /// Appel à l'API pour trouver les livreurs
  Future<void> _findCourier() async {
    // On indique que nous sommes en mode "Recherche par quartier"
    _isRechercheParQuartier = true;

    // Valide tous les champs du formulaire
    if (!_formKey.currentState!.validate()) return;

    // SI le quartier d'origine n'est pas renseigné,
    // afficher une erreur et revenir à l'étape 1
    if (quartierOrigine == null || quartierOrigine!.trim().isEmpty) {
      Get.snackbar(
        "Erreur",
        "Veuillez renseigner le quartier d'origine.",
        snackPosition: SnackPosition.BOTTOM,
      );
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      return;
    }

    // Traitement du champ destination (si vide, on affecte "Inconnue")
    if (quartierDestination == null || quartierDestination!.isEmpty) {
      quartierDestination = "Inconnue";
    }

    setState(() => _isLoading = true);

    // Appel à l'API avec les paramètres validés
    final response = await http.post(
      Uri.parse('https://apps.farisbusinessgroup.com/api/Livraison/find_courier.php'),
      body: {
        'ville_origine': villeOrigine!,
        'quartier_origine': quartierOrigine!,
        'ville_destination': villeDestination!,
        'quartier_destination': quartierDestination ?? "Inconnue",
        'description': descriptionController.text,
      },
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        List livreurs = data['livreurs'];
        livreurs.sort((a, b) => (b['status'] ?? 0).compareTo(a['status'] ?? 0));
        if (livreurs.isNotEmpty) {
          _showIntermediaireDialog(livreurs);
        } else {
          Get.snackbar(
            'Aucun livreur trouvé',
            'Aucun livreur n\'a été trouvé pour ces critères.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            titlePadding: EdgeInsets.only(top: 20),
            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            title: Column(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
                SizedBox(height: 10),
                Text(
                  "Aucun livreur trouvé",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 16),
                Text(
                  "Aucun livreur trouvé dans le quartier d'origine du colis, Vous pouvez élargir la recherche à toute la ville.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text("Annuler", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  _findCourierElargie();
                },
                icon: Icon(Icons.search),
                label: Text("Élargir la recherche"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        );
      }
    } else {
      Get.snackbar('Erreur', 'Une erreur réseau est survenue.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _findCourierElargie() async {
    setState(() => _isLoading = true);
    final response = await http.post(
      Uri.parse('https://apps.farisbusinessgroup.com/api/Livraison/find_courier.php'),
      body: {
        'ville_origine': villeOrigine!,
        'quartier_origine': '', // quartier vide pour élargir la recherche
        'ville_destination': villeDestination!,
        'quartier_destination': quartierDestination!,
        'description': descriptionController.text,
      },
    );
    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        List livreurs = data['livreurs'];
        livreurs.sort((a, b) => (b['status'] ?? 0).compareTo(a['status'] ?? 0));
        if (livreurs.isNotEmpty) {
          _showIntermediaireDialog(livreurs);
        } else {
          Get.snackbar('Aucun livreur trouvé', 'Même avec une recherche élargie, aucun livreur n\'a été trouvé.', snackPosition: SnackPosition.BOTTOM);
        }
      } else {
        Get.snackbar('Erreur', data['message'], snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      Get.snackbar('Erreur', 'Une erreur réseau est survenue.', snackPosition: SnackPosition.BOTTOM);
    }
  }
  void _showIntermediaireDialogGps(List livreurs) {
    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text("Livreurs proches de vous", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${livreurs.length} livreur(s) trouvé(s) dans un rayon de ${_rayonRecherche.toStringAsFixed(1)} km.",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Slider(
                  value: _rayonRecherche,
                  min: 10.0,
                  max: 50.0,
                  divisions: 19,
                  label: "${_rayonRecherche.toStringAsFixed(1)} km",
                  onChanged: (value) {
                    setState(() {
                      _rayonRecherche = value;
                    });
                  },
                  onChangeEnd: (value) async {
                    final position = await _getCurrentPosition();
                    if (position != null) {
                      _findCourierByLocation(position.latitude, position.longitude);
                    }
                  },
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: livreurs.length,
                    itemBuilder: (_, index) {
                      var livreur = livreurs[index];
                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage: livreur['photo_profil'] != null && livreur['photo_profil'].isNotEmpty
                                        ? NetworkImage(livreur['photo_profil'])
                                        : AssetImage('assets/images/default_avatar.png') as ImageProvider,
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.diamond,
                                          color: livreur['isVerified'] == 1 ? Colors.green : Colors.grey,
                                          size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        livreur['isVerified'] == 1 ? "Vérifié" : "Non vérifié",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: livreur['isVerified'] == 1 ? Colors.green : Colors.grey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: livreur['status'] == 1 ? Colors.green.shade100 : Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          livreur['status'] == 1 ? Icons.check_circle : Icons.cancel,
                                          color: livreur['status'] == 1 ? Colors.green : Colors.grey,
                                          size: 14,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          livreur['status'] == 1 ? "Actif" : "Non Actif",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: livreur['status'] == 1 ? Colors.green : Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(livreur['prenom'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    SizedBox(height: 4),
                                    if (livreur['note'] != null &&
                                        livreur['note'].toString().isNotEmpty &&
                                        double.tryParse(livreur['note'].toString()) != null)
                                      Row(
                                        children: [
                                          Icon(Icons.star, color: Colors.amber, size: 18),
                                          SizedBox(width: 4),
                                          Text(
                                            "${double.parse(livreur['note'].toString()).toStringAsFixed(1)} / 5",
                                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                                          ),
                                        ],
                                      )
                                    else
                                      Row(
                                        children: [
                                          Icon(Icons.star_border, color: Colors.grey, size: 18),
                                          SizedBox(width: 4),
                                          Text("Pas encore noté", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                                        ],
                                      ),
                                    SizedBox(height: 4),
                                    Text("${livreur['ville'] ?? 'Ville inconnue'} - ${livreur['quartiers'] ?? ''}",
                                        style: TextStyle(fontSize: 14, color: Colors.black87)),
                                    if (livreur['distance_km'] != null)
                                      Text("Distance : ${livreur['distance_km']} km",
                                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Get.back(); // Fermer la boîte de dialogue
                setState(() {
                  _livreursPayees = livreurs;
                  _isFromGps = true;
                });
                _showPaymentDialog(livreurs, sourceGps: true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              icon: Icon(Icons.directions_bike),
              label: Text("Envoyer une demande aux livreurs proches", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: Text("Fermer", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }


  /// Boîte de dialogue intermédiaire affichant les livreurs disponibles
  void _showIntermediaireDialog(List livreurs) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text("Livreurs disponibles", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${livreurs.length} livreur(s) trouvé(s) à proximité du point de départ de votre course.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: livreurs.length,
                  itemBuilder: (_, index) {
                    var livreur = livreurs[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 📷 Photo + statuts
                            Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: livreur['photo_profil'] != null && livreur['photo_profil'].isNotEmpty
                                      ? NetworkImage(livreur['photo_profil'])
                                      : AssetImage('assets/images/default_avatar.png') as ImageProvider,
                                ),
                                SizedBox(height: 8),

                                // ✅ Label "Vérifié / Non vérifié" à ajouter ici :
                                Row(
                                  children: [
                                    Icon(Icons.diamond,
                                        color: livreur['isVerified'] == 1 ? Colors.green : Colors.grey,
                                        size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      livreur['isVerified'] == 1 ? "Vérifié" : "Non vérifié",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: livreur['isVerified'] == 1 ? Colors.green : Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 4),

                                // Statut Actif / Non Actif
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: livreur['status'] == 1 ? Colors.green.shade100 : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        livreur['status'] == 1 ? Icons.check_circle : Icons.cancel,
                                        color: livreur['status'] == 1 ? Colors.green : Colors.grey,
                                        size: 14,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        livreur['status'] == 1 ? "Actif" : "Non Actif",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: livreur['status'] == 1 ? Colors.green : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 12),
                            // Infos du livreur
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(livreur['prenom'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  SizedBox(height: 4),

                                  // Note
                                  if (livreur['note'] != null &&
                                      livreur['note'].toString().isNotEmpty &&
                                      double.tryParse(livreur['note'].toString()) != null)
                                    Row(
                                      children: [
                                        Icon(Icons.star, color: Colors.amber, size: 18),
                                        SizedBox(width: 4),
                                        Text(
                                          "${double.parse(livreur['note'].toString()).toStringAsFixed(1)} / 5",
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                                        ),
                                      ],
                                    )
                                  else
                                    Row(
                                      children: [
                                        Icon(Icons.star_border, color: Colors.grey, size: 18),
                                        SizedBox(width: 4),
                                        Text(
                                          "Pas encore noté",
                                          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                                        ),
                                      ],
                                    ),

                                  SizedBox(height: 4),
                                  Text(
                                    "${livreur['ville']} - ${livreur['quartiers'] ?? ''}",
                                    style: TextStyle(fontSize: 14, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              Get.back(); // Fermer la boîte de dialogue
              setState(() {
                _livreursPayees = livreurs;
                _isFromGps = true;
              });
              _showPaymentDialog(livreurs, sourceGps: true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            icon: Icon(Icons.directions_bike),
            label: Text("Envoyer une demande de course aux livreurs", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Fermer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Méthode pour afficher le ChoiceChip des opérateurs de paiement
  Widget _buildProviderChoice(StateSetter setStateDialog) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: _providers.map((provider) {
        final slug = provider['slug']!;
        final libelle = provider['libelle']!;
        return ChoiceChip(
          labelPadding: EdgeInsets.symmetric(horizontal: 6),
          label: Text(libelle, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          avatar: CircleAvatar(
            radius: 12,
            backgroundColor: Colors.white,
            child: Image.asset(provider['logo']!, width: 16, height: 16, fit: BoxFit.cover),
          ),
          backgroundColor: Colors.blueGrey,
          selectedColor: Colors.teal,
          selected: _selectedProvider == slug,
          onSelected: (value) {
            setStateDialog(() {
              _selectedProvider = slug;
            });
          },
        );
      }).toList(),
    );
  }

  /// Génère et appelle le code USSD (pour Orange Money)
  Future<void> _callNumber(String montant) async {
    try {
      if (_selectedProvider == "orange money") {
        int montantArrondi = getPaymentAmount().floor();
        String montantUssd = montantArrondi.toString();
        var number = '*144*4*6*$montantUssd#';
        await UssdHelper.launchUssd(context: context, ussdCode: number);
      }
    } catch (e) {
      Get.snackbar('Erreur', "Impossible de générer le code OTP.", snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Boîte de dialogue de paiement
  void _showPaymentDialog(List livreurs, {bool sourceGps = false}) {

    Get.dialog(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            title: Text("Paiement requis", style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Vous devez payer une commission de ${getPaymentAmount().toStringAsFixed(0)} F avant de pouvoir envoyer la demande. \n Remboursable si aucun livreur n'accepte votre course. Les frais de votre course seront discutés avec le livreur, merci!",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 5),
                  Text("Sélectionnez votre opérateur", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange)),
                  SizedBox(height: 5),
                  _buildProviderChoice(setStateDialog),
                  SizedBox(height: 5),
                  Text(_selectedProvider == "moov money" ? "Numéro Moov Money" : "Numéro Orange Money", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  TextFormField(
                    controller: _paymentPhoneController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Ex: 70000000",
                      filled: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                    ],
                  ),
                  SizedBox(height: 5),
                  if (_selectedProvider == "orange money") ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => _callNumber(getPaymentAmount().toStringAsFixed(0)),
                          child: Text("Générer le code OTP", style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: _paymentCodeController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Entrez le code OTP Orange",
                        filled: true,
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    SizedBox(height: 5),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () =>_validatePayment(livreurs, sourceGps: sourceGps),
                          style: TextButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.check_circle_outline),
                              SizedBox(width: 5),
                              Text("VALIDER"),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: TextButton(
                          onPressed: () => Get.back(),
                          style: TextButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.cancel),
                              SizedBox(width: 5),
                              Text("ANNULER"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  if (_selectedProvider == "orange money")
                    UssdHelper.buildClickableUssdWidget(
                      context: context,
                      ussdCode: '*144*4*6*${getPaymentAmount().floor()}#',
                    ),
                  /* SizedBox(height: 10),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        Get.back();
                        _showLivreursDialog(livreurs);
                      },
                      icon: Icon(Icons.visibility, color: Colors.grey),
                      label: Text("Ignorer le paiement pour le moment", style: TextStyle(color: Colors.grey)),
                    ),
                  ),*/
                ],
              ),
            ),
          );
        },
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _validatePayment(List livreurs, {bool sourceGps = false}) async {
    if (_paymentPhoneController.text.isEmpty || _paymentPhoneController.text.length != 8) {
      Get.snackbar('Erreur', 'Veuillez entrer un numéro de téléphone valide.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (_selectedProvider == "orange money" && _paymentCodeController.text.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez entrer le code OTP pour Orange Money.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() => _isProcessingPayment = true);

    Get.dialog(
      AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 5),
            Text(_selectedProvider == "orange money" ? "Paiement Orange..." : "Paiement Moov..."),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    final cotiserController = Get.find<CotiserController>();
    final montant = getPaymentAmount();

    if (_selectedProvider == "moov money") {
      cotiserController.makeRequestInitMoovOtp(
        phone: _paymentPhoneController.text.trim(),
        amount: montant.toStringAsFixed(0),
      ).then((result) async {
        Get.back();
        setState(() => _isProcessingPayment = false);
        if (result.isSuccess) {
          Navigator.pop(context);
          _buildMoovOtpConfirmSheet(result.message ?? "", livreurs, sourceGps: sourceGps);
        } else {
          Get.snackbar("Erreur", result.message ?? "Erreur Moov inconnue", snackPosition: SnackPosition.BOTTOM);
        }
      });
    } else {
      CotiserBody body = CotiserBody(
        tontine: _tontineId,
        periode: _periodeId,
        montant: montant,
        provider: "orange money",
        telephone: _paymentPhoneController.text.trim(),
        code_otp: _paymentCodeController.text.trim(),
      );

      cotiserController.cotiser(body).then((result) async {
        Get.back(); // Ferme le loader
        setState(() => _isProcessingPayment = false);

        if (result.isSuccess) {
          Navigator.pop(context); // Ferme la boîte de dialogue de paiement

          // ✅ Préparer les valeurs
          final customId = Get.find<UserController>().userInfo?.id.toString() ?? "PASSAGER001";
// Pour la ville, on utilise toujours la valeur sélectionnée par l’utilisateur
          final originVille = villeOrigine;
// Pour le quartier, si c’est un appel basé sur la localisation GPS, on garde "Coordonnées GPS"
          final originQuartier = sourceGps ? "Coordonnées GPS" : quartierOrigine;
          final destinationVilleSafe = villeDestination ?? "Inconnue";
          final destinationQuartierSafe = quartierDestination?.isNotEmpty == true ? quartierDestination! : "Inconnue";
// Une validation minimale (adaptable selon vos besoins)
          if (!sourceGps && (originVille == null || originQuartier == null)) {
            Get.snackbar("Erreur", "Ville ou quartier d'origine manquant.", snackPosition: SnackPosition.BOTTOM);
            return;
          }
// Création de la course en passant les valeurs modifiées
          await createCourse(
            customId: customId,
            originVille: originVille!,
            originQuartier: originQuartier!,
            destinationVille: destinationVilleSafe,
            destinationQuartier: destinationQuartierSafe,
            description: descriptionController.text,
            isGpsBased: sourceGps,
            latitude: positionCarte?.latitude,
            longitude: positionCarte?.longitude,
            latitudeDestination: positionDestinationCarte?.latitude,
            longitudeDestination: positionDestinationCarte?.longitude,
            typeColis: selectedTypeColis ?? "Non précisé",
            prixEstime: getEstimatedCostF()?.toString() ?? "0",
          );




          // ✅ Envoyer les notifications
          await _sendNotification(livreurs, sourceGps: sourceGps);

          // ✅ Fenêtre de confirmation
          Get.dialog(AlertDialog(
            title: Text("Demande envoyée", style: TextStyle(color: Colors.green)),
            content: Text(   "Votre demande de course a été envoyée. Un livreur prendra bientôt en charge votre course. "
                "Sinon, contactez-nous au +22674249090. Merci pour votre fidélité!",),
            actions: [
              TextButton(onPressed: () => Get.back(), child: Text("Fermer")),
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.to(() => CoursesPage());
                },
                child: Text("Voir la demande", style: TextStyle(color: Colors.orange)),
              ),
            ],
          ));
        } else {
          Get.snackbar("Erreur", result.message ?? "Paiement échoué", snackPosition: SnackPosition.BOTTOM);
        }
      });
    }
  }
  Future<void> createCourse({
    required String customId,
    required String originVille,
    required String originQuartier,
    required String destinationVille,
    required String destinationQuartier,
    required String description,
    required String typeColis,
    required String prixEstime,
    bool isGpsBased = false,
    double? latitude,
    double? longitude,
    double? latitudeDestination,
    double? longitudeDestination,
  }) async {

    final userController = Get.find<UserController>();
    final userId = userController.userInfo?.id?.toString();
    final telephonePassager = _phonePassagerController.text.trim();

    if (userId == null || userId.isEmpty) {
      Get.snackbar("Erreur", "Identifiant utilisateur introuvable.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // 🔄 Si latitude/longitude non fournis, utiliser lastKnownPosition
    double? lat = latitude;
    double? lon = longitude;

    if ((lat == null || lon == null) && lastKnownPosition != null) {
      lat = lastKnownPosition!.latitude;
      lon = lastKnownPosition!.longitude;
    }

    final payload = {
      'user_id': userId,
      'custom_id': customId,
      'origin_ville': originVille,
      'origin_quartier': originQuartier,
      'destination_ville': destinationVille,
      'destination_quartier': destinationQuartier,
      'description': description,
      'telephone_passager': telephonePassager,
      'latitude': lat?.toString(),
      'longitude': lon?.toString(),
      'latitude_destination': latitudeDestination?.toString(),  // 🔧 Ajouté
      'longitude_destination': longitudeDestination?.toString(),  // 🔧 Ajouté
      'type_colis': typeColis,
      'prix_estime': prixEstime,
    };

    print("📦 Payload envoyé à l'API : $payload");


    try {
      final response = await http.post(
        Uri.parse("https://apps.farisbusinessgroup.com/api/Livraison/create_course.php"),
        body: jsonEncode(payload),
        headers: {"Content-Type": "application/json"},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) {
        Get.snackbar("Succès", data['message'], snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar("Erreur", data['message'] ?? "Erreur inconnue", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Erreur", "Exception: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }


  void _buildMoovOtpConfirmSheet(String messageMoov, List livreurs, {bool sourceGps = false}) {
    final parts = messageMoov.split(';'); // "transId;requestId"
    final transId = parts[0];
    final reqId = parts[1];

    _paymentCodeController.text = "";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
            top: 10,
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: _buildMoovOtpForm(transId, reqId, livreurs, sourceGps: sourceGps),
          ),
        );
      },
    );
  }


  Widget _buildMoovOtpForm(String transId, String reqId, List livreurs, {bool sourceGps = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 5),
        Text(
          "Confirmation OTP (Moov)",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
        ),
        Divider(),
        TextFormField(
          controller: _paymentCodeController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Entrez le code OTP Moov",
            border: OutlineInputBorder(),
            filled: true,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => _confirmMoovPayment(transId, reqId, livreurs, sourceGps: sourceGps),
                style: TextButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                child: Text("VALIDER"),
              ),
            ),
            SizedBox(width: 5),
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: Text("ANNULER"),
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
      ],
    );
  }

  Future<void> _findCourierByLocation(double latitude, double longitude, {bool skipDialog = false}) async {
    // 🛑 Vérifie les champs obligatoires AVANT d'afficher le GIF
    if (villeOrigine == null || villeOrigine!.isEmpty) {
      Get.snackbar("Erreur", "Veuillez sélectionner une ville.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (_phonePassagerController.text.trim().isEmpty) {
      Get.snackbar("Erreur", "Veuillez renseigner votre contact téléphonique.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // ✅ Affiche l’animation de chargement SEULEMENT si les champs sont valides
    if (!skipDialog) {
      Get.dialog(
        Center(
          child: Container(
            width: 300,
            height: 300,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/search_animation.gif',
                  width: 160,
                  height: 160,
                ),
                SizedBox(height: 16),
                Text(
                  "Recherche de livreurs en cours...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,               // texte noir
                    decoration: TextDecoration.none,   // pas de soulignement
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      await Future.delayed(Duration(milliseconds: 100));
    }

    try {
      final response = await http.post(
        Uri.parse('https://apps.farisbusinessgroup.com/api/Livraison/find_courier_by_location.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'rayon': _rayonRecherche.toString(), // ✅ Envoi du rayon dynamique ici
        }),
      );

      if (!skipDialog) Get.back(); // Ferme le dialogue d'attente

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          List livreurs = data['livreurs'];
          Get.back(); // Ferme le loader si non déjà fermé
// Trier par distance croissante, puis status (actif = 1 d'abord)
          livreurs.sort((a, b) {
            final distanceA = double.tryParse(a['distance_km'].toString()) ?? double.infinity;
            final distanceB = double.tryParse(b['distance_km'].toString()) ?? double.infinity;

            // 1️⃣ Comparaison des distances
            final distanceCompare = distanceA.compareTo(distanceB);
            if (distanceCompare != 0) return distanceCompare;

            // 2️⃣ Si distance égale, comparer le statut (actif d'abord)
            final statusA = a['status'] ?? 0;
            final statusB = b['status'] ?? 0;
            return statusB.compareTo(statusA); // 1 (actif) avant 0 (inactif)
          });
          if (livreurs.isNotEmpty) {
            _showIntermediaireDialogGps(livreurs);
          } else {
            Get.snackbar("Aucun livreur trouvé", "Aucun livreur n'est proche de votre position.");
          }
        } else {
          Get.snackbar("Erreur", data['message'] ?? "Erreur inconnue.");
        }
      }
    } catch (e) {
      if (!skipDialog) Get.back();
      Get.snackbar("Erreur", "Exception : $e");
    }
  }


  void _confirmMoovPayment(String transId, String reqId, List livreurs, {bool sourceGps = false}) async {
    final otp = _paymentCodeController.text.trim();
    final customId = Get.find<UserController>().userInfo?.id.toString() ?? "PASSAGER001";
    final originVille = villeOrigine ?? "Inconnue";
    final originQuartier = _isFromGps ? "Coordonnées GPS" : quartierOrigine ?? "Inconnu";
    final destinationVilleSafe = villeDestination ?? "Inconnue";
    final destinationQuartierSafe = quartierDestination ?? "Inconnu";
    if (otp.isEmpty) {
      Get.snackbar('Erreur', "Veuillez saisir le code OTP Moov", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Affiche un dialogue de chargement pendant la confirmation OTP
    Get.dialog(
      AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 5),
            Text("Confirmation Moov..."),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    final cotiserController = Get.find<CotiserController>();

    // Création du body pour la demande de cotisation via Moov Money
    CotiserBody body = CotiserBody(
      tontine: _tontineId,
      periode: _periodeId,
      montant: getPaymentAmount(),
      provider: "moov money",
      telephone: _paymentPhoneController.text.trim(),
      code_otp: otp,
      trans_id: transId,
      request_id: reqId,
    );

    // Appel de l'API de paiement pour Moov Money
    var result = await cotiserController.cotiser(body, provider: "moov money");
    Get.back(); // Ferme le dialogue de chargement

    if (result.isSuccess) {
      Navigator.pop(context); // Ferme le bottom sheet OTP

      // Préparation des valeurs à utiliser pour la création de la course.
      // Si la demande est basée sur la localisation GPS, on force "GPS" et "Coordonnées GPS".
      final String originVilleSafe = sourceGps ? "GPS" : (villeOrigine ?? "Inconnue");
      final String originQuartierSafe = sourceGps ? "Coordonnées GPS" : (quartierOrigine ?? "Inconnu");
      final String destinationVilleSafe = villeDestination ?? "Inconnue";
      final String destinationQuartierSafe = (quartierDestination != null && quartierDestination!.isNotEmpty) ? quartierDestination! : "Inconnu";

      // Création de la course (demande de livraison)
      await createCourse(
        customId: customId,
        originVille: originVille!,
        originQuartier: originQuartier!,
        destinationVille: destinationVilleSafe,
        destinationQuartier: destinationQuartierSafe,
        description: descriptionController.text,
        isGpsBased: sourceGps,
        latitude: positionCarte?.latitude,
        longitude: positionCarte?.longitude,
        latitudeDestination: positionDestinationCarte?.latitude,
        longitudeDestination: positionDestinationCarte?.longitude,
        typeColis: selectedTypeColis ?? "Non précisé",
        prixEstime: getEstimatedCostF()?.toString() ?? "0",
      );



      // Envoi de la notification aux livreurs sélectionnés
      await _sendNotification(livreurs, sourceGps: sourceGps);

      // Affichage d'un dialogue de confirmation indiquant que la demande a bien été envoyée.
      Get.dialog(
          AlertDialog(
            title: Text("Demande envoyée", style: TextStyle(color: Colors.green)),
            content: Text(
              "Votre demande de course a été envoyée. Un livreur prendra bientôt en charge votre course. "
                  "Sinon, contactez-nous au +22674249090. Merci pour votre fidélité!",
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: Text("Fermer")),
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.to(() => CoursesPage());
                },
                child: Text("Voir la demande", style: TextStyle(color: Colors.orange)),
              ),
            ],
          )
      );
    } else {
      Get.snackbar("Erreur", result.message ?? "Échec du paiement", snackPosition: SnackPosition.BOTTOM);
    }
  }
  Widget _buildStep1Form() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepOrange, Colors.orange],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Détails du colis",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedTypeColis,
            items: typesColis.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                selectedTypeColis = val;
              });
            },
            decoration: _inputDecoration("Type de colis", Icons.local_shipping),
            validator: (_) => null,
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: descriptionController,
            decoration: _inputDecoration("Description du colis", Icons.description),
            // Vous pouvez fixer un nombre maximal de lignes ou le laisser évoluer :
            maxLines: 3, // ou maxLines: null pour un champ extensible
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.deepOrange, Colors.orange]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Origine du colis",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          SizedBox(height: 10),
          DropdownButtonFormField(
            value: villeOrigine,
            decoration: _inputDecoration("Choisir la ville", Icons.location_city),
            items: villesFromApi.map((v) {
              return DropdownMenuItem(
                value: v,
                child: Text(v),
              );
            }).toList(),
            onChanged: (val) async {
              if (val == "Autre") {
                final controller = TextEditingController();
                final nouvelleVille = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Saisir une nouvelle ville"),
                      content: TextField(
                        controller: controller,
                        decoration: InputDecoration(hintText: "Nom de la ville"),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, controller.text.trim()),
                          child: Text("Valider"),
                        ),
                      ],
                    );
                  },
                );
                if (nouvelleVille != null && nouvelleVille.isNotEmpty) {
                  setState(() {
                    if (!villesFromApi.contains(nouvelleVille)) {
                      villesFromApi.add(nouvelleVille);
                    }
                    villeOrigine = nouvelleVille;
                    villeDestination = nouvelleVille;
                    quartiersOrigine = [];
                    quartierOrigine = null;
                    quartiersDestination = [];
                    quartierDestination = null;
                  });
                }
              } else {
                setState(() {
                  villeOrigine = val;
                  quartiersOrigine = quartiersFromApi[villeOrigine] ?? [];
                  quartierOrigine = null;
                  villeDestination = villeOrigine;
                  quartiersDestination = quartiersFromApi[villeDestination] ?? [];
                  quartierDestination = null;
                });
              }
            },
            validator: (val) => val == null ? 'Champ obligatoire' : null,
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _quartierOrigineController,
            readOnly: true,
            onTap: () async {
              if (quartiersOrigine.isEmpty) {
                Get.snackbar("Info", "Veuillez d'abord choisir une ville", snackPosition: SnackPosition.BOTTOM);
                return;
              }
              final selected = await showDialog<String>(
                context: context,
                builder: (context) => SearchableDropdownDialog(
                  title: "Choisir un quartier de départ",
                  items: quartiersOrigine,
                ),
              );
              if (selected != null && selected.isNotEmpty) {
                setState(() {
                  quartierOrigine = selected;
                  _quartierOrigineController.text = selected;
                });
              }
            },
            validator: (value) {
              if (_isRechercheParQuartier && (value == null || value.trim().isEmpty)) {
                return 'Veuillez sélectionner un quartier de départ';
              }
              return null;
            },
            decoration: _inputDecoration("Quartier de départ du colis", Icons.home_work),
          ),
          buildCenteredImageMapButton(
            label: "Choisir sur la carte",
            imagePath: 'assets/images/map_icon_square.png',
            onTap: () async {
              final result = await Get.to(() => MapSelectionPage(title: "Choisir sur la carte"));
              if (result != null && result is Map) {
                final quartier = result['quartier'];
                final ville = result['ville'];
                final pos = result['position'];
                if (pos != null && pos is LatLng) {
                  setState(() {
                    positionCarte = pos;
                    if (ville != null && ville.isNotEmpty) {
                      villeOrigine = ville;
                      villeDestination = ville;
                      quartiersOrigine = quartiersFromApi[villeOrigine] ?? [];
                      quartiersDestination = quartiersFromApi[villeDestination] ?? [];
                    }
                    if (quartier != null && quartier.isNotEmpty) {
                      if (!quartiersOrigine.contains(quartier)) {
                        quartiersOrigine.add(quartier);
                      }
                      quartierOrigine = quartier;
                      _quartierOrigineController.text = quartier;
                    } else {
                      final coords = "${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}";
                      quartierOrigine = coords;
                      _quartierOrigineController.text = coords;
                      if (!quartiersOrigine.contains(coords)) {
                        quartiersOrigine.add(coords);
                      }
                    }
                  });
                  Get.snackbar(
                    "Position sélectionnée",
                    "Ville : ${ville ?? "Inconnue"}\nQuartier : ${quartierOrigine ?? "Coordonnées GPS"}",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              }
            },
          ),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.lightGreen],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                    setState(() => _currentStep = 1);
                  }
                },
                icon: Icon(Icons.arrow_forward, color: Colors.white),
                label: Text(
                  "Continuer",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, // Permet d'afficher le dégradé du Container
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  Widget _buildStep2Form() {
    final distance = getEstimatedDistanceKm();
    final cost = getEstimatedCostF();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Partie scrollable pour le contenu du formulaire (destination, téléphone, estimation, etc.)
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.deepOrange, Colors.orange]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Destination du colis",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _quartierDestinationController,
                  readOnly: true,
                  onTap: () async {
                    if (quartiersDestination.isEmpty) {
                      Get.snackbar("Info", "Veuillez d'abord choisir une ville", snackPosition: SnackPosition.BOTTOM);
                      return;
                    }
                    final selected = await showDialog<String>(
                      context: context,
                      builder: (context) => SearchableDropdownDialog(
                        title: "Choisir un quartier de destination",
                        items: quartiersDestination,
                      ),
                    );
                    if (selected != null && selected.isNotEmpty) {
                      setState(() {
                        quartierDestination = selected;
                        _quartierDestinationController.text = selected;
                      });
                    }
                  },
                  decoration: _inputDecoration("Quartier de destination du colis", Icons.home_work),
                ),
                buildCenteredImageMapButton(
                  label: "Choisir sur la carte",
                  imagePath: 'assets/images/map_icon_square.png',
                  onTap: () async {
                    final result = await Get.to(() => MapSelectionPage(title: "Choisir sur la carte"));
                    if (result != null && result is Map) {
                      final quartier = result['quartier'];
                      final ville = result['ville'];
                      final pos = result['position'];
                      if (pos != null && pos is LatLng) {
                        setState(() {
                          positionDestinationCarte = pos;
                          if (ville != null && ville.isNotEmpty) {
                            villeDestination = ville;
                            quartiersDestination = quartiersFromApi[villeDestination] ?? [];
                          }
                          if (quartier != null && quartier.isNotEmpty) {
                            if (!quartiersDestination.contains(quartier)) {
                              quartiersDestination.add(quartier);
                            }
                            quartierDestination = quartier;
                            _quartierDestinationController.text = quartier;
                          } else {
                            final coords = "${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}";
                            quartierDestination = coords;
                            _quartierDestinationController.text = coords;
                            if (!quartiersDestination.contains(coords)) {
                              quartiersDestination.add(coords);
                            }
                          }
                        });
                        Get.snackbar(
                          "Position sélectionnée",
                          "Ville : ${ville ?? "Inconnue"}\nQuartier : ${quartierDestination ?? "Coordonnées GPS"}",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    }
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _phonePassagerController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration("Votre contact téléphonique", Icons.phone),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return "Veuillez entrer un numéro de téléphone";
                    if (val.length < 8) return "Numéro trop court";
                    if (val.length > 8) return "Numéro trop long";
                    return null;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                ),
                SizedBox(height: 10),
                if (distance != null && cost != null) ...[
                  Text(
                    "💰 Coût estimé : ${cost} F",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.orange),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Ce coût est estimatif. Le coût réel sera négocié avec le livreur.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange[800],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ] else ...[
                  Text(
                    "ℹ️ Choisissez un point d'origine et une destination sur la carte pour voir le coût estimé.",
                    style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                  ),
                  SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
        // Partie fixe en bas pour les boutons "Trouver" et "Recherche par quartier"
        Column(
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 30,
              runSpacing: 20,
              children: [
                Column(
                  children: [
                    Ink(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Colors.deepOrange, Colors.orange]),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.my_location, color: Colors.white, size: 30),
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          Get.dialog(
                            Center(
                              child: Container(
                                width: 300,
                                height: 300,
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/images/search_animation.gif', width: 160, height: 160),
                                    SizedBox(height: 16),
                                    Text(
                                      "Recherche de livreurs en cours…",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        decoration: TextDecoration.none,          // pas de soulignement
                                        decorationColor: Colors.transparent,      // s’il reste un trait, il sera transparent
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            barrierDismissible: false,
                          );
                          await Future.delayed(Duration(milliseconds: 200));
                          final position = await _getCurrentPosition();
                          if (position != null) {
                            await _findCourierByLocation(position.latitude, position.longitude, skipDialog: true);
                          } else {
                            Get.back();
                          }
                        },
                        iconSize: 60,
                        padding: EdgeInsets.all(22),
                        splashRadius: 30,
                      ),
                    ),
                    SizedBox(height: 6),
                    Container(
                      width: 200,
                      child: Text(
                        "Trouver des livreurs à proximité",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Ink(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Colors.orange, Colors.lightGreen]),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.search, color: Colors.white, size: 30),
                        onPressed: _findCourier,
                        iconSize: 60,
                        padding: EdgeInsets.all(22),
                        splashRadius: 30,
                      ),
                    ),
                    SizedBox(height: 6),
                    Container(
                      width: 120,
                      child: Text(
                        "Recherche par quartier",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeOut);
                setState(() => _currentStep = 0);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: Text("Retour", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }


  Future<void> _sendNotification(List livreurs, {bool sourceGps = false}) async {
    List<String> livreursIds = livreurs.map((livreur) => livreur['custom_id'].toString()).toList();
    final Map<String, dynamic> payload = {
      'livreurs_ids': livreursIds,
      'title': "Nouvelle demande de course",
      'body': sourceGps
          ? "Une course a été demandée près de votre position actuelle."
          : "Une demande de course a été effectuée dans votre quartier.",
    };

    final url = Uri.parse("https://apps.farisbusinessgroup.com/api/Livraison/notification_demande_course.php");
    try {
      final response = await http.post(
        url,
        body: jsonEncode(payload),
        headers: {"Content-Type": "application/json"},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) {
        Get.snackbar("Succès", data['message'], snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar("Erreur", data['message'] ?? "Erreur lors de l'envoi de la notification", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Erreur", "Exception: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }


  InputDecoration _inputDecoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    prefixIcon: Icon(icon, color: Colors.orange),
  );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentStep > 0) { // Si on n'est pas sur la première étape
          _pageController.previousPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          setState(() {
            _currentStep--;
          });
          return false; // Empêche la fermeture de la page
        }
        return true; // Sinon, autorise la fermeture de la page
      },
      child: isLoadingCities
          ? Scaffold(
        body: Center(child: CircularProgressIndicator()),
      )
          : Scaffold(
        appBar: AppBar(
          title: Text(
            'Trouver un livreur pour une course',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.orange, Colors.lightGreen]),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Tu peux ajouter ici un indicateur d'étapes si besoin
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep1Form(),
                      _buildStep2Form(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}