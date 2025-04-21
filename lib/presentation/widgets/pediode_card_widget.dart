
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:faris/common/common.dart';
import 'package:faris/data/models/periodicite_model.dart';

class PeriodeCardWidget extends StatelessWidget {
  final Periodicite? periodicite;
  final VoidCallback onPress;

  PeriodeCardWidget({Key? key, required this.periodicite, required this.onPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 8),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(5)
        ),
        child: ListTile(
          contentPadding: EdgeInsets.only(left: 10, right: 10),
          horizontalTitleGap: 5,
          onTap: onPress,
          leading: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
                color: periodicite?.isPaid == 1 ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: Icon(periodicite?.isPaid == 1 ? Icons.check_circle : Icons.cancel, color: periodicite?.isPaid == 1 ? Colors.green : Colors.red,),
            ),
          ),
          title: Text("${Common.convertDateToString(DateTime.parse(periodicite!.libelle!))}",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("#Preneur: ${periodicite?.preneur?.displayName ?? ""}",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontFamily:
                    GoogleFonts.raleway(fontWeight: FontWeight.w700).fontFamily),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              /*Text("Période: ${cotisation.periode?.libelle ?? ""}",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontFamily:
                    GoogleFonts.raleway(fontWeight: FontWeight.w700).fontFamily),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),*/
            ],
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${Common.fcfa_currency_format().format(periodicite?.montantCotisation)}",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 5,),
              Container(
                width: 100,
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: periodicite?.isPaid == 1 ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                    child: Text("${periodicite?.isPaid == 1 ? "PAYE" : "NON PAYE"}",
                        style: TextStyle(
                            color: periodicite?.isPaid == 1 ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontFamily: GoogleFonts.raleway(
                                fontWeight: FontWeight.w700)
                                .fontFamily))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}