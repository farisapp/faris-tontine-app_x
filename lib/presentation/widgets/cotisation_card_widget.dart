import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:faris/common/common.dart';
import 'package:faris/data/models/cotisation_model.dart';

class CotisationCardWidget extends StatelessWidget {
  final Cotisation cotisation;

  CotisationCardWidget({Key? key, required this.cotisation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 8),
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
        title: Text("${cotisation.membre?.displayName ?? "Membre"}",
          style: TextStyle(
              fontSize: 13,
              fontFamily:
              GoogleFonts.raleway(fontWeight: FontWeight.w800).fontFamily),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("#${cotisation.provider ?? ""}",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontFamily:
                  GoogleFonts.raleway(fontWeight: FontWeight.w700).fontFamily),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text("Période: ${cotisation.periode != null ? Common.convertDateToString(DateTime.parse(cotisation.periode!.libelle!)) : ""}",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontFamily:
                  GoogleFonts.raleway(fontWeight: FontWeight.w700).fontFamily),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("${Common.fcfa_currency_format().format(cotisation.montant ?? 0)}",
              style: TextStyle(
                  fontSize: 15,
                  fontFamily:
                  GoogleFonts.raleway(fontWeight: FontWeight.w800).fontFamily),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 5,),
            Container(
              width: 100,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10)),
              child: Center(
                  child: Text("${cotisation.statut == "PAID" ? "PAYE" : "NON PAYE"}",
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontFamily: GoogleFonts.raleway(
                              fontWeight: FontWeight.w700)
                              .fontFamily))),
            ),
          ],
        ),
      ),
    );
  }
}
