import 'package:faris/common/app_constant.dart';
import 'package:faris/controller/splash_controller.dart';
import 'package:faris/controller/user_controller.dart';
import 'package:faris/presentation/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:faris/presentation/theme/theme_color.dart';
import 'package:share_plus/share_plus.dart';

class BlocProfil extends StatelessWidget {
  final String nom;
  final String? citation;
  final String? avatar;

  const BlocProfil({Key? key, required this.nom, this.citation, this.avatar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
    );
  }
}
