import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/farisnana_controller.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/progress_dialog.dart';
import '../../widgets/empty_box_widget.dart';
import 'explore_offers_page.dart';
import 'liste_faris_nana_achat.dart';

class FarisNanaAchatPage extends StatefulWidget {
  final String? codeArticle; // Code de l'article souscrit
  final bool openDetailAfterLoad; // Flag pour ouvrir directement DetailArticle

  const FarisNanaAchatPage({Key? key, this.codeArticle, this.openDetailAfterLoad = false})
      : super(key: key);

  @override
  _FarisNanaAchatPageState createState() => _FarisNanaAchatPageState();
}

class _FarisNanaAchatPageState extends State<FarisNanaAchatPage> {
  final FarisnanaController _farisnanaController = Get.put(FarisnanaController());
  late Future<List<dynamic>> _achatsFuture;
  List<dynamic> achats = [];
  late TextEditingController codeArticleTextEditingController;

  @override
  void initState() {
    super.initState();
    codeArticleTextEditingController = TextEditingController();

    // Si un code est fourni, préremplir et lancer la validation
    if (widget.codeArticle != null && widget.codeArticle!.isNotEmpty) {
      codeArticleTextEditingController.text = widget.codeArticle!;
      // Retirez ou commentez cette ligne pour éviter une validation automatique
      // WidgetsBinding.instance.addPostFrameCallback((_) => validateForm());
    }
    _achatsFuture = _farisnanaController.getListeAchat();
    _loadAchats();
  }

  @override
  void dispose() {
    codeArticleTextEditingController.dispose();
    super.dispose();
  }

  Future<void> _loadAchats() async {
    try {
      achats = await _achatsFuture;

      // Supprimez ou commentez ce bloc qui déclenche la redirection automatique :
      /*
    if (widget.openDetailAfterLoad && widget.codeArticle != null) {
      var achat = achats.firstWhere(
        (a) => a["codeArticle"] == widget.codeArticle,
        orElse: () => null,
      );
      if (achat != null) {
        print("Redirection automatique vers DetailArticle avec idPaiement: ${achat["id"]}");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (c) => DetailArticle(idPaiement: achat["id"])),
          );
        });
        return;
      }
    }
    */

      // Mettez à jour l'affichage sans redirection automatique
      setState(() {});
    } catch (e) {
      print("Erreur lors du chargement des achats : $e");
    }
  }

  Future<void> validateForm() async {
    if (codeArticleTextEditingController.text.isEmpty) {
      showCustomSnackBar(context, "Veuillez entrer un code valide", isError: true);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ProgressDialog(message: "Recherche en cours ...");
        },
      );
      final codeArticle = codeArticleTextEditingController.text.trim();
      Navigator.pop(context); // Ferme le ProgressDialog
      await _fetchArticleData(codeArticle);
    }
  }

  Future<void> _fetchArticleData(String codeArticle) async {
    try {
      final result = await _farisnanaController.infoArticle(codeArticle);
      if (result.isNotEmpty) {
        // Au lieu de naviguer automatiquement vers InfoArticleSouscription,
        // affichez un message ou mettez à jour l'état pour rester sur FarisNanaAchatPage.
        showCustomSnackBar(context, "Article trouvé !", isError: false);
        // Optionnel : mettre à jour un état pour afficher les infos de l'article sur cette page
      } else {
        showCustomSnackBar(context, "Code de l'article invalide ou indisponible. Réessayez !", isError: true);
      }
    } catch (e) {
      showCustomSnackBar(context, "Une erreur s'est produite : ${e.toString()}", isError: true);
    }
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext infoDialogContext) {
        return AlertDialog(
          title: const Text("Comment obtenir le code de l'article ?", style: TextStyle(fontSize: 15)),
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

  void _showSubscriptionModal() {
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
                label: const Text(
                  "?",
                  style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
                ),
              ),
            ],
          ),
          content: TextField(
            controller: codeArticleTextEditingController,
            keyboardType: TextInputType.text,
            style: const TextStyle(fontSize: 14, color: Colors.orangeAccent),
            decoration: InputDecoration(
              labelText: "Tapez ici le code de l'article",
              hintText: "CODE",
              labelStyle: TextStyle(fontSize: 12, color: Colors.orange.shade800),
              hintStyle: TextStyle(fontSize: 12, color: Colors.orange.shade800),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.orange.shade800),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await validateForm();
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(150, 30),
              ),
              child: const Text(
                'VALIDÉ',
                style: TextStyle(color: Colors.orange, fontSize: 14),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAchatFarisNana() {
    return FutureBuilder<List<dynamic>>(
      future: _achatsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [Center(child: CircularProgressIndicator())],
          );
        } else if (snapshot.hasError) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [Center(child: Text("Une erreur s'est produite ! Veuillez réessayer."))],
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const EmptyBoxWidget(
                    titre: "Pas de souscription en cours !",
                    icon: "assets/icons/iconAchat.png",
                    iconType: "png",
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.to(() => ExploreOffersPage());
                    },
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    label: const Text(
                      "Cliquez ici pour découvrir nos offres",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade800,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          final achats = snapshot.data!;
          return ListView.builder(
            itemCount: achats.length,
            itemBuilder: (context, index) {
              final achat = achats[index];
              return ListeFarisNanaAchat(
                nomclient: achat['nomclient'] ?? '--',
                nomArticle: achat['nomArticle'] ?? '--',
                date_debut: achat['date_debut'] ?? '--',
                date_fin: achat['date_fin'] ?? '--',
                codeArticle: achat['codeArticle'] ?? '--',
                numTelephone: achat['Telephone'] ?? 0,
                status: achat['status'] ?? "0",
                id: achat['id'] ?? 0,
                nbrTranche: achat['nbrTranche'] ?? 0,
                totalPaye: achat['totalPaye'] ?? 0,
                totalRester: achat['totalRester'] ?? 0,
                livraison: achat['livraison'] ?? 0,
                imageArticle: achat['imageArticle'] ?? "--",
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Liste de vos achats",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orangeAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExploreOffersPage()),
          );
        },
        label: Row(
          children: const [
            Icon(Icons.add, color: Colors.white),
            Text("Souscrire", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _achatsFuture = _farisnanaController.getListeAchat();
          });
          await _loadAchats();
        },
        child: _buildAchatFarisNana(),
      ),
    );
  }
}
