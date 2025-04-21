import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:faris/presentation/theme/theme_color.dart';

class EmptyBoxWidget extends StatelessWidget {
  final String titre;
  final String icon;
  final String iconType;

  const EmptyBoxWidget({Key? key, required this.titre, required this.icon, required this.iconType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if(iconType == "svg") ...[
            SvgPicture.asset("$icon", width: 80, height: 80, color: AppColor.kTontinet_textColor1,)
          ] else if(iconType == "png") ...[
            Image.asset("$icon", width: 80, height: 80),
          ] else if(iconType == "lottie") ...[
            Lottie.asset(
              icon,
              width: 200,
              height: 200,
            ),
          ],
          SizedBox(height: 10,),
          Text("$titre", style: TextStyle(color: AppColor.kTontinet_textColor1, fontSize: 14), textAlign: TextAlign.center,)
        ],
      ),
    );
  }
}
