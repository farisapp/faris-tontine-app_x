import 'package:faris/common/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:faris/controller/tontine_details_controller.dart';
import 'package:faris/data/models/membre_model.dart';
import 'package:faris/presentation/widgets/custom_snackbar.dart';

class MembreCardWidget extends StatelessWidget {
  final Membre? membre;
  final VoidCallback onPress;
  final TontineDetailsController controller;

  MembreCardWidget({Key? key, required this.membre, required this.onPress, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Stack(
        children: [
          Container(
            width: 90,
            height: 135,
            margin: EdgeInsets.only(left: 5, bottom: 5, right: 5),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5.0,
                    spreadRadius: 2.0,
                  )
                ]
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: membre?.id == 0 ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline),
                  SizedBox(height: 5,),
                  Text("Ajouter", style: TextStyle(fontFamily:
                  GoogleFonts.raleway(fontWeight: FontWeight.w800).fontFamily),)
                ],
              ) : Column(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: membre?.avatar != null ? NetworkImage(AppConstant.BASE_IMAGE_URL+"/${membre?.avatar}") : Svg("assets/icons/person.svg") as ImageProvider,
                    backgroundColor: Colors.blueGrey[200],
                  ),
                  SizedBox(height: 8,),
                  Text("${membre?.displayName}", style: TextStyle(fontSize: 12, fontFamily:
                  GoogleFonts.raleway(fontWeight: FontWeight.w800).fontFamily), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,),
                  SizedBox(height: 8,),
                  /*Text(controller.isUpToDate(membre!.id!) ?  "A jour" : "Pas à jour", style: TextStyle(fontSize: 12, color: controller.isUpToDate(membre!.id!) ? Colors.green : Colors.red, fontFamily:
                  GoogleFonts.raleway(fontWeight: FontWeight.w800).fontFamily), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,)*/
                ],
              )
            ),
          ),
          /*Positioned(
                                      bottom: 0,
                                      right: 0,
                                      left: 0,
                                      child: Container(
                                        height: 35,
                                        width: 35,
                                        child: Icon(Icons.access_time, color: Colors.grey,),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(30),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 5.0,
                                                spreadRadius: 2.0,
                                              )
                                            ]
                                        ),
                                      ),
                                    )*/
        ],
      ),
    );
  }
}
