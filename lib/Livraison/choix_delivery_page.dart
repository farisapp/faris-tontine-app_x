import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_client_page.dart';
import 'home_livreur_page.dart.dart';

class ChoixDeliveryPage extends StatelessWidget {
  const ChoixDeliveryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Choisissez votre camp',
          style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
          maxLines: 2,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.deepOrangeAccent, Colors.orange]),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ Image ajoutée
            Image.asset(
              'assets/images/delivery2.png',
              height: screenHeight * 0.2,
            ),
            const SizedBox(height: 30),

            _buildOptionButton(
              context,
              title: "Je cherche un livreur",
              description: "Vous avez un colis à envoyer ? Trouvez un livreur rapidement",
              icon: Icons.search,
              color: Colors.deepOrange,
              titleColor: Colors.deepOrange, // 💙 titre 1
              onPressed: () => Get.to(() => HomeClientPage()),
            ),
            const SizedBox(height: 30),
            _buildOptionButton(
              context,
              title: "Je suis un livreur",
              description: "Inscrivez-vous comme livreur ou accédez à votre profil",
              icon: Icons.directions_bike,
              color: Colors.orange,
              titleColor: Colors.deepOrange, // 💜 titre 2
              onPressed: () => Get.to(() => const HomeLivreurPage()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context,
      {required String title,
        required String description,
        required IconData icon,
        required Color color,
        required Color titleColor, // 👈 ajoute ce paramètre
        required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: titleColor)),
                  const SizedBox(height: 5),
                  Text(description, style: const TextStyle(color: Colors.black87)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
