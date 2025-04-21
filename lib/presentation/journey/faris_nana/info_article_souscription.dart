import 'dart:convert';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:faris/common/app_constant.dart';
import 'package:faris/presentation/journey/faris_nana/faris_nana_acceuil.dart';
import 'package:faris/presentation/journey/faris_nana/faris_nana_achat_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../controller/farisnana_controller.dart';
import '../../../controller/user_controller.dart';
import '../../theme/theme_color.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/progress_dialog.dart';
import 'package:video_player/video_player.dart';
import 'import_video_page.dart';
import 'liste_paiement_faris_nana.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

class InfoArticleSouscription extends StatefulWidget {
  final String codeArticle;

  const InfoArticleSouscription({Key? key, required this.codeArticle}) : super(key: key);

  @override
  State<InfoArticleSouscription> createState() => _InfoArticleSouscriptionState();
}

class _InfoArticleSouscriptionState extends State<InfoArticleSouscription> {
  bool isLoadingVideo = false; // loader vidéo
  String? videoUrl; // ✅ Ajouté ici
  List<Map<String, dynamic>>? listepaiementData;
  List<dynamic>? articleData;
  late Future<void> _futureArticleData;
// Déclaration des variables
  bool _includeDeliveryFees = false; // Pour gérer l'état du bouton à cocher
  double deliveryFees = 1000.0; // Montant des frais de livraison

  VideoPlayerController? _videoController;
  Future<void>? _initializeVideoPlayerFuture;
  bool showVideo = false;

