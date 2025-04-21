import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../theme/theme_color.dart';
import '../../../widgets/empty_box_widget.dart';
import '../../../widgets/titre_faris_nana.dart';
import 'add_faris_depot_achat.dart';
import 'faris_Depot_controller.dart';
import 'farisnana_depot_controller.dart';
import 'liste_faris_depot_nana.dart';


class FarisNanaDepotPage extends StatefulWidget {
  @override
  _FarisNanaDepotPageState createState() => _FarisNanaDepotPageState();
}

class _FarisNanaDepotPageState extends State<FarisNanaDepotPage> {
  final FarisDepotController _FarisDepotController = Get.put(FarisDepotController());
  final FarisnanaDepotController _farisnanaDepotController = Get.put(FarisnanaDepotController());

  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  //Fonction de recuperation des info sur une Depot
  Future<void> _fetchArticleData(String codeArticle) async {
    try {
      List<dynamic> result = await _FarisDepotController.infoArticle(codeArticle);


    } catch (e) {
      _showCustomSnackBar("Une erreur s'est produite : ${e.toString()}", isError: true);
    }
  }

  void _showCustomSnackBar(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: isError ? Colors.orangeAccent : Colors.green,
      duration:  Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  //Affichage du modal en cas d'erreur ou perte de connexion avec redirection
  AlertDialog _showErrorModal(String message) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Row(
        children: [
          Icon(Icons.error, color: Colors.orangeAccent, size: 30),
          SizedBox(width: 10),
          Text("Désolé !"),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style:  TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
        ],
      ),
      actions: [
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children:  [
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
//Widget de recuperation et affichage des Depots soumises
  Widget _buildDepotArticles() {
    return Column(
      children: [
        Container(
          height: 70,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orangeAccent,
                Colors.orange,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius:  BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
        SizedBox(height: 40),
        TitreFarisNana(titre: "Mes dépôt-ventes soumis"),
        Expanded(
          child: Padding(
            padding:  EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: FutureBuilder<List<dynamic>>(
              future: _farisnanaDepotController.getListeDepot(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return  Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return _showErrorModal("Une erreur s'est produite lors du chargement des données.");
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return  Center(
                    child: EmptyBoxWidget(
                      titre: "Pas de Depot en cours !",
                      icon: "assets/icons/icondemande.png",
                      iconType: "png",
                    ),
                  );
                } else {
                  return RefreshIndicator(

                    onRefresh: () async {
                      await _farisnanaDepotController.getListeDepot();
                      setState(() {}); // Force un rafraîchissement de la page
                    },
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var article = snapshot.data![index];

                        if (article is Map<String, dynamic>) {
                          var date = DateTime.tryParse(article['created_at'] ?? '');
                          var formattedDate = date != null
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
                }
              },
            ),
          ),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ Fond blanc pour correspondre à AddFarisNanaAchat
      appBar: AppBar(
        title: Text(
          "FARIS NANA",
          style: TextStyle(
            color: Colors.white, // ✅ Texte blanc pour plus de lisibilité
            fontSize: 20,
            fontFamily: GoogleFonts.lato(fontWeight: FontWeight.w800).fontFamily,
          ),
        ),
        backgroundColor: Colors.orange, // ✅ Uniformisation avec AddFarisNanaAchat
        elevation: 0,
        iconTheme:  IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black, // ✅ Uniformisation avec AddFarisNanaAchat
        onPressed: () {
          Get.to(() => AddFarisDepotAchat());
        },
        label: Row(
          children:  [
            Icon(Icons.add, color: Colors.white),
            SizedBox(width: 5),
            Text("Ajouter un dépôt-vente", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 40),
          TitreFarisNana(titre: "Mes dépôt_ventes soumis"),
          Expanded(
            child: Padding(
              padding:  EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: FutureBuilder<List<dynamic>>(
                future: _farisnanaDepotController.getListeDepot(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return  Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return _showErrorModal("Une erreur s'est produite lors du chargement des données.");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return  Center(
                      child: EmptyBoxWidget(
                        titre: "Vous n'avez pas encore fait de Depot!",
                        icon: "assets/images/empty.png",
                        iconType: "png",
                      ),
                    );
                  } else {
                    return RefreshIndicator(
                      onRefresh: () async {
                        await _farisnanaDepotController.getListeDepot();
                        setState(() {}); // ✅ Rafraîchissement des données
                      },
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          var article = snapshot.data![index];

                          if (article is Map<String, dynamic>) {
                            var date = DateTime.tryParse(article['created_at'] ?? '');
                            var formattedDate = date != null
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
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Modification des couleurs des statuts
  Widget _buildStatusWidget(int status) {
    Color bgColor;
    String statusText;

    switch (status) {
      case 0:
        bgColor = Colors.orange; // 🟠 Orange pour "En cours"
        statusText = "En cours";
        break;
      case 1:
        bgColor = Colors.green; // ✅ Vert pour "Disponible"
        statusText = "Disponible";
        break;
      default:
        bgColor = Colors.grey; // ⚪ Gris pour état inconnu
        statusText = "Inconnu";
        break;
    }

    return Container(
      padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        statusText,
        style: TextStyle(color: bgColor, fontWeight: FontWeight.bold),
      ),
    );
  }

}