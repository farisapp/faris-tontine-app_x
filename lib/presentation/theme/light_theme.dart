
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:faris/presentation/theme/theme_color.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: GoogleFonts.lato().fontFamily,
  //appBarTheme: AppBarTheme(backgroundColor: Colors.grey[200]),
  primaryColor: AppColor.kTontinet_primary,
  colorScheme: ColorScheme.light(primary: AppColor.kTontinet_primary, secondary: AppColor.kTontinet_secondary) ,
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: AppColor.kTontinet_primary_light))
);