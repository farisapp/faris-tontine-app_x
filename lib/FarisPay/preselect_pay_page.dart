import 'package:faris/FarisPay/select_op_page.dart';
import 'package:faris/FarisPay/transfert_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PreselectPayPage extends StatelessWidget {
  PreselectPayPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Liste des options avec icônes et images
    final List<Map<String, dynamic>> buttonData = [
      {
        "title": "Achat de Mégas et Unités",
        "subtitle": "Souscrire aux forfaits internet et crédits d'appel et profitez des bonus",
        "image": "assets/images/internet.png",
        "icon": Icons.shopping_cart,
        "onPress": () => Get.to(() => SelectOpPage(), transition: Transition.cupertino),
        "isAvailable": true,
        "borderColor": Colors.orange.shade300,
      },
      {
        "title": "Transfert d'argent et paiements",
        "subtitle": "Envoyez et recevez de l'argent entre opérateurs et gérez vos paiements mobile money simplement",
        "image": "assets/images/mobile_money.png",
        "icon": Icons.currency_exchange,
        "onPress": () => Get.to(() => TransfertPage(), transition: Transition.cupertino),
        "isAvailable": true,
        "borderColor": Colors.purple.shade300,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Choisir une option",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange.shade700,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centre verticalement
            crossAxisAlignment: CrossAxisAlignment.center, // Centre horizontalement
            children: buttonData.map((button) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: _buildRectangleButton(
                  context: context,
                  title: button["title"],
                  subtitle: button["subtitle"],
                  imagePath: button["image"],
                  icon: button["icon"],
                  onPress: button["onPress"],
                  isAvailable: button["isAvailable"],
                  borderColor: button["borderColor"],
                  maxWidth: screenWidth * 0.85, // Ajustement pour mieux centrer
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildRectangleButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String imagePath,
    required IconData icon,
    required VoidCallback onPress,
    required bool isAvailable,
    required Color borderColor,
    required double maxWidth,
  }) {
    return GestureDetector(
      onTap: isAvailable ? onPress : null,
      child: Container(
        width: maxWidth,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              spreadRadius: 1,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centrer le titre et l'icône
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isAvailable ? borderColor : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isAvailable ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Image.asset(
              imagePath,
              height: 80, // Ajusté pour une meilleure visibilité
              width: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: isAvailable ? Colors.black54 : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
