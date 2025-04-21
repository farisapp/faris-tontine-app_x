import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:faris/presentation/theme/theme_color.dart';

class TitreWidget extends StatelessWidget {
  final String titre;
  final Color? titreColor;
  final Color? lineColor;
  const TitreWidget({Key? key, required this.titre, this.titreColor, this.lineColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$titre".toUpperCase(), style: TextStyle(color: titreColor ?? AppColor.kTontinet_secondary_dark, fontSize: 16, fontFamily: GoogleFonts.raleway(fontWeight: FontWeight.w900).fontFamily)),
          Container(
            margin: EdgeInsets.only(top: 5),
            height: 4,
            width: 90,
            color: lineColor ?? Colors.orange,
          )
        ],
      ),
    );
  }
}
