import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common/app_constant.dart';  // Ajustez le chemin si nécessaire
import '../controller/user_controller.dart';

class CourseRequestsPage extends StatefulWidget {
  @override
  _CourseRequestsPageState createState() => _CourseRequestsPageState();
}

class _CourseRequestsPageState extends State<CourseRequestsPage> {
  List<dynamic> _courseRequests = [];
  List<dynamic> _riders = []; // Liste des riders, pour récupérer custom_id et telephone
  bool _isLoading = true;
  int pendingRequestsCount = 0;
  Timer? _refreshTimer;
  // Récupération de l'ID de l'utilisateur via le UserController
  final String userId = Get.find<UserController>().userInfo?.id.toString() ?? "1";
  Set<int> _locallyHandledCourseIds = {}; // Pour exclure les courses acceptées/refusées localement

  @override
  void initState() {
    super.initState();
    _getListeRiders();  // Récupère les infos du rider pour custom_id et téléphone
    _getCourseRequests();
    _refreshTimer = Timer.periodic(Duration(seconds: 2), (_) {
      _getCourseRequests();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// Récupère la liste des riders depuis l'API (même logique que dans ProfilRiderPage)
  Future<void> _getListeRiders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstant.TOKEN);
      if (token == null) {
        debugPrint("❌ Aucun token trouvé !");
        return;
      }
      final response = await http.get(
        Uri.parse(AppConstant.LISTE_FARIS_RIDER_URI),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _riders = data['data'] ?? [];
        });
      } else {
        debugPrint("❌ Erreur HTTP ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Exception dans _getListeRiders: $e");
    }
  }

  /// Méthode pour récupérer le custom_id du rider courant à partir de la liste _riders
  String? getCurrentRiderCustomId() {
    final rider = _riders.firstWhere(
          (r) => r['user_id'].toString() == userId,
      orElse: () => null,
    );
    return rider != null ? rider['custom_id'] : null;
  }

  /// Méthode pour récupérer le numéro de téléphone du rider courant
  String? getCurrentRiderPhone() {
    final rider = _riders.firstWhere(
          (r) => r['user_id'].toString() == userId,
      orElse: () => null,
    );
    return rider != null ? rider['telephone'] : null;
  }

  /// Récupère la liste des demandes de courses depuis l'API
  Future<void> _getCourseRequests() async {
    try {
      final url = Uri.parse(
          "https://apps.farisbusinessgroup.com/api/Livraison/get_course_requests.php?user_id=$userId&nocache=${DateTime.now().millisecondsSinceEpoch}");
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _courseRequests = data['data'] ?? [];
          pendingRequestsCount =
              _courseRequests.where((e) => e['status'].toString() == "0").length;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint("❌ Exception dans _getCourseRequests(): $e");
    }
  }

  /// Permet de lancer un appel téléphonique au passager
  Future<void> _callPassenger(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar("Erreur", "Impossible de lancer l'appel.",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  /// Affiche une boîte de dialogue de confirmation
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

  /// Action d'acceptation d'une course
  void _accepterCourse(Map<String, dynamic> requestData) {
    _handleCourseRequest(true, requestData);
  }

  /// Envoie la réponse (acceptation ou refus) à l'API pour une demande de course
  Future<void> _handleCourseRequest(bool accepted, Map<String, dynamic> requestData) async {
    try {
      final courseId = requestData['id'];
      final String riderCustomId = getCurrentRiderCustomId() ?? 'PASSAGER00';
      final String riderPhone = getCurrentRiderPhone() ?? '';

      if (courseId == null || courseId.toString().isEmpty) return;

      final url = Uri.parse('https://apps.farisbusinessgroup.com/api/Livraison/handle_course_request.php');
      final body = {
        'id': courseId.toString(),
        'rider_custom_id': riderCustomId,
        'numero_livreur': riderPhone,
        'accepted': accepted ? '1' : '0',
      };

      final response = await http.post(url, body: body);
      final responseData = response.body.isNotEmpty ? json.decode(response.body) : null;

      if (responseData == null || responseData['success'] == true) {
        // ✅ Met à jour le statut localement pour masquer la demande sans la supprimer
        setState(() {
          final index = _courseRequests.indexWhere(
                (c) => c['id'].toString() == requestData['id'].toString(),
          );

          // Empêche la réapparition en l'ajoutant à la liste des courses gérées localement
          _locallyHandledCourseIds.add(int.parse(requestData['id'].toString()));

          if (index != -1) {
            _courseRequests[index]['status'] = accepted ? 1 : 2;
          }

          // Met à jour le nombre de demandes en attente
          pendingRequestsCount =
              _courseRequests.where((e) => e['status'].toString() == "0").length;
        });

        if (accepted) {
          Get.dialog(
            AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text("Course acceptée"),
              content: Text("Veuillez contacter le demandeur s'il vous plaît."),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text("OK", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            barrierDismissible: false,
          );
        } else {
          Get.snackbar(
            "Succès",
            "Course refusée.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
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
      debugPrint("❌ Erreur lors de la requête de course : $e");
      Get.snackbar(
        "Erreur",
        "Une erreur est survenue : $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Construit une ligne détaillée pour afficher les informations
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.red),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label : $value",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit la carte pour chaque demande de course
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
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2))],
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
          _buildDetailRow(
              Icons.location_on,
              "Départ",
              "${request["origin_ville"]} - ${request["origin_quartier"]}"),
          _buildDetailRow(
              Icons.flag,
              "Destination",
              "${request["destination_quartier"]}"),
          _buildDetailRow(
              Icons.phone,
              "Numéro du demandeur",
              "${request["telephone_passager"] ?? "Non fourni"}"),
          _buildDetailRow(
            Icons.calendar_today,
            "Date",
            "${(request["created_at"] != null ? request["created_at"].toString().split(" ").first : '')}",
          ),
          SizedBox(height: 10),
          // Boutons Accepter / Refuser
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showConfirmationDialog(
                      title: "Accepter cette course ?",
                      content: "N'accepter pas une course si vous n'êtes pas disponible et prêt (e) à démarrer pour la course. Vous confirmez ?",
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
          SizedBox(height: 10),
          // Bouton Appeler le demandeur
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

  /// Construit la section entière des demandes de courses disponibles
  /// Construit la section entière des demandes de courses disponibles
  Widget _buildCourseRequestsSection() {
    List<dynamic> filteredRequests = _courseRequests
        .where((e) =>
    e['status'].toString() == "0" &&
        !_locallyHandledCourseIds.contains(int.tryParse(e['id'].toString() ?? '')))
        .toList();

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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Divider(),
        filteredRequests.isEmpty
            ? Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text("Aucune demande reçue pour l'instant.", style: TextStyle(fontSize: 16)),
          ),
        )
            : ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: filteredRequests.length,
          itemBuilder: (context, index) {
            final request = filteredRequests[index];
            return _buildCourseRequestCard(request);
          },
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Nécessaire pour voir le dégradé dans flexibleSpace
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          "Demandes de courses",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
        body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async {
          await _getListeRiders();
          await _getCourseRequests();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: _buildCourseRequestsSection(),
        ),
      ),
    );
  }
}
