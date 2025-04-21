import 'package:dotted_border/dotted_border.dart';
import 'package:faris/common/app_constant.dart';
import 'package:faris/presentation/journey/tontine/col_retirer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:faris/common/common.dart';
import 'package:faris/controller/auth_controller.dart';
import 'package:faris/controller/tontine_details_controller.dart';
import 'package:faris/controller/user_controller.dart';
import 'package:faris/data/models/membre_model.dart';
import 'package:faris/data/models/periodicite_model.dart';
import 'package:faris/data/models/tontine_model.dart';
import 'package:faris/presentation/journey/contact/contact_page.dart';
import 'package:faris/presentation/journey/tontine/cotiser_page.dart';
import 'package:faris/presentation/journey/tontine/stat_page.dart';
import 'package:faris/presentation/theme/theme_color.dart';
import 'package:faris/presentation/widgets/app_error_widget.dart';
import 'package:faris/presentation/widgets/cotisation_card_widget.dart';
import 'package:faris/presentation/widgets/custom_snackbar.dart';
import 'package:faris/presentation/widgets/membre_card_widget.dart';
import 'package:faris/presentation/widgets/round_textbutton.dart';
import 'package:faris/presentation/widgets/empty_box_widget.dart';
import 'package:jiffy/jiffy.dart';
import 'package:share_plus/share_plus.dart';

class TontineDetailsPage extends StatefulWidget {
  final Tontine tontine;

  const TontineDetailsPage({Key? key, required this.tontine}) : super(key: key);

  @override
  _TontineDetailsPageState createState() => _TontineDetailsPageState();
}

class _TontineDetailsPageState extends State<TontineDetailsPage> {

  _TontineDetailsPageState();

  AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver;
    initJiffy();
    getData(false);
  }

  initJiffy() async {
    await Jiffy.setLocale("fr");
  }

  getData(bool reload) async {
    await Get.find<TontineDetailsController>().getTontineDetails(widget.tontine.id, reload);
    await Get.find<TontineDetailsController>().getTontineMembres(widget.tontine.id, reload);
    await Get.find<TontineDetailsController>().getTontineRequetes(widget.tontine.id, reload);
    await Get.find<TontineDetailsController>().getTontinePeriodicites(widget.tontine.id, reload);
    await Get.find<TontineDetailsController>().getTontinePeriodicitesToPaid(widget.tontine.id, true);
    if(Get.find<AuthController>().isLoggedIn()) {
      await Get.find<UserController>().getUserInfo();
    }
    // Vérifie et notifie s'il y a de nouvelles demandes
    if (Get.find<TontineDetailsController>().requeteList!.isNotEmpty) {
      showCustomSnackBar(
        context,
        "Vous avez ${Get.find<TontineDetailsController>().requeteList!.length} nouvelle(s) demande(s) de participation.",
        isError: false,
        duration: Duration(seconds: 10), // Durée personnalisée de 5 secondes
      );
    }


  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: GetBuilder<UserController>(builder: (userController) {
        return GetBuilder<TontineDetailsController>(builder: (detailController) {
          if(detailController.tontineLoaded){
            if(detailController.tontine != null){
              bool _hasNewNotification = false;
              if (detailController.requeteList != null) {
                _hasNewNotification = detailController.requeteList!.length != 0;
              }
              return RefreshIndicator(
                onRefresh: () async {
                  await getData(true);
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Bouton pour partager la tontine

                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 250,
                        //color: Colors.grey,
                        child: Stack(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 200,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    AppColor.kTontinet_primary_light,
                                    AppColor.kTontinet_secondary_dark,
                                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))
                              ),
                            ),
                            Positioned(
                              top: 30,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 120,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: () => Get.back(),
                                              icon: Icon(Icons.arrow_back, color: Colors.white),
                                            ),
                                            SizedBox(
                                              width: 150,
                                              child: Text(
                                                "${detailController.tontine?.libelle ?? ""}",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontFamily: GoogleFonts.lato(fontWeight: FontWeight.w800).fontFamily,
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacer(),
                                        // Bouton demandes de participation avec badge
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center, // Centre les éléments dans la colonne
                                          children: [
                                            // Icône "demandes de participation"
                                            Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                Center(
                                                  child: IconButton(
                                                    icon: Icon(
                                                      Icons.group,
                                                      color: Colors.yellow,
                                                      size: 30, // Taille de l'icône
                                                    ),
                                                    onPressed: () async {
                                                      await _buildRequeteTontineList();
                                                    },
                                                  ),
                                                ),
                                                if (detailController.requeteList != null &&
                                                    detailController.requeteList!.isNotEmpty)
                                                  Positioned(
                                                    right: 40,
                                                    top: -6,
                                                    child: Container(
                                                      padding: EdgeInsets.all(4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Text(
                                                        "${detailController.requeteList!.length}",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            SizedBox(height: 1), // Espacement entre l'icône et le texte
                                            // Texte du label qui revient à la ligne
                                            SizedBox(
                                              width: 120, // Définir une largeur fixe pour permettre le retour à la ligne
                                              child: Text(
                                                "Demandes de participation",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center, // Centre le texte
                                                maxLines: 2, // Autorise jusqu'à 2 lignes
                                                overflow: TextOverflow.visible, // Le texte revient à la ligne
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [detailController.tontine?.statut != "RUNNING"
                                              ? Column(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: Colors.yellow,
                                                ),
                                                onPressed: () async {
                                                  _confirmTontineDelete(detailController.tontine!.id!);
                                                },
                                              ),
                                              Text(
                                                "Supprimer", // Label rouge sous le bouton
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          )
                                              : const SizedBox.shrink(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Positioned(
                              bottom: -5,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 160,
                                //color: Colors.red,
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: detailController.membres != null ? ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    padding: EdgeInsets.only(left: 20, right: 20),
                                    itemCount: detailController.membres?.length,
                                    itemBuilder: (context, index){
                                      return MembreCardWidget(
                                        membre: detailController.membres?[index],
                                        controller: detailController,
                                        onPress: () async {
                                          // Si l'élément cliqué est le bouton "Ajouter" (représenté par un membre avec id == 0)
                                          if (detailController.membres?[index].id == 0) {
                                            // Calculer le nombre réel de membres ajoutés (excluant l'élément bouton "Ajouter")
                                            int currentMembersCount = detailController.membres!.length - 1;
                                            // Condition : si des paiements ont été effectués ou si le nombre de membres atteint ou dépasse la limite
                                            if (detailController.tontine?.hasPayment == 1 ||
                                                currentMembersCount >= detailController.tontine!.nbrePersonne!) {
                                              showCustomSnackBar(context, "Nombre de membres atteint");
                                            } else {
                                              // Vérifier que l'utilisateur connecté est le créateur pour autoriser l'ajout
                                              if (detailController.tontine?.createur?.id == userController.userInfo!.id) {
                                                Get.to(() => ContactPage(tontine: detailController.tontine!));
                                              } else {
                                                showCustomSnackBar(context, "Vous ne pouvez pas ajouter de membre");
                                              }
                                            }
                                          } else {
                                            // Pour un membre déjà ajouté, afficher ses détails
                                            _buildUserTontineDetails(detailController.tontine!, detailController.membres![index]);
                                          }
                                        },
                                      );
                                    }
                                ) : SizedBox.shrink(),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /*if(detailController.tontine?.createur?.id == userController.userInfo!.id && detailController.tontine?.statut == "FINISHED")...[
                              RoundTextButton(
                                  titre: "Retirer",
                                  backgroundColor: Colors.teal,
                                  textColor: Colors.white,
                                  height: 35,
                                  fontSize: 14,
                                  elevation: 2,
                                  onPressed: () {
                                    Get.to(() => RetirerPage(tontine: detailController.tontine!));
                                  }
                              )
                            ]else ...[

                            ],*/
                            Center(
                              child: Text(
                                "${detailController.tontine?.type}",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                "CODE: ${detailController.tontine?.numero}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Common.getTontineStatutColor(detailController.tontine?.statut),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "${Common.getTontineStatut(detailController.tontine?.statut)}",
                                  style: TextStyle(
                                    color: Common.getTontineStatutColor(detailController.tontine?.statut),
                                    fontSize: 18,
                                    fontFamily: GoogleFonts.lato(fontWeight: FontWeight.w800).fontFamily,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 15),
                              child: SizedBox(
                                height: 35,
                                width: double.infinity, // Largeur maximale
                                child: Center( // Centre tout le contenu
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center, // Centre les boutons horizontalement
                                    children: [
                                      if (userController.userInfo != null) ...[
                                        if (detailController.tontine!.statut == "PENDING" && (detailController.membres != null)) ...[
                                          if (detailController.tontine?.createur?.id == userController.userInfo!.id)
                                            RoundTextButton(
                                              titre: "Lancer la cotisation",
                                              backgroundColor: Colors.orange.shade800,
                                              textColor: Colors.white,
                                              height: 35,
                                              fontSize: 14,
                                              elevation: 2,
                                              onPressed: () {
                                                if (detailController.tontine != null) {
                                                  _confirmTontineRun(detailController.tontine!.id!);
                                                }
                                              },
                                              icon: Icons.attach_money, // Icône pour Cotiser
                                            ),
                                        ] else if (detailController.tontine?.statut == "RUNNING") ...[
                                          if (detailController.tontine?.type == "EPARGNE") ...[
                                            if (detailController.periodiciteToPaidList != null) ...[
                                              if (detailController.periodiciteToPaidList!.isEmpty ) ...[
                                                RoundTextButton(
                                                  titre: "Retirer",
                                                  backgroundColor: Colors.lightGreen,
                                                  textColor: Colors.white,
                                                  height: 35,
                                                  fontSize: 14,
                                                  elevation: 2,
                                                  onPressed: () {
                                                    Get.to(() => ColRetirerPage(tontine: detailController.tontine!));
                                                  },
                                                  icon: Icons.remove_circle_outline, // Icône pour Retirer
                                                ),
                                              ] else ...[
                                                if (detailController.isMembre(userController.userInfo!.id!)) ...[
                                                  RoundTextButton(
                                                    titre: "Cotiser",
                                                    backgroundColor: Colors.orange,
                                                    textColor: Colors.white,
                                                    height: 35,
                                                    fontSize: 14,
                                                    elevation: 2,
                                                    onPressed: () {
                                                      Get.to(() => CotiserPage(tontine: detailController.tontine!));
                                                    },
                                                    icon: Icons.attach_money, // Icône pour Cotiser
                                                  ),
                                                ],
                                              ],
                                            ],
                                          ] else ...[
                                            // Ajoute ce bouton à côté du bouton "Retirer" existant dans TontineDetailsPage
                                            Wrap(
                                              alignment: WrapAlignment.center,
                                              spacing: 10, // espace horizontal entre les boutons
                                              runSpacing: 10, // espace vertical entre les boutons
                                              children: [
                                                RoundTextButton(
                                                  titre: "Cotiser",
                                                  backgroundColor: Colors.orange.shade800,
                                                  textColor: Colors.white,
                                                  height: 35,
                                                  fontSize: 14,
                                                  elevation: 2,
                                                  onPressed: () {
                                                    Get.to(() => CotiserPage(tontine: detailController.tontine!));
                                                  },
                                                  icon: Icons.attach_money,
                                                ),

                                                RoundTextButton(
                                                  titre: "Retirer",
                                                  backgroundColor: Colors.green.shade800,
                                                  textColor: Colors.white,
                                                  height: 35,
                                                  fontSize: 14,
                                                  elevation: 2,
                                                  onPressed: () {
                                                    Get.to(() => ColRetirerPage(tontine: detailController.tontine!));
                                                  },
                                                  icon: Icons.remove_circle_outline,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ] else ...[
                                          Expanded(
                                            child: Center( // Centre le texte au milieu de l'écran
                                              child: Text(
                                                " Tontine clôturée, vous pouvez cliquer en haut à droite sur 'Supprimer' pour le supprimer. Merci",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 11,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                                maxLines: 3,
                                                textAlign: TextAlign.center, // Assure que le texte reste centré
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),
                            Row(
                              children: [
                                // Bouton Bloquer : pour une épargne collective, il affiche un message d'erreur
                                Expanded(
                                  child: RoundTextButton(
                                    titre: "Bloquer",
                                    backgroundColor: Colors.blueGrey,
                                    textColor: Colors.white,
                                    height: 35,
                                    fontSize: 14,
                                    elevation: 2,
                                    icon: Icons.lock,
                                    onPressed: () {
                                      showCustomSnackBar(
                                        context,
                                        "Impossible de bloquer un compte collectif",
                                        isError: true,
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: 10),
                                // Bouton Clôturer / Relancer
                                Expanded(
                                  child: detailController.tontine?.statut == "RUNNING"
                                      ? RoundTextButton(
                                    titre: "Clôturer",
                                    backgroundColor: Colors.red.shade300,
                                    textColor: Colors.white,
                                    height: 35,
                                    fontSize: 14,
                                    elevation: 2,
                                    icon: Icons.close,
                                    onPressed: () async {
                                      // On vérifie que seul l'organisateur peut clôturer
                                      final userId = userController.userInfo?.id;
                                      final createurId = detailController.tontine?.createur?.id;
                                      if (userId != createurId) {
                                        showCustomSnackBar(
                                          context,
                                          "C'est l'organisateur qui peut clôturer cette tontine.",
                                        );
                                        return;
                                      }
                                      // Confirmation
                                      bool? confirm = await Get.defaultDialog<bool>(
                                        title: "Confirmation de clôture",
                                        middleText: "Êtes-vous sûr de vouloir clôturer cette tontine ?",
                                        actions: [
                                          RoundTextButton(
                                            titre: "OUI",
                                            width: 80,
                                            height: 40,
                                            fontSize: 14,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            onPressed: () => Get.back(result: true),
                                          ),
                                          RoundTextButton(
                                            titre: "NON",
                                            width: 80,
                                            height: 40,
                                            fontSize: 14,
                                            backgroundColor: Colors.grey,
                                            textColor: Colors.black,
                                            onPressed: () => Get.back(result: false),
                                          ),
                                        ],
                                      );
                                      if (confirm == true) {
                                        await detailController
                                            .updateStatus(detailController.tontine!.id!, 'FINISHED')
                                            .then((result) {
                                          if (result.isSuccess) {
                                            showCustomSnackBar(context, "La tontine a été clôturée avec succès.", isError: false);
                                            getData(true);
                                          } else {
                                            showCustomSnackBar(context, result.message);
                                          }
                                        });
                                      }
                                    },
                                  )
                                      : RoundTextButton(
                                    titre: "Relancer",
                                    backgroundColor: Colors.green.shade300,
                                    textColor: Colors.white,
                                    height: 35,
                                    fontSize: 14,
                                    elevation: 2,
                                    icon: Icons.play_arrow,
                                    onPressed: () async {
                                      bool? confirm = await Get.defaultDialog<bool>(
                                        title: "Confirmation de relance",
                                        middleText: "Êtes-vous sûr de vouloir relancer cette tontine ?",
                                        actions: [
                                          RoundTextButton(
                                            titre: "RELANCER",
                                            width: 80,
                                            height: 40,
                                            fontSize: 14,
                                            backgroundColor: Colors.green,
                                            textColor: Colors.white,
                                            onPressed: () => Get.back(result: true),
                                          ),
                                          RoundTextButton(
                                            titre: "ANNULER",
                                            width: 80,
                                            height: 40,
                                            fontSize: 14,
                                            backgroundColor: Colors.grey,
                                            textColor: Colors.black,
                                            onPressed: () => Get.back(result: false),
                                          ),
                                        ],
                                      );
                                      if (confirm == true) {
                                        await detailController
                                            .updateStatus(detailController.tontine!.id!, 'RUNNING')
                                            .then((result) {
                                          if (result.isSuccess) {
                                            showCustomSnackBar(context, "La tontine a été relancée avec succès.", isError: false);
                                            getData(true);
                                          } else {
                                            showCustomSnackBar(context, result.message);
                                          }
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Container(
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
                                            Text("Montant cotisé", style: TextStyle(fontSize: 16, color: AppColor.kTontinet_secondary, fontFamily:
                                            GoogleFonts.lato(fontWeight: FontWeight.w700).fontFamily), maxLines: 1, overflow: TextOverflow.ellipsis,),
                                            SizedBox(height: 5,),
                                            RichText(
                                              text: TextSpan(
                                                  text: "${Common.currency_format().format((detailController.tontine?.totalMontantCotise ?? 0) - (detailController.tontine?.montantRetire ?? 0))}",
                                                  style: TextStyle(color: Colors.green, fontSize: 18, fontFamily:
                                                  GoogleFonts.lato(fontWeight: FontWeight.w800).fontFamily),
                                                  children: [
                                                    TextSpan(
                                                        text: " FCFA",
                                                        style: TextStyle(color: Colors.green, fontSize: 16, fontFamily:
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
                                            Text("Paiements en attente", style: TextStyle(fontSize: 16, color: AppColor.kTontinet_secondary, fontFamily:
                                            GoogleFonts.lato(fontWeight: FontWeight.w700).fontFamily), maxLines: 1, overflow: TextOverflow.ellipsis,),
                                            SizedBox(height: 5,),
                                            RichText(
                                              text: TextSpan(
                                                  text: "${Common.currency_format().format(detailController.tontine?.totalMontantRestant)}",
                                                  style: TextStyle(color: Colors.red, fontSize: 18, fontFamily:
                                                  GoogleFonts.lato(fontWeight: FontWeight.w800).fontFamily),
                                                  children: [
                                                    TextSpan(
                                                        text: " FCFA",
                                                        style: TextStyle(color: Colors.red, fontSize: 16, fontFamily:
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
                            ),
                            SizedBox(height: 10,),
                            Container(
                              height: 70,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 5.0,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Montant retiré",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColor.kTontinet_secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  RichText(
                                    text: TextSpan(
                                      text: "${Common.currency_format().format(detailController.tontine?.montantRetire ?? 0)}",
                                      style: TextStyle(
                                        color: Colors.orange.shade700,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: " FCFA",
                                          style: TextStyle(
                                            color: Colors.orange.shade700,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Boutons supplémentaires pour partager
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    final shareContent =
                                        "Bonjour.Je t'invite à participer à une tontine en ligne avec l'application Faris. Pour participer, merci de télécharger l'application sur Playstore (Android) ici: https://play.google.com/store/apps/details?id=com.powersofttechnology.faris ou sur AppStore (Iphone) ici: https://apps.apple.com/bf/app/faris/id6458983816?l=fr-FR . Le code tontine est : ${detailController.tontine?.numero ?? ""}. Economisons ensemble avec Faris!";
                                    Share.share(
                                      shareContent,
                                      subject: "Invitation à une tontine",
                                    );
                                  },
                                  icon: const Icon(Icons.share),
                                  label: const Text("Partager", style: TextStyle(fontWeight: FontWeight.bold),),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white, // Définit la couleur du texte en blanc
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                            // Boutons supplémentaires pour rendre public
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    bool? confirm = await Get.defaultDialog<bool>(
                                      title: "Rendre public",
                                      middleText: "Souhaitez-vous vraiment rendre cette tontine visible publiquement ?",
                                      actions: [
                                        RoundTextButton(
                                          titre: "OUI",
                                          width: 80,
                                          height: 40,
                                          fontSize: 14,
                                          backgroundColor: Colors.purple,
                                          textColor: Colors.white,
                                          onPressed: () => Get.back(result: true),
                                        ),
                                        RoundTextButton(
                                          titre: "NON",
                                          width: 80,
                                          height: 40,
                                          fontSize: 14,
                                          backgroundColor: Colors.grey,
                                          textColor: Colors.black,
                                          onPressed: () => Get.back(result: false),
                                        ),
                                      ],
                                    );

                                    if (confirm == true) {
                                      final result = await Get.find<TontineDetailsController>().updatePublicStatus(
                                        detailController.tontine!.id!,
                                        true,
                                      );

                                      if (result.isSuccess) {
                                        showCustomSnackBar(context, "La tontine est maintenant publique.", isError: false);
                                        await getData(true); // Rafraîchir les données
                                      } else {
                                        showCustomSnackBar(context, result.message);
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.public),
                                  label: const Text("Rendre public", style: TextStyle(fontWeight: FontWeight.bold),),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.purple, // Définit la couleur du texte en blanc
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Durée de votre tontine", style: TextStyle(color: AppColor.kTontinet_secondary, fontSize: 13, fontWeight: FontWeight.bold)),
                                    Text("${Common.getDuree(detailController.tontine!.dateDebut!, detailController.tontine!.dateFin!)} ${Common.pluralize(Common.getDuree(detailController.tontine!.dateDebut!, detailController.tontine!.dateFin!), "Jour")}", style: TextStyle(fontSize: 13, color: AppColor.kTontinet_primary, fontFamily:
                                    GoogleFonts.lato(fontWeight: FontWeight.w700)
                                        .fontFamily)),
                                  ],
                                ),
                                SizedBox(height: 10,),
                                LinearProgressIndicator(
                                  value: 0.0,
                                  backgroundColor: Colors.grey.withOpacity(0.3),
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      Colors.green),
                                  minHeight: 6,
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Début: ${Common.convertDateToString(detailController.tontine?.dateDebut)}",
                                      style: TextStyle(
                                          color: AppColor.kTontinet_secondary,
                                          fontSize: 13,
                                          fontFamily:
                                          GoogleFonts.lato(fontWeight: FontWeight.w700)
                                              .fontFamily),
                                    ),
                                    Text(
                                      "Fin: ${Common.convertDateToString(detailController.tontine?.dateFin)}",
                                      style: TextStyle(
                                          color: AppColor.kTontinet_secondary,
                                          fontSize: 13,
                                          fontFamily:
                                          GoogleFonts.lato(fontWeight: FontWeight.w700)
                                              .fontFamily),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            SizedBox(height: 25,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Filtrer par période", style: TextStyle(fontSize: 18, color: AppColor.kTontinet_secondary, fontFamily:
                                GoogleFonts.lato(fontWeight: FontWeight.w800)
                                    .fontFamily)),
                                GetBuilder<TontineDetailsController>(builder: (periodiciteController) {
                                  if(periodiciteController.periodiciteLoaded && periodiciteController.periodicites != null){
                                    return Container(
                                        width: 100,
                                        height: 30,
                                        child: DropdownButton<Periodicite>(
                                          value: periodiciteController.selectedPeriod,
                                          icon: Icon(Icons.keyboard_arrow_down),
                                          isExpanded: true,
                                          underline: Container(),
                                          items: periodiciteController.periodicites!.map((Periodicite period) {
                                            return DropdownMenuItem(
                                                value: period,
                                                child: Text(period.id != 0 ? "${Common.convertDateToString(DateTime.parse(period.libelle!))}" : "${period.libelle!}", style: TextStyle(fontSize: 13, color: AppColor.kTontinet_secondary_dark, fontFamily:
                                                GoogleFonts.lato(fontWeight: FontWeight.w700)
                                                    .fontFamily))
                                            );
                                          }).toList(),
                                          hint: Text("Période"),
                                          onChanged: (Periodicite? newValue){
                                            periodiciteController.changePeriod(newValue);
                                          },
                                        )
                                    );
                                  }else{
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 20),
                                      child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2,),
                                      ),
                                    );
                                  }

                                }),

                              ],
                            ),
                            SizedBox(height: 25,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("PAIEMENTS", style: TextStyle(fontSize: 18, color: AppColor.kTontinet_secondary_dark, fontFamily:
                                GoogleFonts.lato(fontWeight: FontWeight.w800)
                                    .fontFamily)),
                                TextButton.icon(
                                  onPressed: () {
                                    Get.to(() => TontineStatPage(tontine: detailController.tontine!));
                                  },
                                  icon: Icon(Icons.bar_chart, color: AppColor.kTontinet_googleColor, size: 18), // Icône ajoutée
                                  label: Text(
                                    "Voir les statistiques",
                                    style: TextStyle(
                                      color: AppColor.kTontinet_googleColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),

                              ],
                            ),
                            GetBuilder<TontineDetailsController>(builder: (cotisationController) {
                              if(cotisationController.cotisationLoaded){
                                if(cotisationController.cotisations!.isEmpty){
                                  return Center(child: Padding(
                                    padding: const EdgeInsets.only(top: 50),
                                    child: EmptyBoxWidget(titre: "Aucune cotisation n'a été faite", icon: "assets/icons/coins_gris.svg", iconType: "svg",),
                                  ));
                                }else{
                                  return ListView.builder(
                                      shrinkWrap: true,
                                      physics: ClampingScrollPhysics(),
                                      padding: EdgeInsets.only(top: 10),
                                      itemCount: cotisationController.cotisations!.length,
                                      itemBuilder: (context, index){
                                        return CotisationCardWidget(cotisation: cotisationController.cotisations![index],);
                                      }
                                  );
                                }

                              }else{
                                return SizedBox(
                                  height: 200,
                                  width: size.width,
                                  child: Center(child: CircularProgressIndicator(),),
                                );
                              }

                            }),
                            SizedBox(height: 10,),
                            /*Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("EN RETARD", style: TextStyle(fontSize: 18, color: AppColor.kTontinet_secondary_dark, fontFamily:
                            GoogleFonts.lato(fontWeight: FontWeight.w800)
                                .fontFamily)),
                          ],
                        ),
                        ListView.builder(
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            padding: EdgeInsets.only(top: 10),
                            itemCount: 3,
                            itemBuilder: (context, index){
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                //height: 70,
                                margin: EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(5)
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.only(left: 10, right: 10),
                                  horizontalTitleGap: 5,
                                  leading: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                        color: Colors.blueGrey[200],
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        "assets/icons/person.svg",
                                        color: Colors.white,
                                        height: 40,
                                        width: 40,
                                      ),
                                    ),
                                  ),
                                  title: Text("Edgar",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontFamily:
                                        GoogleFonts.lato(fontWeight: FontWeight.w800).fontFamily),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text("#Orange Money",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        fontFamily:
                                        GoogleFonts.lato(fontWeight: FontWeight.w700).fontFamily),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text("150 000 Fcfa",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontFamily:
                                            GoogleFonts.lato(fontWeight: FontWeight.w800).fontFamily),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 5,),
                                      Container(
                                        width: 130,
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(10)),
                                        child: Center(
                                            child: Text("12 Aout 2021",
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12,
                                                    fontFamily: GoogleFonts.lato(
                                                        fontWeight: FontWeight.w700)
                                                        .fontFamily))),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                        )*/
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }else{
              return const SizedBox.shrink();
            }
          }else if(detailController.hasError){
            return Center(
              child: AppErrorWidget(
                errorType: detailController.appErrorType,
                onPressed: () async {
                  await getData(true);
                },
              ),
            );
          }else{
            return Center(
              child: SizedBox(
                  width: size.width,
                  height: 150,
                  child: Center(child: CircularProgressIndicator(),)
              ),
            );
          }
        });
      }),
    );
  }

  _buildUserTontineDetails(Tontine tontine, Membre membre){
    Get.find<TontineDetailsController>().getUserTontineEtats(tontine.id, membre.id, true);
    return Get.bottomSheet(
        Container(
          height: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  height: 3,
                  width: 50,
                  margin: EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(25)
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "${membre.displayName}",
                  style: TextStyle(fontSize: 14, color: Colors.blueGrey, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 10),
                GetBuilder<TontineDetailsController>(builder: (detailsController) {
                  if(detailsController.tontineEtatLoaded){
                    if(detailsController.userTontineEtatList!.isEmpty){
                      return SizedBox(
                        height: 200,
                        width: Get.width,
                        child: Center(child: Text("Données non disponibles")),
                      );
                    }else{
                      return SizedBox(
                        height: 250,
                        width: Get.width,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: detailsController.userTontineEtatList!.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.symmetric(vertical: 8),
                                margin: EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(5)
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.only(left: 10, right: 10),
                                  horizontalTitleGap: 5,
                                  leading: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                        color: detailsController.userTontineEtatList![index].paidByUser == 1 ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: Center(
                                      child: Icon(
                                          detailsController.userTontineEtatList![index].paidByUser == 1 ? Icons.check_circle : Icons.cancel,
                                          color: detailsController.userTontineEtatList![index].paidByUser == 1 ? Colors.green : Colors.red
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    "${Common.convertDateToString(DateTime.parse(detailsController.userTontineEtatList![index].libelle!))}",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: GoogleFonts.lato(fontWeight: FontWeight.w800).fontFamily
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 100,
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color: detailsController.userTontineEtatList![index].paidByUser == 1 ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${detailsController.userTontineEtatList![index].paidByUser == 1 ? "PAYE" : "NON PAYE"}",
                                            style: TextStyle(
                                                color: detailsController.userTontineEtatList![index].paidByUser == 1 ? Colors.green : Colors.red,
                                                fontSize: 12,
                                                fontFamily: GoogleFonts.lato(fontWeight: FontWeight.w700).fontFamily
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                        ),
                      );
                    }
                  }else{
                    return SizedBox(
                      height: 200,
                      width: Get.width,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                }),
                Spacer(),
                if(tontine.statut == "PENDING")...[
                  if(Get.find<TontineDetailsController>().tontine?.createur?.id == Get.find<UserController>().userInfo!.id)...[
                    RoundTextButton(
                        titre: "Retirer ce membre",
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        height: 35,
                        fontSize: 14,
                        elevation: 2,
                        onPressed: () {
                          _confirmUserDelete(membre.id);
                        }
                    )
                  ]else if(Get.find<TontineDetailsController>().membres!.any((element) => element.id == membre.id))...[
                    RoundTextButton(
                        titre: "Quitter cette tontine",
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        height: 35,
                        fontSize: 14,
                        elevation: 2,
                        onPressed: () {
                          _confirmUserDelete(membre.id);
                        }
                    )
                  ]
                ]
              ],
            ),
          ),
        )
    );
  }
  _buildRequeteTontineList(){
    return Get.bottomSheet(
        Container(
          height: 400,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  height: 3,
                  width: 50,
                  margin: EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(25)
                  ),
                ),
                SizedBox(height: 10),
                Text("Demandes de participation", style: TextStyle(fontSize: 14, color: Colors.blueGrey, fontWeight: FontWeight.w700)),
                SizedBox(height: 10),
                GetBuilder<TontineDetailsController>(builder: (controller) {
                  if(controller.requeteList != null) {
                    if(controller.requeteList!.isEmpty) {
                      return SizedBox(
                        height: 200,
                        width: Get.width,
                        child: Center(child: Text("Aucune demande de participation")),
                      );
                    }else{
                      return SizedBox(
                        height: 300,
                        width: Get.width,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: controller.requeteList!.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(controller.requeteList![index].user?.displayName ?? ""),
                                subtitle: Row(
                                  children: [
                                    InkWell(
                                        onTap: () => Common.showConfirmDialog(
                                            titre: "Rejet",
                                            message: "Etes vous sûr de vouloir rejeter cet utilisateur?",
                                            onPressed: () async {
                                              Get.back();
                                              await controller.acceptOrRejectRequest(controller.requeteList![index].id!, "REJECT");
                                            }
                                        ),
                                        child: Text("Rejeter", style: TextStyle(color: Colors.red))
                                    ),
                                    SizedBox(width: 10),
                                    InkWell(
                                        onTap: () => Common.showConfirmDialog(
                                            titre: "Acceptation",
                                            message: "Etes vous sûr de vouloir accepter cet utilisateur?",
                                            onPressed: () async {
                                              Get.back();
                                              await controller.acceptOrRejectRequest(controller.requeteList![index].id!, "ACCEPT");
                                            }
                                        ),
                                        child: Text("Accepter", style: TextStyle(color: Colors.green))
                                    ),
                                  ],
                                ),
                              );
                            }
                        ),
                      );
                    }
                  }else{
                    return SizedBox(height: 200, child: CircularProgressIndicator());
                  }
                })
              ],
            ),
          ),
        )
    );
  }
  _confirmTontineRun(int id) async {
    bool? confirm = await Get.defaultDialog<bool>(
      title: "Lancer la cotisation",
      middleText: "Êtes-vous sûr de vouloir lancer cette tontine ? Il est préférable d'ajouter tous les membres avant de lancer.",
      actions: [
        RoundTextButton(
          titre: "OUI",
          width: 80,
          height: 40,
          fontSize: 14,
          backgroundColor: Colors.orange.shade800,
          textColor: Colors.white,
          onPressed: () => Get.back(result: true),
        ),
        RoundTextButton(
          titre: "NON",
          width: 80,
          height: 40,
          fontSize: 14,
          backgroundColor: Colors.grey,
          textColor: Colors.black,
          onPressed: () => Get.back(result: false),
        ),
      ],
    );

    if (confirm == true) {
      final result = await Get.find<TontineDetailsController>().updateStatus(id, "RUNNING");

      if (result.isSuccess) {
        showCustomSnackBar(context, result.message, isError: false);
        await getData(true); // rafraîchir les données
      } else {
        showCustomSnackBar(context, result.message);
      }
    }
  }
  /* _confirmTontineRun(int id) {
    return Get.defaultDialog(
        title: "Confirmation",
        middleText: "Cliquez sur OUI pour confirmer",
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RoundTextButton(
                titre: "OUI",
                width: 80,
                height: 40,
                onPressed: () {
                  Get.find<TontineDetailsController>().updateStatus(id, "RUNNING").then((result) {
                    if(result.isSuccess){
                      showCustomSnackBar(context, result.message, isError: false);
                    }else{
                      showCustomSnackBar(context, result.message);
                    }
                  });
                  Get.back();
                },
                backgroundColor: Colors.red,
                textColor: Colors.white,
              ),
              SizedBox(width: 10,),
              RoundTextButton(
                titre: "NON",
                width: 80,
                height: 40,
                fontSize: 14,
                backgroundColor: Colors.grey,
                textColor: Colors.black,
                onPressed: () {
                  Get.back();
                },
              )
            ],
          ),
        ]);
  }*/

  _confirmUserDelete(int? userId) {
    return Get.defaultDialog(
        title: "Supprimer",
        middleText: "Êtes vous sûr de vouloir supprimer ce membre?",
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RoundTextButton(
                titre: "OUI",
                width: 80,
                height: 40,
                onPressed: () async {
                  await Get.find<TontineDetailsController>().deleteTontineMembre(userId, widget.tontine.id).then((result) {
                    // On ignore l'erreur si l'API bug mais que l'action a été réalisée
                  });

                  Get.back(); // Fermer la confirmation
                  Get.back(); // Fermer le bottom sheet

                  showCustomSnackBar(
                    context,
                    "Vous avez quitté cette tontine avec succès.",
                    isError: false,
                  );

                  await getData(true);
                },
                backgroundColor: Colors.red,
                textColor: Colors.white,
              ),
              SizedBox(width: 10,),
              RoundTextButton(
                titre: "NON",
                width: 80,
                height: 40,
                fontSize: 14,
                backgroundColor: Colors.grey,
                textColor: Colors.black,
                onPressed: () {
                  Get.back();
                },
              )
            ],
          ),
        ]);
  }

  _confirmTontineDelete(int id) {
    return Get.defaultDialog(
      title: "Supprimer",
      middleText: "Êtes-vous sûr de vouloir supprimer cette tontine ?",
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RoundTextButton(
              titre: "OUI",
              width: 80,
              height: 40,
              fontSize: 14,
              onPressed: () {
                // Appel de la méthode hard delete
                Get.find<TontineDetailsController>().deleteTontine(id).then((result) {
                  if(result.isSuccess){
                    showCustomSnackBar(context, result.message, isError: false);
                  } else {
                    showCustomSnackBar(context, result.message);
                  }
                });
                Get.back(); // Fermer le dialogue
                Get.back(); // Retourner à la page précédente
              },
              backgroundColor: Colors.red,
              textColor: Colors.white,
            ),
            SizedBox(width: 10,),
            RoundTextButton(
              titre: "NON",
              width: 80,
              height: 40,
              fontSize: 14,
              backgroundColor: Colors.grey,
              textColor: Colors.black,
              onPressed: () {
                Get.back();
              },
            )
          ],
        ),
      ],
    );
  }
}