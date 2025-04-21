import 'package:faris/presentation/journey/tontine/shared/public_tontine_page.dart';
import 'package:faris/presentation/journey/tontine/tontine_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'col_tontine_page.dart';
import 'indiv_tontine_page.dart';

class AppColors {
  static const Color orange = Colors.orange;
  static const Color black = Colors.black;
  static const Color white = Colors.white;
}

class SelectTontineTypePage extends StatelessWidget {
  const SelectTontineTypePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Définir le diamètre des boutons en fonction de la largeur de l'écran (exemple : 30 % de la largeur)
    final double buttonDiameter = screenWidth * 0.3;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sélection du type d'épargne",
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.orange,
        centerTitle: true,
      ),
      // Utilisez SizedBox.expand pour que le Container prenne tout l'espace
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.white,
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      "Choisissez le type d'épargne",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    // Ajout d'un espace supplémentaire
                    const SizedBox(height: 20),
                    // Espace déjà existant basé sur la largeur de l'écran
                    SizedBox(height: screenWidth * 0.1),
                    // Première ligne de boutons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          child: _buildCircleButton(
                            context: context,
                            diameter: buttonDiameter,
                            title: "ÉPARGNE INDIVIDUELLE",
                            subtitle: "Vous cotisez seul(e) dans votre compte épargne",
                            image: 'assets/images/indiv_icon.png',
                            onPress: () => Get.to(
                                  () => const IndivTontinePage(),
                              transition: Transition.cupertino,
                            ),
                          ),
                        ),
                        Flexible(
                          child: _buildCircleButton(
                            context: context,
                            diameter: buttonDiameter,
                            title: "TONTINE EN GROUPE",
                            subtitle: "La tontine traditionnelle, en ligne",
                            image: 'assets/images/collaboration.png',
                            onPress: () => Get.to(
                                  () => TontinePage(),
                              transition: Transition.cupertino,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenWidth * 0.1),
                    // Deuxième ligne de boutons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          child: _buildCircleButton(
                            context: context,
                            diameter: buttonDiameter,
                            title: "ÉPARGNE COLLECTIVE",
                            subtitle: "Vous cotisez à plusieurs dans un compte épargne",
                            image: 'assets/images/collective_icon.png',
                            onPress: () => Get.to(
                                  () => ColTontinePage(),
                              transition: Transition.cupertino,
                            ),
                          ),
                        ),
                        Flexible(
                          child: _buildCircleButton(
                            context: context,
                            diameter: buttonDiameter,
                            title: "ÉPARGNES OU TONTINES PARTAGÉES",
                            subtitle: "Vous pouvez demander à participer",
                            image: "assets/images/epargnes_partagees.png",
                            onPress: () => Get.to(
                                  () => PublicTontinesPage(),
                              transition: Transition.cupertino,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required BuildContext context,
    required double diameter,
    required String title,
    required String subtitle,
    required String image,
    required VoidCallback onPress,
  }) {
    // Vérifier les conditions sur le titre pour appliquer un style spécifique
    final bool isTontineEnGroupe = title == "TONTINE EN GROUPE";
    final bool isPartagees = title == "ÉPARGNES OU TONTINES PARTAGÉES";

    return GestureDetector(
      onTap: onPress,
      child: Column(
        children: [
          Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                // Appliquer un fond blanc si c'est le bouton partagé, sinon un dégradé vert pour "TONTINE EN GROUPE" ou orange par défaut
                colors: isPartagees
                    ? [Colors.white, Colors.white]
                    : isTontineEnGroupe
                    ? [Colors.green.shade100, Colors.green.shade200]
                    : [Colors.orange.shade100, Colors.orange.shade200],
              ),
              border: Border.all(
                color: AppColors.orange,
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Image.asset(
                    image,
                    width: diameter * 0.6,
                    height: diameter * 0.6,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: diameter * 0.1),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: diameter * 0.05),
          SizedBox(
            width: diameter,
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
