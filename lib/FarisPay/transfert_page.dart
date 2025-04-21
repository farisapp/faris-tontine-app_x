import 'package:faris/FarisPay/retrait_page.dart';
import 'package:faris/FarisPay/sonabel_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'VisaUbaRechargePage.dart';
import 'canal_page.dart';
import 'money_transfert_page.dart';
import 'onea_page.dart';

class TransfertPage extends StatefulWidget {
  const TransfertPage({Key? key}) : super(key: key);

  @override
  _TransfertPageState createState() => _TransfertPageState();
}

class _TransfertPageState extends State<TransfertPage> {
  Future<void> _refreshPage() async {
    // Simuler un délai pour le rafraîchissement
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Récupérer la largeur de l'écran
    double screenWidth = MediaQuery.of(context).size.width;
    // Taille de police de base (réduite pour les petits écrans)
    double baseFontSize = screenWidth < 360 ? 10 : 12;
    // Calculer la largeur de chaque carte en tenant compte du padding global
    double cardWidth = (screenWidth - 48) / 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Opérations Mobile Money",
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth < 360 ? 16 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: GridView.extent(
                physics: const NeverScrollableScrollPhysics(),
                maxCrossAxisExtent: 180,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                shrinkWrap: true,
                children: [
                  _buildOutlinedCard(
                    imagePath: "assets/images/logo_all.png", // ✅ image
                    title: "Transfert d'argent entre réseaux",
                    color: Colors.purple,
                    cardWidth: cardWidth,
                    baseFontSize: baseFontSize,
                    onPress: () => Get.to(() => MoneyTransferPage()),
                  ),
                  _buildOutlinedCard(
                    imagePath: "assets/images/visa.png", // ✅ image
                    title: "Recharger carte VISA",
                    color: Colors.blue,
                    cardWidth: cardWidth,
                    baseFontSize: baseFontSize,
                    onPress: () => Get.to(() => VisaUbaRechargePage()),
                  ),
                  _buildOutlinedCard(
                    imagePath: "assets/images/orange_money.png", // ✅ image
                    title: "Retrait Orange Money",
                    color: Colors.green,
                    cardWidth: cardWidth,
                    baseFontSize: baseFontSize,
                    onPress: () => Get.to(() => RetraitPage()),
                  ),
                  _buildOutlinedCard(
                    imagePath: "assets/images/sonabel.png", // ✅ image
                    title: "Cashpower",
                    color: Colors.yellow.shade700,
                    cardWidth: cardWidth,
                    baseFontSize: baseFontSize,
                    onPress: () => Get.to(() => SonabelPage()),
                  ),
                  _buildOutlinedCard(
                    imagePath: "assets/images/onea.png", // ✅ image
                    title: "Factures ONEA (Moov Money)",
                    color: Colors.blueAccent,
                    cardWidth: cardWidth,
                    baseFontSize: baseFontSize,
                    onPress: () => Get.to(() => OneaPage()),
                  ),
                  _buildOutlinedCard(
                    imagePath: "assets/images/canal+.png", // ✅ image
                    title: "Abonnement ou réabonnement",
                    color: Colors.red,
                    cardWidth: cardWidth,
                    baseFontSize: baseFontSize,
                    onPress: () => Get.to(() => CanalPage()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildOutlinedCard({
    IconData? icon, // rendu optionnel
    String? imagePath, // nouvelle propriété
    required String title,
    required Color color,
    required double cardWidth,
    required double baseFontSize,
    required VoidCallback onPress,
  }) {
    return InkWell(
      onTap: onPress,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 5,
              spreadRadius: 1,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // ✅ aligne tout en haut
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            imagePath != null
                ? Image.asset(
              imagePath,
              width: cardWidth * 0.5,
              height: cardWidth * 0.5,
              fit: BoxFit.contain,
            )
                : Icon(
              icon,
              size: cardWidth * 0.3,
              color: color,
            ),
            // ❌ SizedBox supprimé
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: baseFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
