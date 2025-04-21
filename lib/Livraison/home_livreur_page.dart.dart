import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:faris/Livraison/profil_rider_page.dart';
import 'package:faris/Livraison/mes_courses_page.dart';
import 'package:faris/Livraison/rider_login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/user_controller.dart';
import 'demandes_courses_page.dart';
import 'note_livreur_page.dart';
import 'package:http/http.dart' as http;

class HomeLivreurPage extends StatefulWidget {
  const HomeLivreurPage({Key? key}) : super(key: key);

  @override
  State<HomeLivreurPage> createState() => _HomeLivreurPageState();
}

class _HomeLivreurPageState extends State<HomeLivreurPage> {
  String? riderCustomId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _afficherConsentementLocalisation();
    });
  }

  Future<void> _afficherConsentementLocalisation() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = Get.find<UserController>().userInfo?.id.toString();

    if (userId == null) return;

    final dernierUserId = prefs.getString("dernier_user_id");

    // Si c’est un nouvel utilisateur (ou première fois), on montre la boîte
    if (dernierUserId != userId) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Permission de localisation"),
          content: const Text(
            "Faris suit votre position même lorsque l’application est en arrière-plan. "
                "Cela permet de recevoir des demandes de course à tout moment, même si l’application est fermée.",
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Marquer comme déjà vu pour cet utilisateur
                await prefs.setString("dernier_user_id", userId);

                // Tu peux ici lancer ton service WorkManager si besoin
              },
              child: const Text("J'ai compris"),
            ),
          ],
        ),
      );
    }
  }

  Future<String?> getCurrentRiderCustomId(String userId) async {
    try {
      final url = "https://apps.farisbusinessgroup.com/api/Livraison/get_all_riders.php?user_id=$userId";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] && data["riders"] != null && data["riders"].isNotEmpty) {
          final rider = data["riders"][0]; // Un seul rider attendu
          return rider["custom_id"]?.toString();
        }
      }
    } catch (e) {
      print("Erreur API get_all_riders.php : $e");
    }
    return null;
  }

  Future<void> fetchRiderCustomId() async {
    final userId = Get.find<UserController>().userInfo?.id?.toString();

    if (userId != null) {
      final customId = await getCurrentRiderCustomId(userId);
      setState(() {
        riderCustomId = customId;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [Color(0xFFFFF8E1), Color(0xFFFFE0B2), Color(0xFFFFA726)],
            stops: [0.2, 0.7, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
          child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.delivery_dining, size: 28, color: Colors.deepOrange),
                      SizedBox(width: 10),
                      Text(
                        "Espace Livreur",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  _buildButtonsRow(context, [
                    _buildCircleButton(
                      context: context,
                      text: "S'inscrire",
                      iconPath: "assets/images/as_delivery.png",
                      onPressed: () => Get.to(() => RiderLoginPage()),
                    ),
                    _buildCircleButton(
                      context: context,
                      text: "Mon profil",
                      iconPath: "assets/images/profil_delivery.png",
                      onPressed: () => Get.to(() => ProfilRiderPage()),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildButtonsRow(context, [
                    _buildCircleButton(
                      context: context,
                      text: "Courses et livraisons disponibles",
                      iconPath: "assets/images/avail_delivery.png",
                      onPressed: () {
                        Get.to(() => CourseRequestsPage());
                      },
                    ),
                    _buildCircleButton(
                      context: context,
                      text: "Mes courses",
                      iconPath: "assets/images/mes_demandes_courses.png",
                      onPressed: () async {
                        if (riderCustomId == null) {
                          final userId = Get.find<UserController>().userInfo?.id?.toString();
                          if (userId != null) {
                            setState(() => isLoading = true);
                            final customId = await getCurrentRiderCustomId(userId);
                            setState(() {
                              riderCustomId = customId;
                              isLoading = false;
                            });
                          }
                        }

                        if (riderCustomId != null) {
                          Get.to(() => MesCoursesPage());
                        } else {
                          Get.snackbar("Erreur", "Profil livreur non trouvé",
                              backgroundColor: Colors.red, colorText: Colors.white);
                        }
                      },
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonsRow(BuildContext context, List<Widget> buttons) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20,
      runSpacing: 20,
      children: buttons,
    );
  }

  Widget _buildCircleButton({
    required BuildContext context,
    required String text,
    required String iconPath,
    required VoidCallback onPressed,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double circleRadius = screenWidth * 0.15;

    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Colors.deepOrange, Colors.orangeAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(2, 2)),
              ],
            ),
            child: CircleAvatar(
              radius: circleRadius,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: SizedBox(
                  width: circleRadius * 2,
                  height: circleRadius * 2,
                  child: Image.asset(iconPath, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 120,
            child: Text(
              text,
              textAlign: TextAlign.center,
              softWrap: true,
              maxLines: 3,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

