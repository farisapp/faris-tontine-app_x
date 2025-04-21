import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Depot/vente_nana_page.dart';
import 'faris_nana_achat_page.dart';
import 'add_faris_nana_achat.dart';
import 'explore_offers_page.dart';
import 'package:faris/presentation/journey/faris_nana/Depot/add_faris_depot_achat.dart';

class BannerWidget extends StatelessWidget {
  const BannerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Utilisation de MediaQuery pour adapter la taille des textes et de l'image
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth < 360 ? 12 : 14;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [Colors.orange, Colors.deepOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "Avec Faris Nana, achetez sans vous ruiner, à petit prix !!",
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Image.asset(
              "assets/images/banner_image.png",
              height: 80,
              width: 80,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class ServicesGrid extends StatelessWidget {
  final Function(BuildContext) onSubscriptionTap;

  const ServicesGrid({Key? key, required this.onSubscriptionTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calcul de la taille de police responsive
    double screenWidth = MediaQuery.of(context).size.width;
    double titleFontSize = screenWidth < 360 ? 12 : 16;
    double subtitleFontSize = screenWidth < 360 ? 10 : 12;

    final List<Map<String, dynamic>> services = [
      {
        "title": "Achats Nana",
        "subtitle": "Découvrez nos offres disponibles et payez à tempérament",
        "icon": Icons.shopping_cart,
        "borderColor": Colors.red,
      },
      {
        "title": "Achats en cours",
        "subtitle": "Voir vos achats entamés",
        "icon": Icons.list_alt,
        "borderColor": Colors.orangeAccent,
      },
      {
        "title": "Dépôt-Vente",
        "subtitle": "Louez un espace pour stocker et vendre vos produits",
        "icon": Icons.store,
        "borderColor": Colors.orange,
      },
      {
        "title": "Achetez d'autres biens",
        "subtitle": "Achetez n'importe quel autre produit à tempérament",
        "icon": Icons.shopping_cart,
        "borderColor": Colors.red.shade400,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            if (index == 0) {
              Get.to(() => const ExploreOffersPage());
            } else if (index == 1) {
              Get.to(() => const FarisNanaAchatPage());
            } else if (index == 2) {
              Get.to(() => const AddFarisDepotAchat());
            } else if (index == 3) {
              Get.to(() => const AddFarisNanaAchat());
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: services[index]["borderColor"], width: 2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  services[index]["icon"],
                  size: 50,
                  color: services[index]["borderColor"],
                ),
                const SizedBox(height: 8),
                Text(
                  services[index]["title"],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Le sous-titre est enveloppé dans un Flexible pour gérer l'espace
                Flexible(
                  child: Text(
                    services[index]["subtitle"],
                    style: TextStyle(fontSize: subtitleFontSize, color: Colors.black54),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FarisNanaAcceuil extends StatelessWidget {
  const FarisNanaAcceuil({Key? key}) : super(key: key);

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext infoDialogContext) {
        return AlertDialog(
          title: const Text(
            "Comment obtenir le code de l'article ?",
            style: TextStyle(fontSize: 15),
          ),
          content: const Text(
            "- Nous publions les offres avec les codes articles sur notre page Facebook.\n"
                "- Vous pouvez aussi explorer nos offres disponibles et sélectionner directement un article.",
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(infoDialogContext).pop(),
              child: const Text("OK", style: TextStyle(fontSize: 12)),
            ),
          ],
        );
      },
    );
  }

  void _showSubscriptionModal(BuildContext context) {
    final TextEditingController codeArticleTextEditingController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(12),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Souscrire à un achat", style: TextStyle(fontSize: 16)),
              TextButton.icon(
                onPressed: () => _showInfoDialog(dialogContext),
                icon: const Icon(Icons.info, color: Colors.orangeAccent, size: 18),
                label: const Text("?", style: TextStyle(color: Colors.orangeAccent, fontSize: 12)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeArticleTextEditingController,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  labelText: "Tapez ici le code de l'article",
                  labelStyle: TextStyle(fontSize: 12),
                  hintText: "CODE",
                  hintStyle: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final codeArticle = codeArticleTextEditingController.text.trim();
                if (codeArticle.isNotEmpty) {
                  Navigator.of(dialogContext).pop();
                  Get.to(() => FarisNanaAchatPage(codeArticle: codeArticle));
                } else {
                  Navigator.of(dialogContext).pop();
                  Get.snackbar(
                    "Erreur",
                    "Veuillez entrer un code valide.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(150, 30),
              ),
              child: const Text("VALIDER", style: TextStyle(fontSize: 12)),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Annuler", style: TextStyle(fontSize: 12)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double baseFontSize = screenWidth < 360 ? 12 : 14;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: const Padding(
          padding: EdgeInsets.all(6.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey,
            radius: 18,
            child: Icon(Icons.person, color: Colors.white, size: 18),
          ),
        ),
        title: Center(
          child: Text(
            "Achats Nana",
            style: GoogleFonts.lato(
              fontSize: baseFontSize + 6,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ),
        actions: [
          Tooltip(
            message: "Voir les notifications",
            child: IconButton(
              icon: Icon(Icons.notifications, color: Colors.black, size: baseFontSize + 8),
              onPressed: () {
                Get.snackbar(
                  "Notifications",
                  "Vous n'avez aucune nouvelle notification.",
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: const BannerWidget(),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: ServicesGrid(onSubscriptionTap: (ctx) => _showSubscriptionModal(ctx)),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.deepOrange, Colors.orange],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: FloatingActionButton.extended(
              onPressed: () => _showSubscriptionModal(context),
              backgroundColor: Colors.transparent,
              elevation: 0,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Souscrire à un achat", style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.black, Colors.deepOrange],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: FloatingActionButton.extended(
              onPressed: () => Get.to(() => const VenteNanaPage()),
              backgroundColor: Colors.transparent,
              elevation: 0,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Vendre vos produits", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
