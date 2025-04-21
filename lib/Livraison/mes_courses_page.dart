import 'dart:convert';
import 'dart:typed_data'; // Garde uniquement celui-ci
import 'package:flutter/services.dart'; // Nécessaire pour rootBundle
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/user_controller.dart';
import '../../../../common/app_constant.dart';

class MesCoursesPage extends StatefulWidget {
  const MesCoursesPage({Key? key}) : super(key: key);

  @override
  _MesCoursesPageState createState() => _MesCoursesPageState();
}


class _MesCoursesPageState extends State<MesCoursesPage> {
  List<dynamic> _courses = [];
  List<dynamic> _riders = [];
  bool _isLoading = true;
  BitmapDescriptor? riderIcon;

  late String userId;
  String? riderCustomId;
  double parseDoubleSafe(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }



  @override
  void initState() {
    super.initState();
    _loadCustomIcons(); // 🔥 Très important
    // Récupération du user_id depuis le UserController
    userId = Get.find<UserController>().userInfo?.id.toString() ?? "";
    print("MesCoursesPage: User ID = $userId");
    // Si un riderCustomId est passé via le constructeur, on l'utilise ; sinon, on le récupère via la liste des riders.
    riderCustomId = riderCustomId ;
    print("MesCoursesPage: RiderCustomId (déjà passé) = $riderCustomId");
    fetchRiders();
  }
  Future<void> _loadCustomIcons() async {
    print("🔄 Chargement de l'icône personnalisée rider.png...");

    try {
      final ByteData byteData = await rootBundle.load('assets/icons/rider.png');
      print("✅ Image rider.png chargée depuis les assets");

      final Uint8List imageData = byteData.buffer.asUint8List();

      final BitmapDescriptor bitmap = await BitmapDescriptor.fromBytes(imageData);
      print("✅ BitmapDescriptor généré avec succès");

      setState(() {
        riderIcon = bitmap;
      });

      print("✅ riderIcon mis à jour dans le state : $riderIcon");

    } catch (e) {
      print("❌ Erreur lors du chargement de l'icône personnalisée : $e");
    }
  }


