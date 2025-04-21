import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../common/app_constant.dart';
import '../controller/user_controller.dart';
import 'find_courier_page.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart'; // pour rootBundle


class CoursesPage extends StatefulWidget {
  @override
  _CoursesPageState createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  List<dynamic> _courses = [];
  bool _loading = true;
  BitmapDescriptor? _departIcon;
  BitmapDescriptor? _destinationIcon;
  BitmapDescriptor? _riderIcon;
  List<dynamic> _riders = [];

  @override
  void initState() {
    super.initState();
    _loadCustomIcons();
    fetchRiders(); // appel initial
  }

  Future<void> _loadCustomIcons() async {
    try {
      final ByteData byteData = await rootBundle.load('assets/icons/rider.png');
      final Uint8List imageData = byteData.buffer.asUint8List();
      _riderIcon = await BitmapDescriptor.fromBytes(imageData);
      setState(() {}); // pour déclencher le rebuild
    } catch (e) {
      print("❌ Erreur lors du chargement de l'icône rider : $e");
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
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Future<void> fetchRiders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstant.TOKEN);
    if (token == null) {
      print("❌ Aucun token disponible");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(AppConstant.LISTE_FARIS_RIDER_URI),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _riders = data['data'] ?? [];
        });
        await fetchCourses(); // 👈 important
      } else {
        print("❌ Erreur chargement riders : ${response.statusCode}");
      }
    } catch (e) {
      print("💥 Exception fetchRiders: $e");
    }
  }


  Future<void> fetchCourses() async {
    final userId = Get.find<UserController>().userInfo?.id?.toString();
    if (userId == null) return;

    final response = await http.get(Uri.parse(
      'https://apps.farisbusinessgroup.com/api/Livraison/get_courses.php?user_id=$userId&nocache=${DateTime.now().millisecondsSinceEpoch}',
    ));

    setState(() => _loading = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() => _courses = (data['courses'] as List)
            .where((course) => course['is_deleted_client'].toString() != '1')
            .toList());
      } else {
        Get.snackbar("Erreur", data['message']);
      }
    } else {
      Get.snackbar("Erreur", "Impossible de charger les courses");
    }
  }
  Future<void> _supprimerCourse(int courseId) async {
    final url = Uri.parse("https://apps.farisbusinessgroup.com/api/Livraison/delete_course_role.php");

    try {
      final response = await http.post(url, body: {
        'course_id': courseId.toString(),
        'role': 'client', // 👈 Important pour ne supprimer que côté client
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _courses.removeWhere((c) => c['id'].toString() == courseId.toString());
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("🗑️ Course supprimée.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("⚠️ ${data['message']}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Erreur réseau (${response.statusCode})")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("💥 Exception: $e")),
      );
    }
  }

  void _showRatingDialog(String riderId, int courseId) {
    double rating = 3;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Noter le livreur"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Attribuez une note à ce livreur."),
            SizedBox(height: 10),
            StatefulBuilder(
              builder: (context, setState) => Slider(
                value: rating,
                min: 1,
                max: 5,
                divisions: 4,
                label: rating.toString(),
                onChanged: (val) {
                  setState(() => rating = val);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Annuler"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text("Envoyer"),
            onPressed: () {
              Navigator.pop(context);
              _sendRating(riderId, rating.toInt(), courseId);
            },
          ),
        ],
      ),
    );
  }

  void _sendRating(String riderCode, int note, int courseId) async {
    final userId = Get.find<UserController>().userInfo?.id?.toString();
    if (userId == null) {
      Get.snackbar("Erreur", "Utilisateur non identifié");
      return;
    }

    final url = Uri.parse("https://apps.farisbusinessgroup.com/api/Livraison/note_rider.php");
    final response = await http.post(url, body: {
      "rider_code": riderCode,
      "note": note.toString(),
      "user_id": userId,
      "course_id": courseId.toString(),
    });

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success']) {
        Get.snackbar("Note enregistrée!", "Merci 🙏");
      } else {
        Get.snackbar("Erreur", result['message'] ?? "Une erreur est survenue");
      }
    } else {
      Get.snackbar("Erreur", "Erreur serveur (${response.statusCode})");
    }
  }



  void _showConfirmationDialog(String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text("Confirmer"),
          ),
        ],
      ),
    );
  }
  Future<void> _refuserCourse(int courseId) async {
    final url = Uri.parse("https://apps.farisbusinessgroup.com/api/Livraison/update_course_status_colis.php");

    try {
      final response = await http.post(url, body: {
        'course_id': courseId.toString(),
        'status': '0', // Remet à "En attente de livreur"
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            final index = _courses.indexWhere((c) => c['id'].toString() == courseId.toString());
            if (index != -1) {
              _courses[index]['status'] = 0;
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("🔄 La course est à nouveau en attente de livreur.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("⚠️ Erreur : ${data['message']}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Erreur serveur (${response.statusCode})")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("💥 Exception : $e")),
      );
    }
  }
  double parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Future<void> _updateClientStatus(int courseId, int statusColisDemandeur, {bool markAsRefused = false}) async {
    final url = Uri.parse("https://apps.farisbusinessgroup.com/api/Livraison/update_course_status_colis.php");

    try {
      final Map<String, String> body = {
        'course_id': courseId.toString(),
        'status_colis_demandeur': statusColisDemandeur.toString(),
      };

      // ✅ Si c'est un refus global, on ajoute aussi status = 2
      if (markAsRefused) {
        body['status'] = '2';
      }

      final response = await http.post(url, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            final index = _courses.indexWhere((c) => c['id'].toString() == courseId.toString());
            if (index != -1) {
              _courses[index]['status_colis_demandeur'] = statusColisDemandeur;
              if (markAsRefused) {
                _courses[index]['status'] = 2;
              }
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


  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.deepOrange),
          SizedBox(width: 8),
          Expanded(
            child: Text("$label : $value",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(dynamic course) {
    int status = int.tryParse(course['status'].toString()) ?? 0;
    int statusColis = int.tryParse(course['status_colis']?.toString() ?? "0") ?? 0;
    int statusClient = int.tryParse(course['status_colis_demandeur']?.toString() ?? "0") ?? 0;

    String statusText;
    Color statusColor;

// Si le client a annulé, on affiche en priorité "annulé"
    if (statusClient == 2) {
      statusText = "Annulée par vous ❌";
      statusColor = Colors.red.shade200;
    } else {
      switch (status) {
        case 0:
          statusText = "En attente de livreur";
          statusColor = Colors.orange.shade600;
          break;
        case 1:
          statusText = "Acceptée par un livreur ✅";
          statusColor = Colors.green.shade600;
          break;
        case 2:
          statusText = "Annulée ❌";
          statusColor = Colors.redAccent;
          break;
        default:
          statusText = "Inconnu";
          statusColor = Colors.grey;
      }
    }

    String statusLivreur = switch (statusColis) {
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

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        border: Border.all(color: statusColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(statusText,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 8),
          _buildDetailRow(Icons.location_on, "Départ",
              "${course['origin_ville'] ?? 'Non défini'} - ${course['origin_quartier'] ?? 'Non défini'}"),

          _buildDetailRow(Icons.flag, "Destination",
              course['destination_quartier']?.toString().isNotEmpty ?? false ? course['destination_quartier'] : 'Non défini'),

          _buildDetailRow(Icons.description, "Description",
              (course['description']?.toString().trim().isNotEmpty ?? false) ? course['description'] : "Non défini"),

          _buildDetailRow(Icons.calendar_today, "Date",
              course['created_at']?.toString().split(" ").first ?? "Non défini"),

          _buildDetailRow(Icons.perm_identity, "Code livreur",
              (course['rider_custom_id']?.toString().isNotEmpty ?? false && course['rider_custom_id'] != 'PASSAGER00')
                  ? course['rider_custom_id']
                  : "Non défini"),

          _buildDetailRow(Icons.phone, "Numéro du livreur",
              course['numero_livreur']?.toString().isNotEmpty ?? false ? course['numero_livreur'] : "Non défini"),

          _buildDetailRow(Icons.category, "Type de colis",
              course['type_colis']?.toString().isNotEmpty ?? false ? course['type_colis'] : "Non défini"),

          _buildDetailRow(Icons.attach_money, "Prix estimé",
              course['prix_estime']?.toString().isNotEmpty ?? false ? "${course['prix_estime']} F" : "Non défini"),

          _buildDetailRow(Icons.inventory, "📦 Statut selon livreur", statusLivreur),
          _buildDetailRow(Icons.inventory_2, "📦 Statut selon vous", statusClientLabel),

          if (course['latitude'] != null &&
              course['longitude'] != null &&
              course['latitude_destination'] != null &&
              course['longitude_destination'] != null)
            Container(
              margin: const EdgeInsets.only(top: 10),
              height: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      parseDouble(course['latitude']),
                      parseDouble(course['longitude']),
                    ),
                    zoom: 13,
                  ),
                  markers: () {
                    final Set<Marker> markers = {};

                    // Marqueur Départ
                    markers.add(
                      Marker(
                        markerId: MarkerId("depart_${course['id']}"),
                        position: LatLng(
                          parseDouble(course['latitude']),
                          parseDouble(course['longitude']),
                        ),
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                        infoWindow: const InfoWindow(title: "📍 Départ"),
                      ),
                    );

                    // Marqueur Destination
                    markers.add(
                      Marker(
                        markerId: MarkerId("arrivee_${course['id']}"),
                        position: LatLng(
                          parseDouble(course['latitude_destination']),
                          parseDouble(course['longitude_destination']),
                        ),
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                        infoWindow: const InfoWindow(title: "🏁 Destination"),
                      ),
                    );

                    // Position du livreur (récupérée depuis _riders via rider_custom_id)
                    final riderId = course['rider_custom_id'];
                    final rider = _riders.firstWhere(
                          (r) => r['custom_id'] == riderId,
                      orElse: () => null,
                    );

                    if (rider != null &&
                        rider['latitude'] != null &&
                        rider['longitude'] != null &&
                        _riderIcon != null) {
                      markers.add(
                        Marker(
                          markerId: MarkerId("rider_${course['id']}"),
                          position: LatLng(
                            parseDouble(rider['latitude']),
                            parseDouble(rider['longitude']),
                          ),
                          icon: _riderIcon!,
                          infoWindow: const InfoWindow(title: "🧍‍♂️ Livreur"),
                        ),
                      );
                    }

                    return markers;
                  }(),
                  liteModeEnabled: true,
                  zoomControlsEnabled: false,
                  myLocationEnabled: false,
                  compassEnabled: false,
                ),
              ),
            ),
          // Réorganisation des boutons pour le status "Acceptée"
          // Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // 🔸 Ligne : Annuler | Supprimer (toujours visibles)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    label: "Annuler",
                    icon: Icons.block,
                    color: Colors.black,
                    onPressed: () => _showConfirmationDialog(
                      "Annuler la course",
                      "Cette course sera marquée comme annulée).",
                          () => _updateClientStatus(course['id'], 2, markAsRefused: true),
                    ),
                  ),
                  _buildActionButton(
                    label: "Supprimer",
                    icon: Icons.delete_forever,
                    color: Colors.red.shade900,
                    onPressed: () => _showConfirmationDialog(
                      "Supprimer la course",
                      "Cette course sera supprimée de votre écran.",
                          () => _supprimerCourse(course['id']),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // 🔸 Ligne : Livré | Non livré (si acceptée)
              if (status == 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      label: "Livré",
                      icon: Icons.check_circle,
                      color: Colors.green,
                      onPressed: () => _showConfirmationDialog(
                        "Confirmation",
                        "Marquer comme Livré?",
                            () => _updateClientStatus(course['id'], 3),
                      ),
                    ),
                    _buildActionButton(
                      label: "Non livré",
                      icon: Icons.close,
                      color: Colors.grey,
                      onPressed: () => _showConfirmationDialog(
                        "Confirmation",
                        "Marquer comme Non livré ?",
                            () => _updateClientStatus(course['id'], 4),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 10),

              // 🔸 Ligne : Noter | Appeler (si course acceptée)
              if (status == 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      label: "Noter le livreur",
                      icon: Icons.star_rate,
                      color: Colors.amber[800]!,
                      onPressed: () {
                        _showRatingDialog(course['rider_custom_id'], course['id']);
                      },
                    ),
                    if (course['numero_livreur'] != null &&
                        course['numero_livreur'].toString().isNotEmpty)
                      _buildActionButton(
                        label: "Appeler le livreur",
                        icon: Icons.call,
                        color: Colors.blue,
                        onPressed: () {
                          final tel = course['numero_livreur'];
                          launchUrl(Uri.parse("tel:$tel"));
                        },
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mes demandes de course"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: fetchCourses,
        child: _courses.isEmpty
            ? ListView(
          children: [
            SizedBox(height: 200),
            Center(child: Text("Vous n'avez pas encore demandé de course.")),
          ],
        )
            : ListView.builder(
          itemCount: _courses.length,
          itemBuilder: (_, index) => _buildCourseCard(_courses[index]),
        ),
      ),
      floatingActionButton: ElevatedButton.icon(
        onPressed: () => Get.to(() => FindCourierPage()),
        icon: Icon(Icons.find_in_page),
        label: Text("Trouver un livreur"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          shape: StadiumBorder(),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }
}