  int _tranchePaiements = 1; // Initialisation avec la première tranche
  late String dateDebut;
  late String dateFin;
  late int nbrTranche;
  late int articleId;
  late double prix = 0.0;
  late double montantPartranche = 0.0; // Déclarer en double
  TextEditingController _beginDateController = TextEditingController();
  //TextEditingController _endDateController = TextEditingController();
// Widget du bouton "Souscrire et payer à tempérament"
  Widget _buildSubscribeButton(Map<String, dynamic> article) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: ElevatedButton.icon(
          onPressed: () {
            _showSubscriptionModal(
                article["id"], article["nom"], article["prix_unitaire"], article["commission"]);
          },
          icon: Icon(Icons.shopping_cart_checkout, color: Colors.white, size: 24), // Icône souscription
          label: Text(
            "Souscrire et payer à tempérament",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.raleway().fontFamily,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade700, // Couleur principale
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20), // Espacement
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25), // Bouton arrondi
            ),
            elevation: 6, // Effet d’ombre moderne
          ),
        ),
      ),
    );
  }

  final _formKey = new GlobalKey<FormState>();
  @override
  @override
  void initState() {
    super.initState();
    // Initialiser la date de début avec la date du jour au format "yyyy-MM-dd"
    _beginDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _futureArticleData = _fetchArticleData(); // Initialise la récupération des données
  }
  Widget _buildHeader(Map<String, dynamic> article) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 100, // Ajustez la hauteur si nécessaire

      child: Column(
        children: [ Text(
          "Détails de l'article",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: GoogleFonts.lato(fontWeight: FontWeight.w800).fontFamily,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Code: ",
                  style: GoogleFonts.lato(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: "${article['code_unique']}",
                  style: GoogleFonts.lato(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            softWrap: true,
            maxLines: null,
          ),
          const SizedBox(height: 5),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Nom: ",
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: "${article['nom']}",
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
                ),
              ],
            ),
            maxLines: 1,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
  void sendSouscriptionEmail(String codeArticle) async {
    final url = Uri.parse('https://apps.farisbusinessgroup.com/api/send_email_souscription.php');

    final body = {
      "code_article": codeArticle,
      "nom_utilisateur": "${Get.find<UserController>().userInfo?.nom ?? ''} ${Get.find<UserController>().userInfo?.prenom ?? ''}",
      "telephone": Get.find<UserController>().userInfo?.telephone ?? "Non renseigné",
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        print("✅ Email de souscription envoyé !");
      } else {
        print("❌ Échec de l'envoi : ${data['message']}");
      }
    } catch (e) {
      print("❌ Exception email souscription : $e");
    }
  }


  //Fonction de recuperation des infos sur l'article
  Future<void> _fetchArticleData() async {
    try {
      FarisnanaController recup = FarisnanaController();
      List<dynamic> result = await recup.infoArticle(widget.codeArticle);

      setState(() {
        articleData = result.isNotEmpty ? result : [];
        videoUrl = articleData![0]['video_article'];
        if (videoUrl != null && videoUrl!.isNotEmpty) {
          // Ne pas initialiser ici, on le fera uniquement à la demande
        }
      });

      if (result.isEmpty) {
        _showErrorDialog("Code de l'article invalide \n Veuillez réessayer !!!");
        showCustomSnackBar(context, "Article non trouvé", isError: true);
      }
    } catch (e) {
      setState(() {
        articleData = [];
      });
      print('Erreur lors de la récupération des données : $e');
    }
  }

  Widget _buildAvailabilityBadge(int quantite) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          quantite >= 1 ? Icons.check_circle : Icons.cancel,
          color: quantite >= 1 ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            quantite >= 1 ? "Disponible en stock" : "Stock épuisé",
            style: TextStyle(
              color: quantite >= 1 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

//Fonction de redicrection vers la liste de paiement
  //Recuperation et initialisation des donnees
  Future<void> _initialisationData(id,nomArticle) async {
    try {
      print("---------------------------------#####");
      print(id);
      print(nomArticle);
      FarisnanaController recup = FarisnanaController();
      List<dynamic> result = await recup.infoArticlePaiement(id);

      if (result.isNotEmpty) {
        setState(() {
          listepaiementData = (result[2] as List<dynamic>?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList();

        });
        print("####################CONTENU LISTE PAIEMENT###################");
        print(listepaiementData);
        // Redirection en dehors du setState
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => ListePaiementFarisNana(
              paiements: listepaiementData!,
              nomArticle: nomArticle,
              id: id,
            ),
          ),
        );

      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => FarisNanaAchatPage()));

        showCustomSnackBar(context, "Une erreur s'est produite", isError: true);
      }
    } catch (e) {
      setState(() {
        listepaiementData = [];
      });
      print('Erreur lors de la récupération des données : $e');
    }
  }
  //Fonction affichage du modal
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Erreur"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Get.off(() => FarisNanaAcceuil()), // GetX simplifie la navigation
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
  // Fonction pour sélectionner une date et mettre à jour le contrôleur

  Future<void> _selectDate(BuildContext context, TextEditingController controller,
      {DateTime? startDate}) async {
    // Date minimale (7 jours après la date de début si définie)
    DateTime now = DateTime.now();
    DateTime firstDate = startDate?.add(Duration(days: 3)) ?? now.add(Duration(days: 0));

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: now.add(Duration(days: 365)), // Limite : 1 an après aujourd'hui
      locale: const Locale("fr", "FR"), // Format français
    );

    if (pickedDate != null) {
      // Formatage de la date au format ISO 8601 (yyyy-MM-dd)
      controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  //Fonction de calcul de tranche
  void _initialisationTranche(var prixUnitaire, var tranchePaiements, var commission) {
    double prixUnitaireDouble = double.parse(prixUnitaire.toString());
    double commissionDouble = double.parse(commission.toString());
    double additionalFees = _includeDeliveryFees ? deliveryFees : 0.0;

    if (tranchePaiements == null || tranchePaiements == 0) {
      print("Erreur : Le nombre de tranches est invalide !");
      return;
    }

    var result = ((prixUnitaireDouble + additionalFees) / tranchePaiements).ceilToDouble();

    setState(() {
      prix = result;
    });

    print("Montant par tranche: $prix");
  }
  //Fonction du modal pour souscription
  void _showSubscriptionModal(int id, nomArticle, prixUnitaire, commission) {
    // Calcul initial du montant par tranche en utilisant la valeur actuelle
    double localPrix = ((double.parse(prixUnitaire.toString()) +
        (_includeDeliveryFees ? deliveryFees : 0)) /
        _tranchePaiements)
        .ceilToDouble();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            // Fonction locale pour recalculer le montant par tranche
            void recalc() {
              localPrix = ((double.parse(prixUnitaire.toString()) +
                  (_includeDeliveryFees ? deliveryFees : 0)) /
                  _tranchePaiements)
                  .ceilToDouble();
            }

            return AlertDialog(
              title: Text(
                "Souscrire à un Achat",
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: GoogleFonts.raleway(fontWeight: FontWeight.w900)
                      .fontFamily,
                ),
              ),
              content: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Choisir le nombre de tranches",
                        style: TextStyle(
                          color: AppColor.kTontinet_secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: "Nombre de tranches",
                          border: OutlineInputBorder(),
                        ),
                        value: _tranchePaiements,
                        onChanged: (int? value) {
                          if (value != null) {
                            setStateDialog(() {
                              _tranchePaiements = value;
                              recalc();
                            });
                          }
                        },
                        items: List.generate(12, (index) {
                          final tranches = index + 1;
                          return DropdownMenuItem<int>(
                            value: tranches,
                            child: Text('$tranches tranches'),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 5),
                      // Champ de sélection de date de début
                      _buildDatePickerField(
                        label: "Date de début",
                        controller: _beginDateController,
                        onTap: () async {
                          await _selectDate(context, _beginDateController);
                          // Si la date influence le calcul, on peut également appeler recalc()
                          setStateDialog(() {
                            // par exemple, on ne modifie pas localPrix ici
                          });
                        },
                      ),
                      const SizedBox(height: 5),
                      /* // Checkbox "Inclure les frais de livraison"
                      CheckboxListTile(
                        title: const Text(
                          "Inclure les frais de livraison (1000 FCFA)",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColor.kTontinet_secondary,
                          ),
                        ),
                        value: _includeDeliveryFees,
                        onChanged: (bool? value) {
                          setStateDialog(() {
                            _includeDeliveryFees = value ?? false;
                            recalc();
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: Colors.orange,
                      ),*/
                      const SizedBox(height: 5),
                      // Affichage automatique du montant par tranche
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Montant par tranche: ${localPrix.toStringAsFixed(0)} F",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _includeDeliveryFees ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    // Validation des dates
                    if (_beginDateController.text.isEmpty) {
                      showCustomSnackBar(context, "Veuillez saisir une date de début valide", isError: true);
                      return;
                    }

                    DateTime startDate = DateTime.parse(_beginDateController.text);
                    //DateTime endDate = DateTime.parse(_endDateController.text);

                    // La date de fin doit être au moins 7 jours après la date de début
                    /*if (endDate.isBefore(startDate.add(Duration(days: 7)))) {
      showCustomSnackBar(
        context,
        "La date de fin doit être au moins 2 jours après la date de début",
        isError: true,
      );
      return;
    }*/

                    // Validation réussie, envoyer les données
                    try {
                      print("datedatedatedatedatedatedatedatedatedatedatedatedatedatedatedated");
                      DateTime startDate = DateTime.parse(_beginDateController.text);
                      // Reconstruire une date sans heure
                      DateTime dateOnly = DateTime(startDate.year, startDate.month, startDate.day);
                      print(dateOnly);
                      showDialog(
                        context: context,
                        builder: (BuildContext c) {
                          return ProgressDialog(message: "Chargement en cours ...");
                        },
                      );

                      // Assignation des valeurs
                      setState(() {
                        dateDebut = _beginDateController.text;
                        //dateFin = _endDateController.text;
                        nbrTranche = _tranchePaiements;
                        articleId = id;
                      });

                      print("datebebut:${dateDebut}");
                      //print("dateFin:${dateFin}");
                      print("nbrTrabche:${nbrTranche}");
                      print("articleID:${id}");
                      var results = await FarisnanaController().ajoutAchatArticle(
                        dateDebut,
                        nbrTranche,
                        widget.codeArticle,
                        articleId,
                      );

                      //Navigator.pop(context); // Fermer la boîte de chargement
                      if (results == 1) {
                        sendSouscriptionEmail(widget.codeArticle);
                        Navigator.pop(context); // Fermer le ProgressDialog

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              backgroundColor: Colors.white,
                              title: Text(
                                "Souscription réussie !",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              content: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    text: "Votre souscription a été enregistrée avec succès. Cliquez sur '",
                                    style: TextStyle(fontSize: 16, color: Colors.black87),
                                    children: [
                                      TextSpan(
                                        text: "Voir souscriptions",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: "' pour consulter la liste de vos souscriptions et commencer à payer.",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Fermer le dialog
                                  },
                                  child: Text(
                                    "Fermer",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Fermer le dialog
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FarisNanaAchatPage(
                                          codeArticle: widget.codeArticle,
                                          openDetailAfterLoad: false,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    "Voir souscriptions",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                      else if (results == 403) {
                        Navigator.pop(context); // Fermer la boîte de chargement
                        showCustomSnackBar(
                          context,
                          "Le stock de cet article est epuisé !!",
                          isError: true,
                        );
                      } else if (results == 405) {
                        print(_tranchePaiements);
                        Navigator.pop(context); // Fermer la boîte de chargement
                        showCustomSnackBar(
                            context,
                            "Vous avez déjà souscrit pour payer cet article, vous pouvez le voir dans la liste des 'Achats en cours'",
                            isError: true,
                            duration: Duration(seconds: 5)
                        );

                      } else {
                        Navigator.pop(context);
                        showCustomSnackBar(
                          context,
                          "Une erreur s'est produite",
                          isError: true,
                        );
                      }
                    } catch (e) {
                      Navigator.pop(context); // Fermer la boîte de chargement
                      showCustomSnackBar(
                        context,
                        "Une erreur s'est produite : ${e.toString()}",
                        isError: true,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    elevation: 5.0,
                    //fixedSize: const Size(200, 35),
                  ),
                  child: const Text(
                    'VALIDER',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
// Fonction pour construire le champ de sélection de date
  Widget _buildDatePickerField({
    required String label,
    required TextEditingController controller,
    required Function() onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                color: AppColor.kTontinet_secondary,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: onTap,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                filled: true,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(10.0),
                hintText: "Sélectionner une date",
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
                suffixIcon: const Icon(Icons.calendar_today),
                enabled: false, // Empêche l’édition manuelle
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final userId = Get.find<UserController>().userInfo?.id;
    final List<int> utilisateursAutorises = [1169, 37, 0000];

    return WillPopScope(
        onWillPop: () async {
          // Stoppe la vidéo et masque son affichage lors du retour
          _videoController?.pause();
          setState(() => showVideo = false);
          return true;
        },
        child: Scaffold(
          body: FutureBuilder<void>(
            future: _futureArticleData, // Utilise la future initialisée
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Erreur : ${snapshot.error}"));
              } else if (articleData == null || articleData!.isEmpty) {
                return Center(child: Text("Données de l'article introuvables"));
              } else {
                final article = articleData![0]; // Accès au premier élément
                return Container(
                    height: MediaQuery.of(context).size.height,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 190,
                            //color: Colors.grey,
                            child: Stack(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 150,
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [
                                        Colors.orangeAccent,
                                        AppColor.kTontinet_secondary_dark,
                                      ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))
                                  ),
                                ),
                                Positioned(
                                    top: 20,
                                    child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        height: 125,
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        _videoController?.pause();        // Met en pause la vidéo
                                                        setState(() => showVideo = false);  // Masque le widget vidéo si besoin
                                                        Get.back();
                                                      },
                                                      icon: Icon(Icons.arrow_back, color: Colors.white),
                                                    ),
                                                    SizedBox(
                                                      width: 180,
                                                      child: Text("Détails de l'article",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20,
                                                            fontFamily:
                                                            GoogleFonts.lato(fontWeight: FontWeight.w800).fontFamily),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10,),
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: "Code: ",
                                                    style: GoogleFonts.lato(
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: "${article['code_unique']}",
                                                    style: GoogleFonts.lato(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              softWrap: true,
                                              maxLines: null,
                                            ),
                                            SizedBox(height: 5),
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: "Nom: ",
                                                    style: GoogleFonts.lato(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: "${article['nom']}",
                                                    style: GoogleFonts.lato(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.greenAccent,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              maxLines: 1,
                                            ),
                                            SizedBox(height: 10,),
                                          ],
                                        )
                                    )
                                ),

                              ],
                            ),
                          ),
                          _buildImageCarousel(article),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (utilisateursAutorises.contains(userId))
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (c) => ImportVideoPage(
                                            codeUnique: article["code_unique"].toString(),
                                          ),
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.upload_file),
                                    label: Text("Import vidéo"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                      elevation: 5,
                                    ),
                                  )
                                else
                                  const SizedBox(),

                                if (videoUrl != null && videoUrl!.isNotEmpty)
                                  isLoadingVideo
                                      ? const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    child: SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                      : ElevatedButton.icon(
                                    onPressed: () async {
                                      setState(() {
                                        isLoadingVideo = true;
                                      });

                                      try {
                                        _videoController = VideoPlayerController.network(videoUrl!);
                                        _initializeVideoPlayerFuture = _videoController!.initialize();
                                        await _initializeVideoPlayerFuture;

                                        _videoController!.setLooping(true);

                                        setState(() {
                                          showVideo = true;
                                          isLoadingVideo = false;
                                        });
                                      } catch (e) {
                                        setState(() {
                                          isLoadingVideo = false;
                                        });
                                        showCustomSnackBar(context, "Erreur lors du chargement de la vidéo", isError: true);
                                      }
                                    },
                                    icon: const Icon(Icons.play_circle, color: Colors.orange),
                                    label: const Text(
                                      "Voir la vidéo",
                                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                      elevation: 5,
                                    ),
                                  )
                              ],
                            ),
                          ),
                          if (showVideo && _initializeVideoPlayerFuture != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                              child: FutureBuilder(
                                future: _initializeVideoPlayerFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.done) {
                                    return AspectRatio(
                                      aspectRatio: _videoController!.value.aspectRatio,
                                      child: Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          VideoPlayer(_videoController!),
                                          _PlayPauseOverlay(controller: _videoController!),
                                          VideoProgressIndicator(_videoController!, allowScrubbing: true),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return Center(child: CircularProgressIndicator());
                                  }
                                },
                              ),
                            ),
                          DottedBorder(
                            borderType: BorderType.RRect,
                            radius: Radius.circular(5),
                            strokeWidth: 2,
                            color: Colors.grey.shade400,
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              margin: EdgeInsets.all(5),
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Prix: ${article["prix_unitaire"]} F",
                                      style: TextStyle(
                                        color: AppColor.kTontinet_primary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 20), // Augmentez la largeur pour ajouter plus d'espace
                                    _buildAvailabilityBadge(article["quantite"]),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          /*Container(
                      height: 70,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5.0,
                                offset: Offset(0, 2)
                            )
                          ]
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("Partenaire: ", style: TextStyle(fontSize: 13, color: AppColor.kTontinet_secondary, fontFamily:
                                    GoogleFonts.lato(fontWeight: FontWeight.w700).fontFamily), maxLines: 1, overflow: TextOverflow.ellipsis,),
                                    SizedBox(height: 5,),
                                    RichText(
                                      text: TextSpan(
                                          text: "${article["partenaire"]}",
                                          style: TextStyle(color: Colors.green, fontSize: 18, fontFamily:
                                          GoogleFonts.lato(fontWeight: FontWeight.w800).fontFamily),
                                          children: [
                                            TextSpan(
                                                text: "",
                                                style: TextStyle(color: Colors.green, fontSize: 15, fontFamily:
                                                GoogleFonts.lato(fontWeight: FontWeight.w800).fontFamily)
                                            )
                                          ]
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                  ],
                                ),
                              )
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.4),),
                          ),
                          Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("Telephone: ", style: TextStyle(fontSize: 13, color: AppColor.kTontinet_secondary, fontFamily:
                                    GoogleFonts.lato(fontWeight: FontWeight.w700).fontFamily), maxLines: 1, overflow: TextOverflow.ellipsis,),
                                    SizedBox(height: 5,),
                                    RichText(
                                      text: TextSpan(
                                          text: "${article["telephone"]}",
                                          style: TextStyle(color: Colors.red, fontSize: 18, fontFamily:
                                          GoogleFonts.lato(fontWeight: FontWeight.w800).fontFamily),
                                          children: [
                                            TextSpan(
                                                text: "",
                                                style: TextStyle(color: Colors.red, fontSize: 15, fontFamily:
                                                GoogleFonts.lato(fontWeight: FontWeight.w800).fontFamily)
                                            )
                                          ]
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                          ),
                        ],
                      ),
                    ),*/
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:  DottedBorder(
                              borderType: BorderType.RRect,
                              radius: Radius.circular(5),
                              strokeWidth: 2,
                              color: Colors.grey.shade400,
                              child: Container(
                                width: double.infinity,
                                margin: EdgeInsets.all(5),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: 300, // Hauteur maximale souhaitée
                                  ),
                                  child: SingleChildScrollView(
                                    child: Text(
                                      (article["description"] != null && article["description"].toString().trim().isNotEmpty)
                                          ? article["description"]
                                          : "Description indisponible",
                                      style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),
                          Container(
                            height: 80,
                            width: 850,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10,),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange.shade700,
                                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                        elevation: 5,
                                      ),
                                      onPressed: () {
                                        _showSubscriptionModal(article["id"], article["nom"], article["prix_unitaire"], article["commission"]);
                                      },
                                      icon: Icon(
                                        Icons.attach_money, // Icône de souscription
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                      label: Text(
                                        "Payer en une seule tranches ou en plusieurs tranches",
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          )
                        ],
                      ),
                    )
                )
                ;
              }
            },
          ),
        )) ;
  }
  Widget _buildImageCarousel(Map<String, dynamic> article) {
    // Nom de domaine des images
    String domaine = AppConstant.HOST + AppConstant.HOST_IMAGE_ARTICLE;

    // Récupération des images
    List<String> imageUrls = [
      article['imageCouverture'] != null && article['imageCouverture']!.isNotEmpty ? domaine + article['imageCouverture']! : "",
      article['imageGauche'] != null && article['imageGauche']!.isNotEmpty ? domaine + article['imageGauche']! : "",
      article['imageDroite'] != null && article['imageDroite']!.isNotEmpty ? domaine + article['imageDroite']! : "",
      article['imageArriere'] != null && article['imageArriere']!.isNotEmpty ? domaine + article['imageArriere']! : "",
      article['imageInterieur'] != null && article['imageInterieur']!.isNotEmpty ? domaine + article['imageInterieur']! : "",
    ];

    // Filtrer pour ne garder que les images valides
    imageUrls = imageUrls.where((url) => url.isNotEmpty).toList();

    // Si aucune image n'est disponible, utiliser une seule image par défaut
    if (imageUrls.isEmpty) {
      imageUrls = [
        "https://via.placeholder.com/300?text=Image+Non+Disponible" // Remplacez par votre image par défaut
      ];
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 250.0,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      items: imageUrls.map((url) {
        return Builder(
          builder: (BuildContext context) {
            return CachedNetworkImage(
              imageUrl: url,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => _buildPlaceholderImage(),
              fit: BoxFit.cover,
            );
          },
        );
      }).toList(),
    );
  }

// Fonction pour afficher une image de remplacement si l'image ne charge pas
  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 250.0,
      color: Colors.grey[300],
      child: Center(
        child: Text(
          "PHOTO NON DISPONIBLE",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

}
class _PlayPauseOverlay extends StatelessWidget {
  final VideoPlayerController controller;
  const _PlayPauseOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.value.isPlaying ? controller.pause() : controller.play();
      },
      child: Stack(
        children: [
          if (!controller.value.isPlaying)
            Center(
              child: Icon(Icons.play_circle_fill, size: 60, color: Colors.white),
            ),
        ],
      ),
    );
  }
}