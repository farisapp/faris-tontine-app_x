import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:faris/common/common.dart';
import 'package:faris/presentation/theme/theme_color.dart';

class CategorieServiceFarisNana extends StatelessWidget {
  final String titre;
  final String? subTitle;
  final String icon;
  final Color iconColor;
  final Color backgroundColor;
  //final int tontineCount;
  final String? type;
  final VoidCallback press;

  const CategorieServiceFarisNana({Key? key, required this.titre, required this.icon, required this.iconColor, required this.backgroundColor, required this.press, this.type, this.subTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      child: Container(
        height: 180,
        child: Stack(
          children: [
            // Conteneur principal avec gradient
            Container(
              height: 150,
              width: double.infinity,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.kTontinet_secondary,
                    backgroundColor,
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$titre",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: GoogleFonts
                          .raleway(fontWeight: FontWeight.w800)
                          .fontFamily,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    subTitle ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Icône en bas à gauche
            Positioned(
              bottom: 7,
              left: 15,
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Image.asset(
                    "$icon",
                    width: 32,
                  ),
                ),
              ),
            ),
            // Flèche à droite
            Positioned(
              bottom: 45,
              right: 15, // Positionné à droite
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_forward,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
