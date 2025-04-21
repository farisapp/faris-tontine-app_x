import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:faris/controller/auth_controller.dart';
import 'package:faris/controller/splash_controller.dart';
import 'package:faris/route/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initSplash();
  }

  Future<void> _initSplash() async {
    Get.find<SplashController>().initSharedData();
    final isSuccess = await Get.find<SplashController>().getConfigData();

    if (isSuccess) {
      await Future.delayed(const Duration(seconds: 1));
      if (Get.find<SplashController>().showIntro()) {
        Get.offNamed(RouteHelper.getOnBoardingRoute());
      } else {
        if (Get.find<AuthController>().isLoggedIn()) {
          Get.find<AuthController>().updateToken();
          Get.offNamed(RouteHelper.getInitialRoute());
        } else {
          Get.offNamed(RouteHelper.getAuthRoute());
        }
      }
    } else {
      Get.snackbar('Erreur', 'Échec de chargement de la configuration');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      backgroundColor: Colors.white, // fond blanc simple
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/logo.png",
              height: 120,
            ),
            const SizedBox(height: 20),
            const Text(
              "Développé par Faris Business Group",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Colors.orange), // tu peux le retirer aussi
          ],
        ),
      ),
    );
  }
}
