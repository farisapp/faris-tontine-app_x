import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:faris/presentation/journey/faris_nana/detail_article.dart';
import 'package:faris/presentation/journey/faris_nana/faris_nana_achat_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/app_constant.dart';
import '../../../controller/farisnana_controller.dart';
import '../../../controller/user_controller.dart';
import '../../theme/theme_color.dart';
import '../../widgets/CustomPainer.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/progress_dialog.dart';
import 'liste_paiement_faris_nana.dart';

class ListeFarisNanaAchat extends StatefulWidget {
  final int id;
  final String codeArticle;
  final String nomArticle;
  final String imageArticle;
  final String date_debut;
  final String date_fin;
  final String nomclient;
  final int numTelephone;
  final String nbrTranche;
  final String totalPaye;
  final String totalRester;
  final int livraison;
  final String status;

  const ListeFarisNanaAchat({
    super.key,
    required this.id,
    required this.codeArticle,
    required this.nomArticle,
    required this.date_debut,
    required this.date_fin,
    required this.imageArticle,
    required this.nomclient,
    required this.numTelephone,
    required this.nbrTranche,
    required this.totalPaye,
    required this.totalRester,
    required this.livraison,
    required this.status,
  });

  @override
  State<ListeFarisNanaAchat> createState() => _ListeFarisNanaAchatState();
}

class _ListeFarisNanaAchatState extends State<ListeFarisNanaAchat> {
  //Fonction de suppression demande par l'utilisateur
  Future<void>  _deleteSouscription(id) async {
    print("######################33");
    print(id);
    // Affiche un widget de chargement
    showDialog(
      context: context,
      builder: (BuildContext c) {
        return ProgressDialog(message: "Opération en cours ...");
      },
    );
    try {
      FarisnanaController recup = FarisnanaController();
      int result = await recup.deleteSouscriptionUser(id);

      if (result == 1) {
        Navigator.pop(context);
        //Creation de scnack bar personnalisez
        void showCustomSnackBars(BuildContext context, String message, {bool isError = false}) {
          final snackBar = SnackBar(
            content: Text(
              message,
              style: TextStyle(
                color: isError ? Colors.white: Colors.white, // Couleur du texte
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: isError ? Colors.orangeAccent : Colors.greenAccent, // Couleur de fond
            duration: Duration(seconds: 3),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        //Appel de la fonction de snackbar personnalisez
        showCustomSnackBars(
          context,
          "Opération effectuée avec succès !!!",
          isError: false,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FarisNanaAchatPage()),
        );
      } else {
        Navigator.pop(context);
        //_showErrorDialog("Code de l'article invalide \n Veuillez réessayer !!!");
        showCustomSnackBar(context, "Echec de l'operation !", isError: true);
      }
    } catch (e) {
      print('Erreur lors de la récupération des données : $e');
    }
  }
  String domaine = AppConstant.HOST + AppConstant.HOST_IMAGE_ARTICLE;
  Widget detailWidget({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 30,
                color: Colors.white70,
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          Divider(),
        ],
      ),
    );
  }

  bool _emailSent = false;

  @override
  void initState() {
    super.initState();

    // Si le paiement est terminé, envoyer un email une seule fois
    if (widget.status == "1" && !_emailSent) {
      _emailSent = true;
    }
  }
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: TextButton(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 20,
          shadowColor: widget.status == "0" ? Colors.orange[100] : Colors.green[100],
          minimumSize: const Size.fromHeight(60),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => DetailArticle(idPaiement: widget.id)),
          );
        },
        child: SizedBox(
          width: Get.width,
          child: Container(
            decoration: BoxDecoration(
              color: widget.status == "0" ? Colors.orange[100] : Colors.green[100],
              borderRadius: BorderRadius.circular(20),
            ),
            width: double.infinity,
            child: Stack(
              children: [
                // Contenu principal
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Image et détails de l'article
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.cyan,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                "${domaine + widget.imageArticle}",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${widget.nomArticle}",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColor.kTontinet_secondary_dark,
                                    fontSize: 15,
                                    fontFamily: GoogleFonts.raleway(fontWeight: FontWeight.w900).fontFamily,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "${widget.date_debut}",
                                  style: TextStyle(
                                    color: AppColor.kTontinet_textColor1,
                                    fontSize: 10,
                                    fontFamily: GoogleFonts.lato(fontWeight: FontWeight.w700).fontFamily,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  widget.status == "0"
                                      ? "Vous n'avez pas fini de payer cet article"
                                      : "Paiement terminé",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: widget.status == "0" ? Colors.red : Colors.green,
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  width: 100,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: widget.status == "0" ? Colors.orange : Colors.greenAccent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      widget.status == "0" ? "EN COURS" : "VALIDÉ",
                                      style: TextStyle(
                                        color: widget.status == "0" ? Colors.white : Colors.black,
                                        fontSize: 12,
                                        fontFamily: GoogleFonts.lato(fontWeight: FontWeight.w700).fontFamily,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Nombre de tranches : ${widget.nbrTranche}",
                            style: TextStyle(
                              color: AppColor.kTontinet_secondary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Début ${widget.date_debut}",
                            style: TextStyle(
                              color: AppColor.kTontinet_primary_light,
                              fontSize: 13,
                              fontFamily: GoogleFonts.lato(fontWeight: FontWeight.w700).fontFamily,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
// Code Article
                      Text(
                        "Code Article : ${widget.codeArticle}",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 5),

// Statut livraison
                      Text(
                        "Statut Livraison : ${widget.livraison == 1 ? '✅ Livré' : '🚚 Non livré'}",
                        style: TextStyle(
                          color: widget.livraison == 1 ? Colors.green : Colors.orange,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Nouveau bouton "Effectuer un paiement"
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => ListePaiementFarisNana(
                                paiements: [], // Vous pouvez remplacer [] par la liste des paiements si elle est disponible
                                nomArticle: widget.nomArticle,
                                id: widget.id,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrangeAccent, // Couleur du bouton
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Effectuer un paiement",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Bouton supprimer
                widget.status == "1"
                    ? Positioned(
                  right: 5, // Position en haut à droite
                  top: 5,
                  child: InkWell(
                    onTap: () {
                      // Afficher une boîte de dialogue de confirmation pour supprimer
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Confirmation"),
                          content: Text("Voulez-vous vraiment supprimer cet article ?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Annuler"),
                            ),
                            TextButton(
                              onPressed: () {
                                // Appeler la méthode pour supprimer l'article
                                _deleteSouscription(widget.id);
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Supprimer",
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.status == "0"
                            ? Colors.redAccent
                            : Colors.orangeAccent,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                )
                    : SizedBox.shrink(), // Rien à afficher si la condition est fausse

              ],
            ),
          ),
        ),
      ),
    );

  }
}
