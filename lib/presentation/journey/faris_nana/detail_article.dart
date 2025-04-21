import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:faris/presentation/journey/faris_nana/liste_paiement_faris_nana.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/app_constant.dart';
import '../../../controller/farisnana_controller.dart';
import '../../theme/theme_color.dart';
import '../../widgets/custom_snackbar.dart';
import 'faris_nana_acceuil.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class DetailArticle extends StatefulWidget {
  final int idPaiement;
  const DetailArticle({super.key, required this.idPaiement});

  @override
  State<DetailArticle> createState() => _DetailArticleState();
}

class _DetailArticleState extends State<DetailArticle> {
  List<Map<String, dynamic>>? articleData;
  Map<String, dynamic>? paiementData;
  List<Map<String, dynamic>>? listepaiementData;
  late Future<void> _futureArticleData;

  int _tranchePaiements = 1; // Initialisation avec la première tranche
  late String dateDebut;
  late String dateFin;
  late int nbrTranche;
  late int articleId;

  // Fonction pour afficher "PHOTO" si aucune image n'est disponible
  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 250.0,
      color: Colors.grey[300],
      child: Center(
        child: Text(
          "PHOTO",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  // Fonction pour afficher les images des articles
  Widget _buildImageCarousel(Map<String, dynamic> article) {
    String domaine = AppConstant.HOST + AppConstant.HOST_IMAGE_ARTICLE;

    List<String> imageUrls = [
      article['imageCouverture'] != null
          ? domaine + article['imageCouverture']
          : "",
      article['imageGauche'] != null ? domaine + article['imageGauche'] : "",
      article['imageDroite'] != null ? domaine + article['imageDroite'] : "",
      article['imageArriere'] != null ? domaine + article['imageArriere'] : "",
      article['imageInterieur'] != null
          ? domaine + article['imageInterieur']
          : "",
    ];

    List<String> validImageUrls =
    imageUrls.where((url) => url.isNotEmpty).toList();

    return CarouselSlider(
      options: CarouselOptions(
        height: 250.0,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      items: validImageUrls.isNotEmpty
          ? validImageUrls.map((url) {
        return Builder(
          builder: (BuildContext context) {
            return Image.network(
              url,
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholderImage();
              },
            );
          },
        );
      }).toList()
          : [_buildPlaceholderImage()],
    );
  }

  @override
  void initState() {
    super.initState();
    _futureArticleData = _fetchArticleData(); // Actualisation automatique
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController _telephoneController = TextEditingController();
  TextEditingController _codeController = TextEditingController();
  List<Map<String, String>> providers = [
    {
      "libelle": "Orange Money",
      "slug": "orange money",
      "logo": "assets/images/orange_money.png"
    },
  ];

  String _selectedProvider = "orange money";
  void setProvider(String provider) {
    _selectedProvider = provider;
  }

  Future<void> _callNumber(String montant) async {
    String ussdCode = '*144*4*6*$montant#';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Code USSD", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.orange.shade50,
                ),
                child: Text(
                  ussdCode,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.blue),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: ussdCode));
                      Navigator.pop(context);
                      showCustomSnackBar(context, "Code copié dans le presse-papiers", isError: false);
                    },
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: ussdCode));
                      Navigator.pop(context);
                      showCustomSnackBar(context, "Code copié. Veuillez le coller dans l'application Téléphone.", isError: false);
                    },
                    icon: const Icon(Icons.call),
                    label: const Text("Copier et appeler"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fermer", style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  Future<void> validForm(id, montant, reqId, transId) async {
    try {
      int result = await FarisnanaController().updatePaiement(
        id,
        montant,
        _selectedProvider,
        _codeController.text,
        _telephoneController.text,
        transId,
        reqId,
      );

      if (result == 1) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 30),
                  SizedBox(width: 10),
                  Text("Félicitations !"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Félicitation votre paiement a été affectué avec succès !!!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
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
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                DetailArticle(idPaiement: widget.idPaiement)),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, color: Colors.white),
                        SizedBox(width: 5),
                        Text("Valider"),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        Navigator.pop(context);
        showCustomSnackBar(context, "Une erreur s'est produite ");
        showCustomSnackBar(
            context, "Echec de la transaction. Veuillez recommencer");
      }
    } catch (e) {
      Navigator.pop(context);
      showCustomSnackBar(context, "Une erreur s'est produite : ${e.toString()}",
          isError: true);
    }
  }

  Future<void> _fetchArticleData() async {
    try {
      FarisnanaController recup = FarisnanaController();
      List<dynamic> result = await recup.infoArticlePaiement(widget.idPaiement);

      if (result.isNotEmpty) {
        setState(() {
          paiementData = result[0] as Map<String, dynamic>?;
          articleData = (result[1] as List<dynamic>?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList();
          listepaiementData = (result[2] as List<dynamic>?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList();
          print("tSTATUS");
          print(paiementData?["status"]);
        });
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => FarisNanaAcceuil()));
        _showErrorDialog("Une erreur s'est produite \n Veuillez réessayer !!!");
        showCustomSnackBar(context, "Article non trouvé", isError: true);
      }
    } catch (e) {
      setState(() {
        paiementData = null;
        articleData = [];
        listepaiementData = [];
      });
      print('Erreur lors de la récupération des données : $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Hum"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => FarisNanaAcceuil()),
                );
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text("Félicitations !"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
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
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            DetailArticle(idPaiement: widget.idPaiement)),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: Colors.white),
                    SizedBox(width: 5),
                    Text("Valider"),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  int getMontant(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.floor();
    if (value is String) {
      value = value.replaceAll(RegExp(r'[^\d.]'), '');
      double? parsedValue = double.tryParse(value);
      return parsedValue != null ? parsedValue.floor() : 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: FutureBuilder<void>(
          future: _futureArticleData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Erreur : ${snapshot.error}"));
            } else if (articleData == null || articleData!.isEmpty) {
              return Center(child: Text("Données de l'article introuvables"));
            } else {
              final article = articleData![0];
              final paiement = paiementData![0];
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.orange.shade700,
                    pinned: true,
                    title: Column(
                      children: [
                        Text(
                          'Nana Shop',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 25),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _futureArticleData = _fetchArticleData();
                          });
                        },
                        icon: Icon(Icons.refresh, color: Colors.white),
                        label: Text("Actualiser", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                        height: MediaQuery.of(context).size.height,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(
                                    'Code : ',
                                    style: GoogleFonts.lato(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${article['code_unique']}",
                                    style: GoogleFonts.lato(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Nom : ',
                                    style: GoogleFonts.lato(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${article['nom']}",
                                    style: GoogleFonts.lato(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 10),
                              _buildImageCarousel(article),
                              DottedBorder(
                                borderType: BorderType.RRect,
                                radius: Radius.circular(5),
                                strokeWidth: 2,
                                color: Colors.grey,
                                child: Container(
                                  height: 60,
                                  width: double.infinity,
                                  margin: EdgeInsets.all(5),
                                  padding: EdgeInsets.only(left: 5, right: 5),
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade400,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: "Prix total: ",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                          fontFamily: GoogleFonts.lato(
                                                              fontWeight: FontWeight.w700)
                                                              .fontFamily,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                        "${getMontant(article?["prix_unitaire"])} F",
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 15,
                                                          fontFamily: GoogleFonts.lato(
                                                              fontWeight: FontWeight.w800)
                                                              .fontFamily,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              height: 25,
                                              width: 1,
                                              color: Colors.white.withOpacity(0.7),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  RichText(
                                                      text: TextSpan(
                                                          text: "Quantité disponible: ",
                                                          style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.bold),
                                                          children: [
                                                            TextSpan(
                                                                text: "${article["quantite"]}",
                                                                style: TextStyle(
                                                                    color: AppColor.kTontinet_primary,
                                                                    fontSize: 15,
                                                                    fontFamily: GoogleFonts.lato(
                                                                        fontWeight: FontWeight.w800)
                                                                        .fontFamily))
                                                          ])),
                                                  SizedBox(height: 10),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                ),
                              ),
                              SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade700,
                                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 16,
                                    shadowColor: Colors.black.withOpacity(0.8),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ListePaiementFarisNana(
                                          paiements: listepaiementData!,
                                          nomArticle: article["nom"],
                                          id: paiementData?["id"],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.attach_money, color: Colors.white, size: 18),
                                      SizedBox(width: 10),
                                      Text(
                                        "Faire un paiement",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                height: 50,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 5.0,
                                          offset: Offset(0, 2))
                                    ]),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              RichText(
                                                text: TextSpan(
                                                  text: (paiementData?['status'] == '1')
                                                      ? "PAIEMENT TERMINÉ\n"
                                                      : "PAIEMENT EN COURS\n",
                                                  style: TextStyle(
                                                    color: (paiementData?['status'] == '1')
                                                        ? Colors.greenAccent
                                                        : Colors.redAccent,
                                                    fontSize: 14,
                                                    fontFamily: GoogleFonts.lato(fontWeight: FontWeight.w800)
                                                        .fontFamily,
                                                  ),
                                                  children: [],
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        )),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height: 15,
                                        width: 1,
                                        color: Colors.grey.withOpacity(0.4),
                                      ),
                                    ),
                                    Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              RichText(
                                                text: TextSpan(
                                                  text: paiementData?["livraison"] == 0
                                                      ? "NON LIVRÉ"
                                                      : "LIVRÉ",
                                                  style: TextStyle(
                                                    color: paiementData?["livraison"] == 0
                                                        ? Colors.red
                                                        : Colors.green,
                                                    fontSize: 14,
                                                    fontFamily: GoogleFonts.lato(fontWeight: FontWeight.w800)
                                                        .fontFamily,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: "",
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 14,
                                                        fontFamily: GoogleFonts.lato(fontWeight: FontWeight.w800)
                                                            .fontFamily,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                              Container(
                                height: 60,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5.0,
                                      offset: Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Total à payer",
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: AppColor.kTontinet_secondary,
                                              fontFamily: GoogleFonts.lato(fontWeight: FontWeight.w700)
                                                  .fontFamily,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            "${getMontant(paiementData?["totalPaye"]?.toString())} F",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 15,
                                              fontFamily: GoogleFonts.lato(fontWeight: FontWeight.w800)
                                                  .fontFamily,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                        height: 40,
                                        width: 1,
                                        color: Colors.grey.withOpacity(0.4)),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Déjà payé",
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: AppColor.kTontinet_secondary,
                                              fontFamily: GoogleFonts.lato(fontWeight: FontWeight.w700)
                                                  .fontFamily,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            "${getMontant(paiementData?["totalRester"]?.toString())} F",
                                            style: TextStyle(
                                              color: Colors.greenAccent,
                                              fontSize: 15,
                                              fontFamily: GoogleFonts.lato(fontWeight: FontWeight.w800)
                                                  .fontFamily,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                height: 40,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 5.0,
                                          offset: Offset(0, 2))
                                    ]),
                                child: Center(
                                  child: Text(
                                    "Date de début du paiement: ${paiementData?["date_debut"]}",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: AppColor.kTontinet_secondary,
                                        fontFamily: GoogleFonts.lato(fontWeight: FontWeight.w800)
                                            .fontFamily),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        )),
                  ),
                ],
              );
            }
          }),
    );
  }
}
