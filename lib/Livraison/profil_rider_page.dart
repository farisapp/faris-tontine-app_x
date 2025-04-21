import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Pour File
import 'package:faris/Livraison/rider_login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; // Pour ImagePicker
import 'package:firebase_messaging/firebase_messaging.dart'; // Pour Firebase Messaging
import '../../../../common/app_constant.dart';
import '../controller/user_controller.dart';
import '../presentation/widgets/custom_snackbar.dart';
import '../presentation/widgets/empty_box_widget.dart';
import '../presentation/widgets/progress_dialog.dart';
import '../services/background_service.dart';
import 'SoumettreCNIBPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workmanager/workmanager.dart' as workmanager;
import 'note_livreur_page.dart';

class ProfilRiderPage extends StatefulWidget {
  @override
  _ProfilRiderPageState createState() => _ProfilRiderPageState();
}

class _ProfilRiderPageState extends State<ProfilRiderPage> {
  List<dynamic> _riders = [];
  List<dynamic> _courseRequests = []; // Liste des demandes de course reçues
  final String userId = Get.find<UserController>().userInfo?.id.toString() ?? "1";
  bool _isLoading = true;
  File? _photoProfil;
  final picker = ImagePicker();
  int pendingRequestsCount = 0;
  Timer? _locationTimer;


  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _getListeRiders();
    _startLocationBackgroundTask();
    _getCourseRequests();
    _configureFirebaseMessaging();
    _startPeriodicLocationUpdate(); // ← ICI
    _refreshTimer = Timer.periodic(Duration(seconds: 5), (_) {
      _getCourseRequests();
    });
  }


  @override
  void dispose() {
    _locationTimer?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }
  void _showConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    Get.defaultDialog(
      title: title,
      middleText: content,
      textConfirm: "Oui",
      textCancel: "Annuler",
      confirmTextColor: Colors.white,
      buttonColor: Colors.green,
      onConfirm: () {
        Get.back();
        onConfirm();
      },
      cancelTextColor: Colors.red,
    );
  }

  void _startLocationBackgroundTask() async {
    final userId = Get.find<UserController>().userInfo?.id.toString();
    if (userId == null) return;

    await workmanager.Workmanager().registerPeriodicTask(
      "riderLocationTask",
      taskName,
      frequency: Duration(minutes: 15), // Minimum autorisé sur Android
      inputData: {'user_id': userId},
      initialDelay: Duration(seconds: 10),
      constraints: workmanager.Constraints(
        networkType: workmanager.NetworkType.connected,
      ),
    );

    print("✅ Tâche planifiée pour le livreur $userId");
  }

  /// Configure l'écoute des notifications Firebase.
  void _configureFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data.isNotEmpty && message.data['type'] == 'demande_course') {
        debugPrint("📩 Notification FCM reçue : ${message.data}");

        try {
          // Parsing sécurisé
          final data = message.data;

          final int? courseId = int.tryParse(data['course_id'] ?? '');
          final String originVille = data['origin_ville'] ?? 'Non défini';
          final String originQuartier = data['origin_quartier'] ?? 'Non défini';
          final String destinationVille = data['destination_ville'] ?? 'Non défini';
          final String destinationQuartier = data['destination_quartier'] ?? 'Non défini';
          final String telephonePassager = data['telephone_passager'] ?? 'Non fourni';
          final String description = data['description'] ?? 'Aucune description';
          final String userId = Get.find<UserController>().userInfo?.id.toString() ?? "1";

          if (courseId == null) {
            debugPrint("❌ course_id manquant ou invalide !");
            return;
          }

          // Reconstituer les données nécessaires
          final courseData = {
            'id': courseId, // 👈 clé correcte attendue par _handleCourseRequest
            'origin_ville': originVille,
            'origin_quartier': originQuartier,
            'destination_ville': destinationVille,
            'destination_quartier': destinationQuartier,
            'telephone_passager': telephonePassager,
            'description': description,
          };


          // Afficher le dialogue de demande de course
          _showCourseRequestDialog(courseData);

          // Rafraîchir la liste des demandes
          _getCourseRequests();
        } catch (e) {
          debugPrint("❌ Erreur lors du traitement de la notification : $e");
        }
      }
    });
  }
  void _startPeriodicLocationUpdate() async {
    final userId = Get.find<UserController>().userInfo?.id.toString();
    if (userId == null) return;

    _locationTimer = Timer.periodic(const Duration(minutes: 2), (Timer timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        final response = await http.post(
          Uri.parse('https://apps.farisbusinessgroup.com/api/Livraison/update_rider_position.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_id': int.parse(userId),
            'latitude': position.latitude,
            'longitude': position.longitude,
          }),
        );

        final result = jsonDecode(response.body);
        if (result['success']) {
          debugPrint("📍 Position mise à jour : ${position.latitude}, ${position.longitude}");
        } else {
          debugPrint("⚠️ Échec : ${result['message']}");
        }
      } catch (e) {
        debugPrint("Erreur de localisation : $e");
      }
    });
  }


  Future<void> _callPassenger(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar("Erreur", "Impossible de lancer l'appel.",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  /// Récupère la liste du profil du livreur depuis l'API
  Future<void> _getListeRiders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstant.TOKEN);
      if (token == null) {
        debugPrint("❌ Erreur: Aucun token trouvé !");
        setState(() => _isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse(AppConstant.LISTE_FARIS_RIDER_URI),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("📥 Réponse de l'API rider : ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _riders = data['data'] ?? [];
          _isLoading = false;
        });
      } else {
        debugPrint("❌ Erreur HTTP ${response.statusCode}: ${response.body}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("❌ Exception dans _getListeRiders(): $e");
      setState(() => _isLoading = false);
    }
  }


  String? getCurrentRiderCustomId() {
    final rider = _riders.firstWhere(
          (r) => r['user_id'].toString() == userId,
      orElse: () => null,
    );
    return rider != null ? rider['custom_id'] : null;
  }
  String? getCurrentRiderPhone() {
    final rider = _riders.firstWhere(
          (r) => r['user_id'].toString() == userId,
      orElse: () => null,
    );
    return rider != null ? rider['telephone'] : null;
  }

  /// Récupère la liste des demandes de courses reçues pour le livreur connecté
  Future<void> _getCourseRequests() async {
    try {
      // On appelle directement l'API sans passer de paramètre custom_id,
      // puisque l'API est censée filtrer les demandes avec rider_custom_id = 'PASSAGER00' et status = 0.
      final url = Uri.parse(
        "https://apps.farisbusinessgroup.com/api/Livraison/get_course_requests.php?user_id=$userId",
      );      print("🔎 URL de la requête : $url");

      final response = await http.get(url, headers: {"Accept": "application/json"});
      print("🔎 Réponse de l'API : ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _courseRequests = data['data'] ?? [];
          pendingRequestsCount = _courseRequests.where((e) => e['status'].toString() == "0").length;
        });
        print("🔎 Nombre de demandes récupérées : ${_courseRequests.length}");
      } else {
        print("🔎 Erreur HTTP lors de la récupération des demandes: ${response.statusCode}");
      }
    } catch (e) {
      print("🔎 Exception dans _getCourseRequests(): $e");
    }
  }

  void _contactPassager(String numero) async {
    if (numero.isNotEmpty) {
      final uri = Uri.parse("tel:$numero");
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        Get.snackbar("Erreur", "Impossible de passer l'appel", snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  /// Affiche un dialogue de demande de course
  void _showCourseRequestDialog(Map<String, dynamic> requestData) {
    final originVille = requestData['origin_ville'] ?? 'N/A';
    final originQuartier = requestData['origin_quartier'] ?? 'N/A';
    final destinationVille = requestData['destination_ville'] ?? 'N/A';
    final destinationQuartier = requestData['destination_quartier'] ?? 'N/A';
    final telephonePassager = requestData['telephone_passager'] ?? 'Non fourni';
    final description = requestData['description'] ?? 'Aucune description';

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Nouvelle demande de course", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📍 Départ : $originVille - $originQuartier", style: TextStyle(fontSize: 14)),
            SizedBox(height: 8),
            Text("📦 Destination : $destinationVille - $destinationQuartier", style: TextStyle(fontSize: 14)),
            SizedBox(height: 8),
            Text("📄 Description : $description", style: TextStyle(fontSize: 14)),
            SizedBox(height: 8),
            Text("📞 Téléphone : $telephonePassager", style: TextStyle(fontSize: 14, color: Colors.blue)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    _showConfirmationDialog(
                      title: "Refuser cette course ?",
                      content: "Êtes-vous sûr de vouloir refuser ou annuler cette demande ?",
                      onConfirm: () => _handleCourseRequest(false, requestData),
                    );
                  },
                  icon: Icon(Icons.close),
                  label: Text("Refuser"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    _showConfirmationDialog(
                      title: "Accepter cette course ?",
                      content: "Êtes-vous sûr de vouloir accepter cette demande et démarrer maintenant pour une course ?",
                      onConfirm: () => _accepterCourse(requestData),
                    );
                  },
                  icon: Icon(Icons.check),
                  label: Text("Accepter"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _contactPassager(telephonePassager),
              icon: Icon(Icons.call),
              label: Text("Appeler"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: Size(double.infinity, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _accepterCourse(Map<String, dynamic> requestData) {
    final enrichedRequest = {
      ...requestData,
      'rider_custom_id': getCurrentRiderCustomId() ?? 'PASSAGER00',
      'rider_phone': getCurrentRiderPhone() ?? '',
    };

    _handleCourseRequest(true, enrichedRequest);
  }

  Future<void> _handleCourseRequest(bool accepted, Map<String, dynamic> requestData) async {
    try {
      final courseId = requestData['id'];
      final riderCustomId = getCurrentRiderCustomId() ?? 'PASSAGER00';

      if (courseId == null || courseId.toString().isEmpty) {
        print("❌ course_id est manquant ou vide.");
        return;
      }

      final url = Uri.parse('https://apps.farisbusinessgroup.com/api/Livraison/handle_course_request.php');
      final riderPhone = getCurrentRiderPhone() ?? '';

      final body = {
        'id': courseId.toString(),
        'rider_custom_id': riderCustomId,
        'numero_livreur': riderPhone,
        'accepted': accepted ? '1' : '0',
      };

      print("📤 Données envoyées à handle_course_request.php : $body");

      final response = await http.post(url, body: body);

      print("📥 Réponse brute : ${response.body}");

      if (response.body.isEmpty) {
        // 🔸 Réponse vide, mais éviter le crash
        print("⚠️ Réponse vide du serveur.");
        Get.snackbar(
          "Info",
          "Mise à jour effectuée!.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      try {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          Get.snackbar(
            "Succès",
            accepted ? "Course acceptée avec succès." : "Course refusée.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            "Erreur",
            responseData['message'] ?? "Une erreur est survenue.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        // 🔥 Parsing JSON échoué
        print("❌ FormatException lors du JSON decode : $e");
        Get.snackbar(
          "Succès",
          "Action effectuée, mais réponse non lisible.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("❌ Erreur lors de la requête de course : $e");
      Get.snackbar(
        "Erreur",
        "Une erreur est survenue : $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }


  /// Méthode pour uploader la photo de profil
  Future<void> _uploadProfilePhoto(String riderId, String cnib) async {
    if (_photoProfil == null) {
      Get.snackbar("Erreur", "Veuillez sélectionner une photo de profil",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    try {
      debugPrint("Préparation de la requête d'upload...");
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("https://apps.farisbusinessgroup.com/api/Livraison/upload_cnib.php"),
      );
      request.fields['custom_id'] = riderId;
      request.fields['cnib'] = cnib;
      request.files.add(await http.MultipartFile.fromPath("photo_profil", _photoProfil!.path));
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);
      if (response.statusCode == 200 && jsonResponse['success']) {
        Get.snackbar("Succès", jsonResponse['message'], backgroundColor: Colors.green, colorText: Colors.white);
        _getListeRiders();
      } else {
        Get.snackbar("Erreur", jsonResponse['message'], backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Erreur", "Exception: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  /// Permet de choisir une image et de lancer l'upload
  Future<void> _pickProfileImage(String riderId, String cnib) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _photoProfil = File(pickedFile.path);
      });
      Future.delayed(Duration(milliseconds: 300), () {
        _uploadProfilePhoto(riderId, cnib);
      });
    }
  }

  /// Affiche une ligne de détail pour le profil
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label : $value",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  /// Change le statut actif/inactif du profil
  Future<void> _toggleStatus(String riderId, bool currentStatus) async {
    final newStatus = currentStatus ? 0 : 1;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(message: "Mise à jour du statut..."),
    );
    try {
      final response = await http.post(
        Uri.parse("https://apps.farisbusinessgroup.com/api/Livraison/update_rider_status.php"),
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: jsonEncode({'custom_id': riderId, 'status': newStatus}),
      );
      Navigator.pop(context);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          setState(() {
            final index = _riders.indexWhere((r) => r['custom_id'].toString() == riderId);
            if (index != -1) _riders[index]['status'] = newStatus;
          });
          showCustomSnackBar(context, "Statut mis à jour avec succès", isError: false);
        } else {
          showCustomSnackBar(context, "Erreur: ${responseData['message']}", isError: true);
        }
      } else {
        showCustomSnackBar(context, "Échec de la mise à jour", isError: true);
      }
    } catch (e) {
      Navigator.pop(context);
      showCustomSnackBar(context, "Erreur: $e", isError: true);
    }
  }

  /// Demande confirmation avant changement de statut
  void _confirmToggleStatus(String riderId, bool currentStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.white,
        title: const Text("Changement de statut", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        content: Text(
          "Voulez-vous vraiment ${currentStatus ? "désactiver votre profil ? Vous ne serez plus visible sur la plateforme" : "activer votre profil ? Vous serez visible et pourrez recevoir des courses."}",
          style: const TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Annuler", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _toggleStatus(riderId, currentStatus);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Confirmer", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
// Cette fonction construit une "card" personnalisée pour une demande de course.
  Widget _buildCourseRequestCard(dynamic request) {
    int status = int.tryParse(request['status'].toString()) ?? 0;

    Color statusColor;
    String statusLabel;

    switch (status) {
      case 0:
        statusColor = Colors.orange.shade600;
        statusLabel = "En attente";
        break;
      case 1:
        statusColor = Colors.green.shade600;
        statusLabel = "Acceptée ✅";
        break;
      case 2:
        statusColor = Colors.redAccent;
        statusLabel = "Refusée ❌";
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = "Inconnu";
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
        ],
        border: Border.all(color: statusColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge de statut
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 8),
          _buildDetailRow(Icons.location_on, "Départ", "${request["origin_ville"]} - ${request["origin_quartier"]}"),
          _buildDetailRow(Icons.flag, "Destination", "${request["destination_quartier"]}"),
          _buildDetailRow(Icons.phone, "Téléphone", "${request["telephone_passager"] ?? "Non fourni"}"),
          _buildDetailRow(Icons.calendar_today, "Date", "${(request["created_at"] != null ? request["created_at"].toString().split(" ").first : '')}"),
          SizedBox(height: 10),

// Boutons Accepter / Refuser en ligne
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showConfirmationDialog(
                      title: "Accepter cette course ?",
                      content: "Êtes-vous sûr de vouloir accepter cette demande et démarrer maintenant pour une course ?",
                      onConfirm: () => _accepterCourse(request),
                    );
                  },
                  icon: Icon(Icons.check),
                  label: Text("Accepter"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showConfirmationDialog(
                      title: "Refuser cette course ?",
                      content: "Êtes-vous sûr de vouloir refuser ou annuler cette demande ?",
                      onConfirm: () => _handleCourseRequest(false, request),
                    );
                  },
                  icon: Icon(Icons.close),
                  label: Text("Refuser"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),

// Bouton Appeler en dessous, full width
          SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              final phone = request["telephone_passager"] ?? "";
              if (phone.isNotEmpty) {
                _callPassenger(phone);
              } else {
                Get.snackbar("Info manquante", "Numéro de téléphone introuvable",
                    backgroundColor: Colors.orange, colorText: Colors.white);
              }
            },
            icon: Icon(Icons.phone),
            label: Text("Appeler le demandeur"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),

        ],
      ),
    );
  }

// Section "Demandes de courses reçues" avec ListView.builder
  Widget _buildCourseRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 20),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 12),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.deepOrange, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(Icons.near_me, color: Colors.deepOrange),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Demandes de courses disponibles",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Divider(),
        _courseRequests.isEmpty
            ? Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text("Aucune demande reçue pour l'instant.", style: TextStyle(fontSize: 16))),
        )
            : ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _courseRequests.length,
          itemBuilder: (context, index) {
            final request = _courseRequests[index];
            return _buildCourseRequestCard(request);
          },
        ),
      ],
    );
  }

  /// Crée une nouvelle course (ici, déclenchée par le passager ou même lors de la réponse du livreur)
  Future<void> createCourse({
    required String customId,
    required String originVille,
    required String originQuartier,
    required String destinationVille,
    required String destinationQuartier,
    required String description,
  }) async {
    final url = Uri.parse("https://apps.farisbusinessgroup.com/api/Livraison/create_course.php");
    final payload = {
      'custom_id': customId,
      'origin_ville': originVille,
      'origin_quartier': originQuartier,
      'destination_ville': destinationVille,
      'destination_quartier': destinationQuartier,
      'description': description,
    };
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      debugPrint("🔍 Réponse brute du serveur: ${response.body}");

      final data = jsonDecode(response.body); // Erreur ici si ce n'est pas du JSON

      if (response.statusCode == 200 && data['success']) {
        Get.snackbar("Succès", data['message'], snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar("Erreur", data['message'] ?? "Erreur serveur", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Exception", "❌ $e", snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.deepOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text(
            "Faris coursiers",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () {
                    // Action optionnelle : afficher une boîte ou naviguer
                    Get.snackbar("Demandes", "Vous avez $pendingRequestsCount demande(s) en attente");
                  },
                ),
                if (pendingRequestsCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$pendingRequestsCount',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
 floatingActionButton: (_riders.isEmpty)
          ? Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.deepOrange, Colors.orange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () => Get.to(() => RiderLoginPage()),
          label: const Row(
            children: [
              Icon(Icons.add, color: Colors.white),
              SizedBox(width: 5),
              Text("S'inscrire", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      )
        : null,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _riders.isEmpty
          ? EmptyBoxWidget(
        titre: "Vous n'êtes pas encore inscrit(e) comme livreur!",
        icon: "assets/icons/no_image.png",
        iconType: "png",
      )
          : RefreshIndicator(
        onRefresh: () async {
          await _getListeRiders();
          await _getCourseRequests();
        },
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            // Affichage de la section du profil
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _riders.length,
              itemBuilder: (context, index) {
                var rider = _riders[index];
                bool isVerified = rider["isVerified"] == 1;
                bool isActif = rider["status"] == 1;
                String riderId = rider["custom_id"].toString();
                String? photoProfil = rider["photo_profil"];
                return GestureDetector(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: isVerified
                          ? LinearGradient(colors: [Colors.orange.shade300, Colors.white])
                          : LinearGradient(colors: [Colors.red.shade200, Colors.white]),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(2, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => _pickProfileImage(riderId, rider["cnib"]),
                              child: Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.blueAccent, width: 3),
                                        ),
                                        child: CircleAvatar(
                                          radius: 45,
                                          backgroundColor: Colors.grey.shade300,
                                          backgroundImage: (photoProfil != null && photoProfil.isNotEmpty)
                                              ? NetworkImage(photoProfil) as ImageProvider
                                              : AssetImage("assets/images/default_avatar.png"),
                                        ),
                                      ),
                                      if (isVerified)
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.blue,
                                            border: Border.all(color: Colors.white, width: 2),
                                          ),
                                          padding: EdgeInsets.all(3),
                                          child: Icon(Icons.verified, color: Colors.white, size: 18),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.camera_alt, color: Colors.blue, size: 16),
                                      SizedBox(width: 5),
                                      Text("Photo profile",
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 14,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  isVerified ? "Profil Vérifié" : "Profil non Vérifié",
                                  style: TextStyle(
                                    color: isVerified ? Colors.green : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(width: 5),
                                if (isVerified)
                                  Icon(Icons.verified, color: Colors.green, size: 18),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildDetailRow(Icons.person, "Nom", rider["prenom"] ?? "Non défini"),
                        _buildDetailRow(Icons.qr_code, "Code", rider["custom_id"] ?? "Non défini"),
                        _buildDetailRow(Icons.credit_card, "CNIB", rider["cnib"] ?? "Non défini"),
                        _buildDetailRow(Icons.phone, "Téléphone", rider["telephone"] ?? "Non défini"),
                        _buildDetailRow(Icons.location_city, "Ville", rider["ville"] ?? "Non défini"),
                        _buildDetailRow(Icons.map, "Quartiers", rider["quartiers"] ?? "Non défini"),
                        _buildDetailRow(Icons.delivery_dining, "Moyen de livraison", rider["moyen_livraison"] ?? "Non défini"),
                        if (rider["note"] != null && rider["note"].toString().isNotEmpty && double.tryParse(rider["note"].toString()) != 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              children: [
                                Icon(Icons.star_rate, color: Colors.red, size: 20),
                                SizedBox(width: 6),
                                Text(
                                  "Note :",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "${(double.tryParse(rider["note"].toString()) ?? 0.0).toStringAsFixed(1)} / 5",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 10),
                                ...List.generate(
                                  5,
                                      (index) => Icon(
                                    index < (double.tryParse(rider["note"].toString())?.round() ?? 0)
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              children: [
                                Icon(Icons.star_border, color: Colors.grey, size: 20),
                                SizedBox(width: 6),
                                Text(
                                  "Pas encore noté",
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 10),
                       Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Switch(
                                  value: isActif,
                                  onChanged: (newValue) {
                                    if (!isVerified && newValue == true) {
                                      Get.dialog(
                                        AlertDialog(
                                          title: Text("Profil non vérifié"),
                                          content: Text(
                                            "⚠️ Vous pouvez activer votre profil mais il n'est pas encore vérifié! Veuillez importer les photos de votre CNIB.",
                                          ),
                                          actions: [
                                            TextButton(
                                              child: Text("Annuler"),
                                              onPressed: () => Get.back(),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                              onPressed: () {
                                                Get.back();
                                                _confirmToggleStatus(riderId, isActif);
                                              },
                                              child: Text("Activer"),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      _confirmToggleStatus(riderId, isActif);
                                    }
                                  },
                                  activeColor: Colors.green,
                                  inactiveThumbColor: Colors.red,
                                ),
                                Text(
                                  isActif ? "ACTIF" : "INACTIF",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isActif ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                Get.to(() => NoteLivreurPage(customId: riderId));
                              },
                              icon: const Icon(Icons.star, color: Colors.white),
                              label: const Text("Voir ma notation"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (!isVerified) ...[
                          if ((rider["cnib_image_recto"] != null && rider["cnib_image_recto"].isNotEmpty) &&
                              (rider["cnib_image_verso"] != null && rider["cnib_image_verso"].isNotEmpty))
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                "📸 Photos CNIB envoyées",
                                style: TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                ),
                                onPressed: () {
                                  Get.to(() => SoumettreCNIBPage(
                                    riderId: riderId,
                                    nom: rider["nom"],
                                    cnib: rider["cnib"],
                                    telephone: rider["telephone"],
                                  ));
                                },
                                icon: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                label: Text(
                                  "Soumettre les photos de votre CNIB",
                                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            // SECTION: Demandes de courses reçues
            SizedBox(height: 20),
            // SECTION: Demandes de courses reçues
            _buildCourseRequestsSection(),
          ],
        ),
      ),
    );
  }
}
