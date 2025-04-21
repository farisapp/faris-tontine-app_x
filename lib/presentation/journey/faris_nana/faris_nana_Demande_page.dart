import 'package:faris/presentation/journey/faris_nana/add_faris_nana_achat.dart';
import 'package:faris/presentation/journey/faris_nana/info_article_souscription.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../controller/farisnana_controller.dart';
import '../../../controller/farisnana_demande_controller.dart';
import '../../theme/theme_color.dart';
import '../../widgets/empty_box_widget.dart';
import '../../widgets/titre_faris_nana.dart';
import 'liste_faris_demande_nana.dart';
import 'liste_faris_nana_achat.dart';

class FarisNanaDemandePage extends StatefulWidget {
  const FarisNanaDemandePage({Key? key}) : super(key: key);

  @override
  _FarisNanaDemandePageState createState() => _FarisNanaDemandePageState();
}

class _FarisNanaDemandePageState extends State<FarisNanaDemandePage> {
  // Contrôleurs
  final FarisnanaController _farisnanaController = Get.put(FarisnanaController());
  final FarisnanaDemandeController _farisnanaDemandeController = Get.put(FarisnanaDemandeController());

  // PageController pour la navigation par onglets si nécessaire
  late PageController _pageController;

  // ✅ Stocke le Future pour éviter de l'appeler à chaque build
  Future<List<dynamic>>? _futureDemande;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // On lance la requête une seule fois
    _futureDemande = _farisnanaDemandeController.getListeDemnade();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Méthode pour forcer le rafraîchissement des données
  Future<void> _refreshData() async {
    // Relance la requête, puis reconstruit l'UI
    setState(() {
      _futureDemande = _farisnanaDemandeController.getListeDemnade();
    });
  }

  /// Méthode pour récupérer les infos d'un article (codeArticle)
  Future<void> _fetchArticleData(String codeArticle) async {
    try {
      final result = await _farisnanaController.infoArticle(codeArticle);

      if (result.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InfoArticleSouscription(codeArticle: codeArticle),
          ),
        );
      } else {
        _showCustomSnackBar("Code de l'article invalide ou indisponible. Veuillez réessayer !", isError: true);
      }
    } catch (e) {
      _showCustomSnackBar("Une erreur s'est produite : ${e.toString()}", isError: true);
    }
  }

  /// Affiche un SnackBar personnalisé
  void _showCustomSnackBar(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: isError ? Colors.orangeAccent : Colors.green,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Affiche une boîte de dialogue d'erreur
  AlertDialog _showErrorModal(String message) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Row(
        children: const [
          Icon(Icons.error, color: Colors.orangeAccent, size: 30),
          SizedBox(width: 10),
          Text("Désolé !"),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
        ],
      ),
      actions: [
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check, color: Colors.white),
                SizedBox(width: 5),
                Text("OK"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Fond blanc pour uniformiser avec AddFarisNanaAchat
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "FARIS NANA",
          style: GoogleFonts.lato(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.orange,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // Bouton pour proposer un produit
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        onPressed: () {
          Get.to(() => const AddFarisNanaAchat());
        },
        label: Row(
          children: const [
            Icon(Icons.add, color: Colors.white),
            SizedBox(width: 5),
            Text("Proposez un produit", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          const TitreFarisNana(titre: "MES DEMANDES SOUMISES"),
          // ✅ FutureBuilder basé sur _futureDemande
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: FutureBuilder<List<dynamic>>(
                future: _futureDemande,
                builder: (context, snapshot) {
                  // 1. En cours de chargement
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // 2. Erreur
                  if (snapshot.hasError) {
                    return _showErrorModal("Une erreur s'est produite lors du chargement des données.");
                  }

                  // 3. Pas de données
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: EmptyBoxWidget(
                        titre: "Vous n'avez pas encore fait de demande!",
                        icon: "assets/icons/iconDemande.png",
                        iconType: "png",
                      ),
                    );
                  }

                  // 4. Affichage normal
                  return RefreshIndicator(
                    onRefresh: _refreshData, // Relance la requête
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final article = snapshot.data![index];

                        if (article is Map<String, dynamic>) {
                          final date = DateTime.tryParse(article['created_at'] ?? '');
                          final formattedDate = date != null
                              ? "${date.day}-${date.month}-${date.year}"
                              : "Date inconnue";

                          return ListeFarisNana(
                            codeArticle: article["codeArticle"] ?? '--',
                            boutique: article["boutique"] ?? '--',
                            prixArticle: article["prixArticle"] ?? '--',
                            numVendeur: article["numVendeur"] ?? '--',
                            dateCreation: formattedDate,
                            nomArticle: article["nomArticle"] ?? '--',
                            status: article["status"] ?? 0,
                            id: article["id"] ?? 0,
                          );
                        } else {
                          return _showErrorModal("Erreur dans les données reçues.");
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
