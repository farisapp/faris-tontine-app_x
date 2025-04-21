import 'package:faris/common/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_stack/flutter_image_stack.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:faris/common/common.dart';
import 'package:faris/data/models/tontine_model.dart';
import 'package:faris/presentation/theme/theme_color.dart';

class TontineListTile extends StatelessWidget {
  final Tontine tontine;
  final VoidCallback press;

  const TontineListTile({Key? key, required this.tontine, required this.press}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                          color: Colors.cyan,
                          borderRadius: BorderRadius.circular(15)),
                      child: Center(
                          child: Text(
                            "${Common.getInitials(tontine.libelle)}",
                            style: TextStyle(
                                fontSize: 25,
                                color: Colors.orange,
                                fontFamily:
                                GoogleFonts.lato(fontWeight: FontWeight.w800)
                                    .fontFamily),
                          )),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${tontine.libelle}",
                              style: TextStyle(
                                  color: AppColor.kTontinet_secondary,
                                  fontSize: 15,
                                  fontFamily:
                                  GoogleFonts.lato(fontWeight: FontWeight.w800)
                                      .fontFamily),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "${Common.convertDateToString(tontine.dateDebut)} - ${Common.convertDateToString(tontine.dateFin)}",
                              style: TextStyle(
                                  color: AppColor.kTontinet_textColor1,
                                  fontSize: 10,
                                  fontFamily:
                                  GoogleFonts.lato(fontWeight: FontWeight.w700)
                                      .fontFamily),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            tontine.membres!.length > 0 ? FlutterImageStack.widgets(
                              children: getMembreAvatars(),
                              totalCount: tontine.membres!.length,
                              showTotalCount: true,
                              itemRadius: 40,
                              itemCount: tontine.nbrePersonne,
                              itemBorderWidth: 3,
                              itemBorderColor: Colors.white,
                              extraCountTextStyle: TextStyle(color: Colors.brown),
                            ) : Text("Vous n'avez pas de membres", style: TextStyle(color: Colors.red, fontSize: 11, fontStyle: FontStyle.italic),),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: 100,
                              height: 30,
                              decoration: BoxDecoration(
                                  color: Common.getTontineStatutBgColor(tontine.statut), //_getStatusBgColor(_getStatus(_getProgressValue())
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                  child: Text("${Common.getTontineStatut(tontine.statut)}",
                                      style: TextStyle(
                                          color: Common.getTontineStatutColor(tontine.statut),
                                          fontSize: 12,
                                          fontFamily: GoogleFonts.lato(
                                              fontWeight: FontWeight.w700)
                                              .fontFamily))),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Durée de votre épargne", style: TextStyle(color: AppColor.kTontinet_secondary, fontSize: 13, fontWeight: FontWeight.bold)),
                    Text("${Common.getDuree(tontine.dateDebut!, tontine.dateFin!)} ${Common.pluralize(Common.getDuree(tontine.dateDebut!, tontine.dateFin!), "Jour")}", style: TextStyle(fontSize: 13, color: AppColor.kTontinet_secondary, fontFamily:
                    GoogleFonts.lato(fontWeight: FontWeight.w700)
                        .fontFamily)),
                  ],
                ),
                SizedBox(height: 10,),
                LinearProgressIndicator(
                  value: _getProgressValue(),
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  valueColor: new AlwaysStoppedAnimation<Color>(
                      _getProgressColor()),
                  minHeight: 6,
                ),
                SizedBox(
                  height: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Début ${Common.convertDateToString(tontine.dateDebut)}",
                      style: TextStyle(
                          color: AppColor.kTontinet_primary_light,
                          fontSize: 13,
                          fontFamily:
                          GoogleFonts.lato(fontWeight: FontWeight.w700)
                              .fontFamily),
                    ),
                    Text(
                      "Fin ${Common.convertDateToString(tontine.dateFin)}",
                      style: TextStyle(
                          color: AppColor.kTontinet_primary_light,
                          fontSize: 13,
                          fontFamily:
                          GoogleFonts.lato(fontWeight: FontWeight.w700)
                              .fontFamily),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Color _getStatusBgColor(String? status){
    switch(status){
      case "Non démarée":
        return Colors.red.withOpacity(0.3);
      case "En cours":
        return Colors.orange.withOpacity(0.3);
      case "Terminée":
        return Colors.green.withOpacity(0.3);
      default:
        return Colors.red.withOpacity(0.3);
    }
  }

  Color _getStatusTextColor(String? status){
    switch(status){
      case "Non démarée":
        return Colors.red;
      case "En cours":
        return Colors.orange;
      case "Terminée":
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  Color _getProgressColor(){
   double value = Common.calculDuree(tontine.dateDebut, tontine.dateFin);
   if(value <= 0){
     return Colors.grey.withOpacity(0.3);
   }else if(value > 0 && value <= 1){
     return Colors.orange;
   }else{
     return Colors.green;
   }
  }

  double _getProgressValue(){
    if(tontine.statut == "RUNNING" || tontine.statut == "FINISHED"){
      return Common.calculDuree(tontine.dateDebut, tontine.dateFin);
    }else{
      return 0;
    }
  }

  List<Widget> getMembreAvatars(){
    List<Widget> images = [];
    if(tontine.membres!.isNotEmpty){
      for(int i=0; i < tontine.membres!.length; i++){
        images.add(CircleAvatar(
          radius: 23,
          backgroundImage: tontine.membres![i].avatar != null ? NetworkImage(AppConstant.BASE_IMAGE_URL+"/${tontine.membres![i].avatar}",) : Svg("assets/icons/person.svg") as ImageProvider,
          backgroundColor: Colors.blueGrey[200],
        ));
      }
    }
    return images;
  }
}
