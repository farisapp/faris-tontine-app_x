import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:faris/common/common.dart';
import 'package:faris/controller/request_tontine_controller.dart';
import 'package:faris/presentation/theme/theme_color.dart';
import 'package:faris/presentation/widgets/app_error_widget.dart';
import 'package:faris/presentation/widgets/empty_box_widget.dart';
import 'package:faris/presentation/widgets/round_textbutton.dart';

class UserRequestListPage extends StatelessWidget {

  UserRequestListPage({Key? key}) : super(key: key);

  RequestTontineController _requestController =
  Get.find<RequestTontineController>();

  @override
  Widget build(BuildContext context) {
    _requestController.getRequests(false);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Mes demandes à participer",
              style: TextStyle(
                  color: AppColor.kTontinet_secondary,
                  fontSize: 20,
                  fontFamily: GoogleFonts.raleway(fontWeight: FontWeight.w800)
                      .fontFamily),
            ),
          ],
        ),
        leading: InkWell(
          child: Icon(
            Icons.arrow_back,
            color: AppColor.kTontinet_secondary,
          ),
          onTap: () {
            Get.back();
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColor.kTontinet_secondary),
      ),
      body:  RefreshIndicator(
        onRefresh: () async {
          await _requestController.getRequests(true);
        },
        child: GetBuilder<RequestTontineController>(builder: (requestController) {
          if (requestController.requestLoaded) {
            if(requestController.requeteList != null){
              if(requestController.requeteList!.isNotEmpty){
                return ListView.builder(
                    shrinkWrap: true,
                    //physics: BouncingScrollPhysics(),
                    itemCount: requestController.requeteList!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        child: Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                          color: Colors.cyan,
                                          borderRadius:
                                          BorderRadius.circular(15)),
                                      child: Center(
                                          child: Text(
                                            "${Common.getInitials(requestController.requeteList![index].tontine!.libelle)}",
                                            style: TextStyle(
                                                fontSize: 25,
                                                color: Colors.orange,
                                                fontFamily:
                                                GoogleFonts.raleway(
                                                    fontWeight:
                                                    FontWeight
                                                        .w800)
                                                    .fontFamily),
                                          )),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${requestController.requeteList![index].tontine!.libelle}",
                                              style: TextStyle(
                                                  color: AppColor
                                                      .kTontinet_secondary,
                                                  fontSize: 15,
                                                  fontFamily:
                                                  GoogleFonts.raleway(
                                                      fontWeight:
                                                      FontWeight
                                                          .w800)
                                                      .fontFamily),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              "${Common.convertDateToString(requestController.requeteList![index].tontine!.dateDebut)} - ${Common.convertDateToString(requestController.requeteList![index].tontine!.dateFin)}",
                                              style: TextStyle(
                                                  color: AppColor
                                                      .kTontinet_textColor1,
                                                  fontSize: 11,
                                                  fontFamily:
                                                  GoogleFonts.raleway(
                                                      fontWeight:
                                                      FontWeight
                                                          .w700)
                                                      .fontFamily),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text.rich(
                                              TextSpan(
                                                  text: "Type tontine: ",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey),
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                      "${requestController.requeteList![index].tontine!.type}",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.teal,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold),
                                                    )
                                                  ]),
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                              maxLines: 2,
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text.rich(
                                              TextSpan(
                                                  text:
                                                  "Montant cotisation: ",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey),
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                      "${Common.fcfa_currency_format().format(requestController.requeteList![index].tontine!.montantTontineFrais)}",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.teal,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold),
                                                    )
                                                  ]),
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                              maxLines: 2,
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text.rich(
                                              TextSpan(
                                                  text:
                                                  "Montant à ramasser: ",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey),
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                      "${Common.fcfa_currency_format().format(requestController.requeteList![index].tontine!.totalMontantRamassage!)}",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.teal,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold),
                                                    )
                                                  ]),
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                              maxLines: 2,
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              "${requestController.requeteList![index].tontine!.membres!.length} ${Common.pluralize(requestController.requeteList![index].tontine!.membres!.length, "membre")} / ${requestController.requeteList![index].tontine!.nbrePersonne} ${Common.pluralize(requestController.requeteList![index].tontine!.nbrePersonne!, "membre")}",
                                              style: TextStyle(
                                                  color: Colors.teal,
                                                  fontSize: 11,
                                                  fontStyle:
                                                  FontStyle.italic),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text.rich(
                                              TextSpan(
                                                  text: "Organisateur: ",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey),
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                      "${requestController.requeteList![index].tontine!.createur?.displayName}",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.teal,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold),
                                                    )
                                                  ]),
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                              maxLines: 2,
                                            ),
                                          ],
                                        ))
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 25, right: 25, bottom: 10, top: 10),
                                  child: Container(
                                    width: Get.width,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        color: Common
                                            .getRequestStatutBgColor(
                                            requestController
                                                .requeteList![
                                            index]
                                                .statut),
                                        borderRadius:
                                        BorderRadius.circular(
                                            10)),
                                    child: Center(
                                        child: Text(
                                            "${Common.getRequestStatut(requestController.requeteList![index].statut)}",
                                            style: TextStyle(
                                                color: Common.getRequestStatutColor(
                                                    requestController
                                                        .requeteList![
                                                    index]
                                                        .statut),
                                                fontSize: 12,
                                                fontFamily: GoogleFonts.raleway(
                                                    fontWeight:
                                                    FontWeight
                                                        .w700)
                                                    .fontFamily))),
                                  ),)

                              ],
                            ),
                          ),
                        ),
                      );
                    });
              }else{
                return Center(
                    child: EmptyBoxWidget(
                      titre: "Vous n'avez aucune requête",
                      icon: "assets/icons/coins_gris.svg",
                      iconType: "svg",
                    ));
              }
            }else{
              return Center(
                  child: EmptyBoxWidget(
                    titre: "Vous n'avez aucune requête",
                    icon: "assets/icons/coins_gris.svg",
                    iconType: "svg",
                  ));
            }

          } else if (requestController.requeteLoadError) {
            return Center(
              child: AppErrorWidget(
                errorType: requestController.appErrorType,
                onPressed: () async {
                  await _requestController.getRequests(true);
                },
              ),
            );
          } else {
            return Center(
                child: CircularProgressIndicator());
          }
        }),
      )
    );
  }

}