   /// Récupère la liste des riders via l'API définie dans AppConstant
  Future<void> fetchRiders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstant.TOKEN);
      if (token == null) {
        print("❌ Aucun token trouvé !");
        setState(() { _isLoading = false; });
        return;
      }
      final response = await http.get(
        Uri.parse(AppConstant.LISTE_FARIS_RIDER_URI),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("📤 Réponse Liste Riders: ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _riders = data['data'] ?? [];
        });
        // Recherche du rider dont le user_id correspond
        final rider = _riders.firstWhere(
              (r) => r['user_id'].toString() == userId,
          orElse: () => null,
        );
        if (rider != null) {
          riderCustomId = rider["custom_id"]?.toString();
          print("📍 rider trouvé = $rider");
          print("📍 latitude = ${rider['latitude']}, longitude = ${rider['longitude']}");
        } else {
          print("❌ Aucun rider trouvé pour user_id = $userId");
        }
      } else {
        print("❌ Erreur HTTP lors de la récupération des riders: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception dans fetchRiders(): $e");
    }
    // Ensuite, récupérer les courses
    fetchMyCourses();
  }

  /// Récupère les courses via l'API get_my_courses.php en utilisant le custom_id
  Future<void> fetchMyCourses() async {
    if (riderCustomId == null) {
      print("❌ RiderCustomId introuvable, impossible de récupérer les courses.");
      setState(() { _isLoading = false; });
      return;
    }
    final urlString =
        'https://apps.farisbusinessgroup.com/api/Livraison/get_my_courses.php?custom_id=$riderCustomId&nocache=${DateTime.now().millisecondsSinceEpoch}';
    print("📤 URL de l'API pour les courses : $urlString");

    try {
      final response = await http.get(Uri.parse(urlString));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _courses = (data['data'] as List)
              .where((course) => course['is_deleted_livreur'].toString() != '1')
              .toList();
          _isLoading = false;
        });
      } else {
        print("❌ Erreur HTTP dans fetchMyCourses(): ${response.statusCode} => ${response.body}");
        setState(() { _isLoading = false; });
      }
    } catch (e) {
      print("❌ Exception lors du fetch des courses : $e");
      setState(() { _isLoading = false; });
    }
  }

  /// Met à jour le statut du colis via l'API update_course_status_colis.php
  Future<void> _updateCourseStatus(int courseId, int newStatus) async {
    final url = Uri.parse("https://apps.farisbusinessgroup.com/api/Livraison/update_course_status_colis.php");

    try {
      final response = await http.post(url, body: {
        'course_id': courseId.toString(),
        'status_colis': newStatus.toString(),
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          // ✅ Mise à jour locale immédiate
          setState(() {
            final index = _courses.indexWhere((c) => c['id'].toString() == courseId.toString());
            if (index != -1) {
              _courses[index]['status_colis'] = newStatus;
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("✅ Statut mis à jour.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("⚠️ Erreur : ${data['message']}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Erreur réseau (${response.statusCode})")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("💥 Exception : $e")),
      );
    }
  }

  /// Affiche un dialogue de confirmation
  void _showConfirmationDialog(String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: const Text("Confirmer"),
            ),
          ],
        );
      },
    );
  }

  /// Permet de lancer un appel téléphonique vers le numéro passé
  Future<void> _callPassenger(String phone) async {
    final uri = Uri.parse("tel:$phone");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Impossible de lancer l'appel.")));
    }
  }
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20, color: color),
        label: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          side: BorderSide(color: color, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
  Future<void> _supprimerCourse(int courseId) async {
    final url = Uri.parse("https://apps.farisbusinessgroup.com/api/Livraison/delete_course_role.php");

    try {
      final response = await http.post(
        url,
        body: {
          'course_id': courseId.toString(),
          'role': 'livreur', // ou 'client' selon le rôle du supprimant
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          setState(() {
            _courses.removeWhere((c) => c['id'].toString() == courseId.toString());
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("🗑️ Course supprimée avec succès.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("⚠️ Erreur : ${data['message']}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Erreur serveur : ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("💥 Exception : $e")),
      );
    }
  }

  /// Construit une "card" affichant les détails de la course et les boutons d'action
  Widget _buildCourseCard(dynamic course) {
    final String depart = "${course['origin_ville']} - ${course['origin_quartier']}";
    final String destination = "${course['destination_quartier']}";
    final String telephone = course['telephone_passager'] ?? "Non fourni";
    final String description = course['description'] ?? "Aucune description";
    final String date = course['created_at'].toString().split(" ").first;
    final int courseId = int.tryParse(course['id'].toString()) ?? 0;

    int status = int.tryParse(course['status'].toString()) ?? 0;
    int statusColis = int.tryParse(course['status_colis']?.toString() ?? "0") ?? 0;
    int statusClient = int.tryParse(course['status_colis_demandeur']?.toString() ?? "0") ?? 0;

    Color statusColor;
    String statusText;

    switch (status) {
      case 0:
        statusColor = Colors.orange.shade600;
        statusText = "En attente";
        break;
      case 1:
        statusColor = Colors.green.shade600;
        statusText = "Acceptée ✅ par moi";
        break;
      case 2:
        statusColor = Colors.redAccent;
        statusText = "Annulée ❌";
        break;
      default:
        statusColor = Colors.grey;
        statusText = "Inconnu";
    }

    String statusColisLabel = switch (statusColis) {
      3 => "✅ Livré",
      4 => "❌ Non livré",
      5 => "🚫 Annulé",
      _ => "Inconnu"
    };

    String statusClientLabel = switch (statusClient) {
      3 => "✅ Livré",
      4 => "❌ Non livré",
      2 => "🚫 Annulé",
      _ => "Inconnu"
    };

    // 🔹 Position du livreur
    final riderCode = course['rider_custom_id']?.toString();

    print("💡 rider_custom_id (dans course): $riderCode");
    print("📦 Liste des riders dispos: ${_riders.map((r) => r['custom_id']).toList()}");

    Map<String, dynamic>? rider;
    if (riderCode != null) {
      rider = _riders.firstWhere(
            (r) => r['custom_id']?.toString() == riderCode,
        orElse: () => null,
      );
    }
    print("🎯 Rider trouvé : $rider");
    print("💡 rider_custom_id (dans course): ${course['rider_custom_id']}");
    print("📦 Liste des riders dispos: ${_riders.map((r) => r['custom_id']).toList()}");

    LatLng? riderPosition;
    if (rider != null &&
        rider['latitude'] != null &&
        rider['longitude'] != null) {
      print("📍 Position du livreur = ${rider['latitude']}, ${rider['longitude']}");
      double lat = parseDoubleSafe(rider['latitude']);
      double lng = parseDoubleSafe(rider['longitude']);
      riderPosition = LatLng(lat, lng);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        border: Border.all(color: statusColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(statusText,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.location_on, "Départ", "$depart"),
          _buildDetailRow(Icons.flag, "Destination", destination),
          _buildDetailRow(Icons.description, "Description", description),
          _buildDetailRow(Icons.phone, "Contact du demandeur", telephone),
          _buildDetailRow(Icons.calendar_today, "Date", date),
          _buildDetailRow(Icons.category, "Type de colis", course['type_colis']?.toString().isNotEmpty == true ? course['type_colis'] : "Non défini"),
          _buildDetailRow(Icons.monetization_on, "Prix estimé", course['prix_estime']?.toString().isNotEmpty == true ? "${course['prix_estime']} F" : "Non défini"),
          _buildDetailRow(Icons.local_shipping, "Statut selon vous", statusColisLabel),
          _buildDetailRow(Icons.person, "📦 Statut selon le client", statusClientLabel),
          if (course['latitude'] != null && course['longitude'] != null &&
              course['latitude_destination'] != null && course['longitude_destination'] != null)
            Container(
              margin: const EdgeInsets.only(top: 10),
              height: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      parseDoubleSafe(course['latitude']),
                      parseDoubleSafe(course['longitude']),
                    ),
                    zoom: 13,
                  ),
                  markers: {
                    // 🔹 Départ :
                    Marker(
                      markerId: MarkerId("depart_${course['id']}"),
                      position: LatLng(
                        parseDoubleSafe(course['latitude']),
                        parseDoubleSafe(course['longitude']),
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                      infoWindow: InfoWindow(title: "📍 Départ"),
                    ),
                    // Destination
                    // 🔹 Destination :
                    Marker(
                      markerId: MarkerId("arrivee_${course['id']}"),
                      position: LatLng(
                        parseDoubleSafe(course['latitude_destination']),
                        parseDoubleSafe(course['longitude_destination']),
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                      infoWindow: InfoWindow(title: "🏁 Destination"),
                    ),
                    // Livreur (optionnel)
                    if (riderPosition != null && riderIcon != null)
                      Marker(
                        markerId: MarkerId("rider_${course['id']}"),
                        position: riderPosition,
                        icon: riderIcon!,
                        infoWindow: InfoWindow(title: "🧍‍♂️ Position du livreur"),
                      ),
                  },
                  liteModeEnabled: false,
                  zoomControlsEnabled: false,
                  myLocationEnabled: false,
                  compassEnabled: false,
                ),
              ),
            ),

          const SizedBox(height: 10),

          Row(
            children: [
              _buildActionButton(
                label: "Livré",
                icon: Icons.check_circle,
                color: Colors.green,
                onPressed: () => _showConfirmationDialog(
                  "Confirmation",
                  "Voulez-vous marquer ce colis comme Livré ?",
                      () => _updateCourseStatus(courseId, 3),
                ),
              ),
              const SizedBox(width: 10),
              _buildActionButton(
                label: "Non livré",
                icon: Icons.close_rounded,
                color: Colors.orange,
                onPressed: () => _showConfirmationDialog(
                  "Confirmation",
                  "Voulez-vous marquer ce colis comme Non livré ?",
                      () => _updateCourseStatus(courseId, 4),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Row(
            children: [
              if (statusColis != 5)
                _buildActionButton(
                  label: "Annulée",
                  icon: Icons.cancel,
                  color: Colors.red,
                  onPressed: () => _showConfirmationDialog(
                    "Annulation",
                    "Voulez-vous annuler cette course ?",
                        () => _updateCourseStatus(courseId, 5),
                  ),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _callPassenger(telephone),
                  icon: const Icon(Icons.call, color: Colors.blue),
                  label: const Text("Appeler", style: TextStyle(color: Colors.blue)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    side: const BorderSide(color: Colors.blue, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Row(
            children: [
              _buildActionButton(
                label: "Supprimer",
                icon: Icons.delete_forever,
                color: Colors.red.shade900,
                onPressed: () => _showConfirmationDialog(
                  "Supprimer la course",
                  "Cette course sera définitivement masquée.",
                      () => _supprimerCourse(courseId),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construit une ligne de détail avec icône, libellé et valeur
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              "$label : $value",
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes courses',
          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          maxLines: 2,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.purple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
          ? const Center(child: Text("Vous n'avez pas encore accepté une course.", style: TextStyle(fontSize: 16)))
          : RefreshIndicator(
        onRefresh: fetchMyCourses,
        child: ListView.builder(
          itemCount: _courses.length,
          itemBuilder: (context, index) => _buildCourseCard(_courses[index]),
        ),
      ),
    );
  }
}