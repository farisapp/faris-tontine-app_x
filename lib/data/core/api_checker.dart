
import 'package:faris/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:faris/presentation/journey/auth/signin_page.dart';
import 'package:faris/presentation/widgets/custom_snackbar.dart';
import 'package:faris/route/routes.dart';

class ApiChecker {
  static void CheckApi(Response response) {
    if(response.statusCode == 401) {
      Get.find<AuthController>().clearSharedData();
      Get.offAllNamed(RouteHelper.getAuthRoute());
    }else{
      Get.showSnackbar(GetSnackBar(
        backgroundColor:Colors.red,
        message: response.statusText,
        maxWidth: Get.width,
        duration: Duration(seconds: 3),
        snackStyle: SnackStyle.FLOATING,
        margin: EdgeInsets.all(5),
        borderRadius: 5,
        isDismissible: true,
        dismissDirection: DismissDirection.endToStart,
      ));
    }
  }
}