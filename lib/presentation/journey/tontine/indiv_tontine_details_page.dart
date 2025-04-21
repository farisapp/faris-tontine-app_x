import 'package:faris/common/app_constant.dart';
import 'package:faris/presentation/journey/tontine/indiv_add_tontine_page.dart';
import 'package:faris/data/core/api_client.dart';
import 'package:faris/data/models/api_response.dart' as myApiResponse;
import 'package:faris/presentation/journey/tontine/indiv_retirer_page.dart';
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


class IndivTontineDetailsPage extends StatefulWidget {
  final Tontine tontine;

  const IndivTontineDetailsPage({Key? key, required this.tontine}) : super(key: key);

  @override
  _IndivTontineDetailsPageState createState() => _IndivTontineDetailsPageState();
}

class _IndivTontineDetailsPageState extends State<IndivTontineDetailsPage> {

  _IndivTontineDetailsPageState();

  AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initJiffy();
      await getData(false);
    });
  }

  initJiffy() async {
    await Jiffy.setLocale("fr");
  }

  getData(bool reload) async {
    final detailController = Get.find<TontineDetailsController>();
    final userController = Get.find<UserController>();
    final authController = Get.find<AuthController>();

    // 🔥 Charger rapidement les détails de la tontine
    await detailController.getTontineDetails(widget.tontine.id, reload);

    // ✅ Vérifier immédiatement et changer le statut si nécessaire
    if (detailController.tontine?.statut == "PENDING") {
      await Get.find<TontineDetailsController>().updateStatus(detailController.tontine!.id!, "RUNNING");
      await detailController.getTontineDetails(widget.tontine.id, true);
    }


    // 🟡 Ensuite charger les autres infos
    await detailController.getTontineMembres(widget.tontine.id, reload);
    await detailController.getTontineRequetes(widget.tontine.id, reload);
    await detailController.getTontinePeriodicites(widget.tontine.id, reload);
    await detailController.getTontinePeriodicitesToPaid(widget.tontine.id, true);

    if (authController.isLoggedIn()) {
      await userController.getUserInfo();
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
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 250,
                        //color: Colors.grey,
                        child: Stack(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 120,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    AppColor.kTontinet_primary_light,
                                    AppColor.kTontinet_secondary_dark,
                                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))
                              ),
                            ),
                            Positioned(
                                top: 50,
                                child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 105,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Spacer(),
                                            detailController.tontine?.createur?.id == userController.userInfo!.id ? Row(
                                              children: [
                                                (detailController.tontine?.statut == "PENDING" || detailController.tontine?.statut == "RUNNING") ?
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Modifier", // Label à gauche de l'icône
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(width: 5), // Espace entre le texte et l'icône
                                                    IconButton(
                                                        icon: Icon(
                                                          Icons.edit_note,
                                                          color: Colors.white,
                                                        ),
                                                        onPressed: () async {
                                                          Get.to(() => IndivAddTontinePage(tontine: widget.tontine,));
                                                        }
                                                    ),
                                                  ],
                                                ):
                                                const SizedBox.shrink(),
                                                detailController.tontine?.statut != "RUNNING"
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
                                                      "Supprimer",
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
                                            ) : SizedBox.shrink(),
                                          ],
                                        ),
                                        SizedBox(height: 5,),
                                      ],
                                    )
                                )
                            ),
                            Positioned(
                              bottom: 0,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 160,
                                //color: Colors.red,
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: detailController.membres != null ? ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    padding: EdgeInsets.only(left: 10, right: 10),
                                    itemCount: detailController.membres?.length,
                                    itemBuilder: (context, index){
                                      return MembreCardWidget(
                                        membre: detailController.membres?[index],
                                        controller: detailController,
                                        onPress: () async {
                                          if(detailController.membres?[index].id == 0){
                                            if(detailController.tontine?.createur?.id == userController.userInfo!.id){
                                              if(detailController.tontine?.hasPayment == 1 || (detailController.membres!.length - 1) >= detailController.tontine!.nbrePersonne!){
                                                showCustomSnackBar(context, "Épargne individuelle, vous ne pouvez pas ajouter de membre");
                                              }else{
                                                Get.to(() => ContactPage(tontine: detailController.tontine!));
                                              }
                                            }
                                            else{
                                              showCustomSnackBar(context, "Épargne individuelle, vous ne pouvez pas ajouter de membre");
                                            }

                                          }else{
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
                      SizedBox(height: 5,),
                      Text("${detailController.tontine?.type}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                            color: Colors.black),),
                      Text("CODE: ${detailController.tontine?.numero}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                            color: Colors.purple),),
                      Text("NOM: ${detailController.tontine?.libelle}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                            color: Colors.black),),
                      SizedBox(height: 5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Common.getTontineStatutColor(detailController.tontine?.statut)
                            ),
                          ),
                          SizedBox(width: 10,),
                          Text("${Common.getTontineStatut(detailController.tontine?.statut)}",
                            style: TextStyle(
                                color: Common.getTontineStatutColor(detailController.tontine?.statut),
                                fontSize: 18,
                                fontFamily:
                                GoogleFonts.lato(fontWeight: FontWeight.w800).fontFamily),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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

                            Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 15),
                              child: SizedBox(
                                height: 35,
                                width: size.width,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    if(userController.userInfo != null) ...[
                                      if(detailController.tontine?.statut == "RUNNING")...[
                                        if(detailController.tontine?.type == "EPARGNE")...[
                                          if(detailController.periodiciteToPaidList != null)...[
                                            if(detailController.periodiciteToPaidList!.isEmpty)...[
                                              if(detailController.tontine?.createur?.id == userController.userInfo!.id)...[
                                                RoundTextButton(
                                                    titre: "Retirer",
                                                    backgroundColor: Colors.teal,
                                                    textColor: Colors.white,
                                                    height: 35,
                                                    fontSize: 14,
                                                    elevation: 2,
                                                    onPressed: () {
                                                      final tontine = detailController.tontine!;
                                                      final isBlockedAndNotCompleted = tontine.isBlocked &&
                                                          tontine.totalMontantCotise < tontine.montantTotalTontine;

                                                      if (isBlockedAndNotCompleted) {
                                                        showCustomSnackBar(
                                                          context,
                                                          "Ce compte est bloqué. Le retrait ne sera possible qu’une fois tous les paiements terminés.",
                                                          isError: true,
                                                        );
                                                      } else {
                                                        Get.to(() => IndivRetirerPage(tontine: tontine));
                                                      }
                                                      icon: Icons.remove_circle_outline; // Icône pour Retirer
                                                    } // Icône pour Retirer
                                                )
                                              ]
                                            ]else...[
                                              if(detailController.isMembre(userController.userInfo!.id!))...[
                                                RoundTextButton(
                                                  titre: "Cotiser",
                                                  backgroundColor: Colors.deepOrange,
                                                  textColor: Colors.white,
                                                  height: 35,
                                                  fontSize: 14,
                                                  elevation: 2,
                                                  onPressed: ()  {
                                                    Get.to(() => CotiserPage(tontine: detailController.tontine!,));
                                                    //await _buildCotiserSheet(context);
                                                  },
                                                  icon: Icons.attach_money, // Icône pour Cotiser
                                                ),

                                              ]
                                            ]
                                          ]
                                        ]else...[
                                          Expanded(
                                              child: RoundTextButton(
                                                titre: "Cotiser",
                                                backgroundColor: Colors.deepOrange,
                                                textColor: Colors.white,
                                                height: 35,
                                                fontSize: 14,
                                                elevation: 2,
                                                onPressed: ()  {
                                                  Get.to(() => CotiserPage(tontine: detailController.tontine!,));
                                                  //await _buildCotiserSheet(context);
                                                },
                                                icon: Icons.attach_money,)
                                          ), // Icône pour Cotiser                                          ),
                                          if(detailController.tontine?.createur?.id == userController.userInfo!.id)...[
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 10),
                                                child: RoundTextButton(
                                                    titre: "Retirer",
                                                    backgroundColor: Colors.green.shade800,
                                                    textColor: Colors.white,
                                                    height: 35,
                                                    fontSize: 14,
                                                    elevation: 2,
                                                    onPressed: () {
                                                      final tontine = detailController.tontine!;
                                                      final isBlockedAndNotCompleted = tontine.isBlocked &&
                                                          tontine.totalMontantCotise < tontine.montantTotalTontine;

                                                      if (isBlockedAndNotCompleted) {
                                                        showCustomSnackBar(
                                                          context,
                                                          "Ce compte est bloqué. Le retrait ne sera possible qu’une fois tous les paiements terminés.",
                                                          isError: true,
                                                        );
                                                      } else {
                                                        Get.to(() => IndivRetirerPage(tontine: tontine));
                                                      }
                                                      icon: Icons.remove_circle_outline; // Icône pour Retirer
                                                    }
                                                ),
                                              ),
                                            )
                                          ]
                                        ]

                                      ] else ...[
                                        Expanded(
                                          child: SizedBox(
                                            width: Get.width,
                                            child: Text("Cette épargne est clôturée, vous pouvez la supprimer si vous souhaitez.",
                                              style: TextStyle(color: Colors.red, fontSize: 11, fontStyle: FontStyle.italic),
                                              maxLines: 3,
                                            ),
                                          ),
                                        )
                                      ]
                                    ]
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 5,),
                            Row(
                              children: [
                                // Bouton Bloquer (affiché si l'utilisateur est le créateur)
                                if (detailController.tontine?.createur?.id == userController.userInfo?.id)
                                  Expanded(
                                    child: RoundTextButton(
                                      titre: detailController.tontine!.isBlocked ? "Compte bloqué" : "Bloquer",
                                      backgroundColor: detailController.tontine!.isBlocked ? Colors.grey : Colors.blueGrey,
                                      textColor: Colors.white,
                                      height: 35,
                                      fontSize: 14,
                                      elevation: detailController.tontine!.isBlocked ? 0 : 2,
                                      icon: Icons.lock,
                                      onPressed: detailController.tontine!.isBlocked
                                          ? () {} // Aucune action si déjà bloqué
                                          : () async {
                                        // Affichage de la boîte de dialogue de confirmation
                                        bool? confirm = await Get.defaultDialog<bool>(
                                          title: "Avertissement",
                                          middleText:
                                          "Si vous bloquez votre compte, vous pourrez continuer à cotiser mais vous ne pourrez pas retirer tant que les paiements ne seront pas terminés. Veuillez confirmer.",
                                          actions: [
                                            RoundTextButton(
                                              titre: "Annuler",
                                              width: 80,
                                              height: 40,
                                              fontSize: 14,
                                              backgroundColor: Colors.grey,
                                              textColor: Colors.white,
                                              onPressed: () => Get.back(result: false),
                                            ),
                                            RoundTextButton(
                                              titre: "Bloquer",
                                              width: 80,
                                              height: 40,
                                              fontSize: 14,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              onPressed: () => Get.back(result: true),
                                            ),
                                          ],
                                        );
                                        if (confirm == true) {
                                          final result = await detailController.updateBlockStatus(
                                            detailController.tontine!.id!,
                                            true,
                                          );
                                          if (result.isSuccess) {
                                            showCustomSnackBar(context, result.message, isError: false);
                                            await getData(true);
                                          } else {
                                            showCustomSnackBar(context, result.message);
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                if (detailController.tontine?.createur?.id == userController.userInfo?.id)
                                  const SizedBox(width: 10),
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
                                      // Demande de confirmation pour clôturer
                                      bool? confirm = await Get.defaultDialog<bool>(
                                        title: "Confirmation de clôture",
                                        middleText:
                                        "Êtes-vous sûr de vouloir clôturer cette épargne ?",
                                        actions: [
                                          RoundTextButton(
                                            titre: "CLOTURER",
                                            width: 80,
                                            height: 40,
                                            fontSize: 14,
                                            backgroundColor: Colors.red,
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
                                            .updateStatus(detailController.tontine!.id!, 'FINISHED')
                                            .then((result) {
                                          if (result.isSuccess) {
                                            showCustomSnackBar(context, "L'épargne a été clôturée avec succès.", isError: false);
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
                                      // Demande de confirmation pour relancer
                                      bool? confirm = await Get.defaultDialog<bool>(
                                        title: "Confirmation de relance",
                                        middleText: "Êtes-vous sûr de vouloir relancer cette épargne ?",
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
                                            showCustomSnackBar(context, "L'épargne a été relancée avec succès.", isError: false);
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
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Section Montant cotisé = total cotisé - montant retiré
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Montant cotisé",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: AppColor.kTontinet_secondary,
                                              fontFamily: GoogleFonts.lato(fontWeight: FontWeight.w700).fontFamily,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 5),
                                          RichText(
                                            text: TextSpan(
                                              text: "${Common.currency_format().format((detailController.tontine?.totalMontantCotise ?? 0) - (detailController.tontine?.montantRetire ?? 0))}",
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 18,
                                                fontFamily: GoogleFonts.lato(fontWeight: FontWeight.w800).fontFamily,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: " FCFA",
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 15,
                                                    fontFamily: GoogleFonts.lato(fontWeight: FontWeight.w800).fontFamily,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Séparateur
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      height: 30,
                                      width: 1,
                                      color: Colors.grey.withOpacity(0.4),
                                    ),
                                  ),
                                  // Section Paiements en attentes
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Builder(
                                        builder: (_) {
                                          double montantTontine = (detailController.tontine?.montantTontine ?? 0).toDouble();
                                          int nbrePeriode = detailController.tontine?.nbrePeriode ?? 0;
                                          int totalAttendu = (montantTontine * nbrePeriode).toInt();
                                          int totalCotise = detailController.tontine?.totalMontantCotise ?? 0;
                                          int montantRetire = detailController.tontine?.montantRetire ?? 0;
                                          // Nouvelle formule : totalAttendu - totalCotise - montantRetire
                                          int paiementsAttente = totalAttendu - totalCotise;

                                          return Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Paiements en attentes",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: AppColor.kTontinet_secondary,
                                                  fontFamily: GoogleFonts.lato(fontWeight: FontWeight.w700).fontFamily,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 5),
                                              RichText(
                                                text: TextSpan(
                                                  text: "${Common.currency_format().format(paiementsAttente)}",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 18,
                                                    fontFamily: GoogleFonts.lato(fontWeight: FontWeight.w800).fontFamily,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: " FCFA",
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 15,
                                                        fontFamily: GoogleFonts.lato(fontWeight: FontWeight.w800).fontFamily,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 5,),
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
                            SizedBox(height: 5,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Durée de votre épargne", style: TextStyle(color: AppColor.kTontinet_secondary, fontSize: 13, fontWeight: FontWeight.bold)),
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
                                TextButton(
                                  onPressed: () {
                                    Get.to(() => TontineStatPage(tontine: detailController.tontine!,));
                                  },
                                  child: Text("Voir les statistiques", style: TextStyle(color: AppColor.kTontinet_googleColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                )
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
                                      Text("150 000 FCFA",
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

  _buildUserTontineDetails(Tontine tontine, Membre membre, ){
    Get.find<TontineDetailsController>().getUserTontineEtats(tontine.id, membre.id, true);
    return Get.bottomSheet(
        Container(
          height: 400,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
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
                SizedBox(height: 10,),
                Text("${membre.displayName}", style: TextStyle(fontSize: 14, color: Colors.blueGrey, fontWeight: FontWeight.w700,)),
                SizedBox(height: 10,),
                GetBuilder<TontineDetailsController>(builder: (detailsController) {
                  if(detailsController.tontineEtatLoaded){
                    if(detailsController.userTontineEtatList!.isEmpty){
                      return SizedBox(
                          height: 200,
                          width: Get.width,
                          child: Center(child: Text("Données non disponibles"),)
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
                                        color: detailsController.userTontineEtatList![index].paidByUser  == 1 ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Center(
                                      child: Icon(detailsController.userTontineEtatList![index].paidByUser == 1 ? Icons.check_circle : Icons.cancel, color: detailsController.userTontineEtatList![index].paidByUser == 1 ? Colors.green : Colors.red,),
                                    ),
                                  ),
                                  title: Text("${Common.convertDateToString(DateTime.parse(detailsController.userTontineEtatList![index].libelle!))}",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontFamily:
                                        GoogleFonts.lato(fontWeight: FontWeight.w800).fontFamily),
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
                                            borderRadius: BorderRadius.circular(10)),
                                        child: Center(
                                            child: Text("${detailsController.userTontineEtatList![index].paidByUser == 1 ? "PAYE" : "NON PAYE"}",
                                                style: TextStyle(
                                                    color: detailsController.userTontineEtatList![index].paidByUser == 1 ? Colors.green : Colors.red,
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

                        ),
                      );
                    }
                  }else{
                    return SizedBox(
                      height: 200,
                      width: Get.width,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
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
                  ]else if(Get.find<TontineDetailsController>().membres!.firstWhere((element) => element.id == membre.id).id != null)...[
                    RoundTextButton(
                        titre: "Quitter la tontine",
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
              borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
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
                SizedBox(height: 10,),
                SizedBox(height: 10,),
                GetBuilder<TontineDetailsController>(builder: (controller) {
                  if(controller.requeteList != null) {
                    if(controller.requeteList!.isEmpty) {
                      return SizedBox(
                        height: 200,
                        width: Get.width,
                      );
                    }else{
                      return SizedBox(
                        height: 300,
                        width: Get.width,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: controller.requeteList!.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: MediaQuery.of(context).size.width,

                                margin: EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(5)
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.only(left: 10, right: 10),
                                  horizontalTitleGap: 5,
                                  leading: CircleAvatar(
                                    radius: 18,
                                    backgroundImage: controller.requeteList![index].user!.avatar != null ? NetworkImage(AppConstant.BASE_IMAGE_URL+"/${controller.requeteList![index].user!.avatar}") : Svg("assets/icons/person.svg") as ImageProvider,
                                    backgroundColor: Colors.blueGrey[200],
                                  ),
                                  title: Text("${controller.requeteList![index].user?.displayName ?? ""}",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontFamily:
                                        GoogleFonts.lato(fontWeight: FontWeight.w800).fontFamily),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Common.showConfirmDialog(
                                                titre: "Rejet",
                                                message: "Etes vous sûr de vouloir rejeter cet utilisateur?",
                                                onPressed: () async {
                                                  Get.back();
                                                  await controller.acceptOrRejectRequest(controller.requeteList![index].id!, "REJECT").then((result) {
                                                    if(result.isSuccess){
                                                      showCustomSnackBar(context, result.message, isError: false);
                                                    }else{
                                                      showCustomSnackBar(context, result.message);
                                                    }
                                                  });
                                                  /*if(controller.requeteList!.isEmpty){
                                                    print(controller.requeteList!.length);
                                                    Get.back();
                                                  }*/
                                                }
                                            );
                                          },
                                          child: Container(
                                            width: 90,
                                            height: 25,
                                            decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius: BorderRadius.circular(15)
                                            ),
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.thumb_down, color: Colors.white, size: 14,),
                                                  SizedBox(width: 5,),
                                                  Text("Rejeter", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),)
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10,),
                                        InkWell(
                                          onTap: () {
                                            Common.showConfirmDialog(
                                                titre: "Acceptation",
                                                message: "Etes vous sûr de vouloir accepter cet utilisateur?",
                                                onPressed: () async  {
                                                  Get.back();
                                                  await controller.acceptOrRejectRequest(controller.requeteList![index].id!, "ACCEPT").then((result) {
                                                    if(result.isSuccess){
                                                      showCustomSnackBar(context, result.message, isError: false);
                                                    }else{
                                                      showCustomSnackBar(context, result.message);
                                                    }
                                                  });
                                                }
                                            );
                                          },
                                          child: Container(
                                            width: 90,
                                            height: 25,
                                            decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius: BorderRadius.circular(15)
                                            ),
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.thumb_up, color: Colors.white, size: 14,),
                                                  SizedBox(width: 5,),
                                                  Text("Accepter", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),)
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
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
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                })
                /*Spacer(),
                (tontine.statut == "PENDING" && Get.find<TontineDetailsController>().tontine?.createur?.id == Get.find<UserController>().userInfo!.id) ? RoundTextButton(
                    titre: "Retirer ce membre",
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    height: 35,
                    fontSize: 14,
                    elevation: 2,
                    onPressed: () {
                      _confirmUserDelete(membre.id);
                    }
                ) : SizedBox.shrink(),*/
              ],
            ),
          ),
        )
    );
  }
  Future<myApiResponse.ApiResponse> softDeleteTontine(int id) async {
    final response = await apiClient.putData(
      '${AppConstant.TONTINE_SOFT_DELETE_URI}/$id',
      {"is_deleted": 1},
    );
    return myApiResponse.ApiResponse.fromResponse(response);
  }
  final ApiClient apiClient = Get.find<ApiClient>();


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
                    if(result.isSuccess){
                      Get.back();
                      Get.back();
                      showCustomSnackBar(context, result.message, isError: false);
                    }else{
                      Get.back();
                      showCustomSnackBar(context, result.message);
                    }
                  });
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
      middleText: "Êtes-vous sûr de vouloir supprimer cette épargne ?",
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
                Get.back(); // Fermer la boîte de dialogue
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