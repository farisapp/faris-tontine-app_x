
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:faris/common/app_constant.dart';
import 'package:faris/common/html_type.dart';
import 'package:faris/controller/splash_controller.dart';
import 'package:faris/data/models/tontine_model.dart';
import 'package:faris/presentation/journey/auth/auth_page.dart';
import 'package:faris/presentation/journey/auth/forgot_password_page.dart';
import 'package:faris/presentation/journey/auth/reset_password_page.dart';
import 'package:faris/presentation/journey/auth/signin_page.dart';
import 'package:faris/presentation/journey/auth/signup_page.dart';
import 'package:faris/presentation/journey/auth/verification_page.dart';
import 'package:faris/presentation/journey/html/html_viewer_page.dart';
import 'package:faris/presentation/journey/main_page.dart';
import 'package:faris/presentation/journey/onboarding_page.dart';
import 'package:faris/presentation/journey/profil/edit_profil_page.dart';
import 'package:faris/presentation/journey/splash/splash_screen.dart';
import 'package:faris/presentation/journey/tontine/success_page.dart';
import 'package:faris/presentation/journey/tontine/indiv_tontine_details_page.dart';


import '../offline_page.dart';

class RouteHelper {

  static const String OFFLINE = '/offline';
  static String getOfflineRoute() => '$OFFLINE';
  static String getSplashRoute() => '/splash';
  // static String getSplashRoute() => '/splash';
  static const String INITIAL = '/';
  static const String MAIN = '/main';
  static const String SPLASH_SCREEN = '/splash';
  static const String ONBOARDING = '/onboarding';
  static const String HOME = '/home';
  static const String AUTH = '/auth';
  static const String SIGNIN = '/signin';
  static const String SIGNUP = '/signup';
  static const String VERIFICATION = '/verification';
  static const String PROFIL = '/profil';
  static const String UPDATE_PROFIL = '/update-profile';
  static const String FORGOT_PASSWORD = '/forgot-password';
  static const String RESET_PASSWORD = '/reset-password';
  static const String HTML = '/html';
  static const String TONTINE_LIST = '/tontines';
  static const String TONTINE_DETAILS = '/tontine-details';
  static const String TONTINE_CREATE = '/tontine-create';
  static const String TONTINE_CREATE_SUCCESS = '/tontine-create-confirm';
  static const String STORE_LIST = '/store-list';
  static const String ADD_STORE = '/add-store';
  static const String STORE_DETAILS = '/store-details';
  static String getStoreListRoute() => STORE_LIST;
  static String getAddStoreRoute() => ADD_STORE;
  static String getStoreDetailsRoute(int storeID) => '$STORE_DETAILS?id=$storeID';

  static String getInitialRoute() => '$INITIAL';
  static String getOnBoardingRoute() => '$ONBOARDING';
  static String getAuthRoute() => '$AUTH';
  static String getSignInRoute(String page) => '$SIGNIN?page=$page';
  static String getSignUpRoute() => '$SIGNUP';
  static String getVerificationRoute(String number, String token, String page, String pass) {
    return '$VERIFICATION?page=$page&number=$number&token=$token&pass=$pass';
  }

  static String getMainRoute(String page) => '$MAIN?page=$page';
  static String getForgotPassRoute() => '$FORGOT_PASSWORD';
  static String getResetPasswordRoute(String phone, String token, String page) => '$RESET_PASSWORD?phone=$phone&token=$token&page=$page';
  static String getTontineDetailsRoute(int tontineID) {
    return '$TONTINE_DETAILS?id=$tontineID';
  }
  static String getTontineSuccessRoute(String tontineID, String status) => '$TONTINE_CREATE_SUCCESS?id=$tontineID&status=$status';
  static String getUpdateProfileRoute() => '$UPDATE_PROFIL';
  //static String getFarisPayPaymentRoute(String id, int user) => '$payment?id=$id&user=$user';
  //static String getCheckoutRoute(String page) => '$checkout?page=$page';
  static String getHtmlRoute(String page) => '$HTML?page=$page';


  static List<GetPage> routes = [
    GetPage(name: OFFLINE, page: () => OfflinePage()), // Page hors-ligne
     GetPage(name: '/splash', page: () => SplashScreen()),
    // GetPage(name: '/splash', page: () => SplashScreen()),
    GetPage(name: '/offline', page: () => OfflinePage()),
    GetPage(name: INITIAL, page: () => getRoute(MainPage(pageIndex: 0))),
    GetPage(name: SPLASH_SCREEN, page: () => SplashScreen()),
    GetPage(name: ONBOARDING, page: () => OnBoardingPage()),
    GetPage(name: AUTH, page: () => AuthPage()),
    GetPage(name: SIGNUP, page: () => SignupPage()),
    GetPage(name: SIGNIN, page: () => SigninPage(
      exitFromApp: Get.parameters['page'] == SIGNUP || Get.parameters['page'] == SPLASH_SCREEN || Get.parameters['page'] == ONBOARDING,
    )),
    GetPage(name: VERIFICATION, page: () {
      List<int> _decode = base64Decode(Get.parameters['pass']!);
      String _data = utf8.decode(_decode);
      return VerificationPage(
        number: Get.parameters['number'], fromSignUp: Get.parameters['page'] == SIGNUP, token: Get.parameters['token'], password: _data,
      );
    }),

    GetPage(name: MAIN, page: () => getRoute(MainPage(
      pageIndex: Get.parameters['page'] == 'home' ? 0 : Get.parameters['page'] == 'notification' ? 1
          : Get.parameters['page'] == 'profil' ? 2 : 0,
    ))),

    GetPage(name: FORGOT_PASSWORD, page: () => ForgotPasswordPage()),
    GetPage(name: RESET_PASSWORD, page: () => ResetPasswordPage(
      resetToken: Get.parameters['token'], number: Get.parameters['phone'], fromPasswordChange: Get.parameters['page'] == 'password-change',
    )),
    GetPage(name: UPDATE_PROFIL, page: () => EditProfilPage()),
    GetPage(name: TONTINE_DETAILS, page: () {
      return getRoute(Get.arguments != null ? Get.arguments : IndivTontineDetailsPage(tontine: Tontine(id: int.parse(Get.parameters['id'].toString()))));
    }),
    GetPage(name: TONTINE_CREATE_SUCCESS, page: () => getRoute(AddTontineSuccessPage(
      code_tontine: Get.parameters['code_tontine'],
      tontineID: Get.parameters['id'], status: Get.parameters['status']!.contains('success') ? 1 : 0,
    ))),

    GetPage(name: HTML, page: () => HtmlViewerPage(
      htmlType: Get.parameters['page'] == 'terms-and-condition' ? HtmlType.TERMS_AND_CONDITION
          : Get.parameters['page'] == 'privacy-policy' ? HtmlType.PRIVACY_POLICY
          : Get.parameters['page'] == 'about-us' ? HtmlType.ABOUT_US
          : Get.parameters['page'] == 'tuto' ? HtmlType.TUTO : HtmlType.FAQ,


    )),
  ];

  static getRoute(Widget navigateTo) {
    int _minimumVersion = 0;
    if(GetPlatform.isAndroid) {
      _minimumVersion = Get.find<SplashController>().config?.appMinimumVersionAndroid ?? 0;
    }
    if (AppConstant.APP_VERSION < _minimumVersion) {
      //return UpdateScreen(isUpdate: true);
    } else {
      return navigateTo;
      /*if (Get.find<SplashController>().config!.maintenanceMode!) {
        //return UpdateScreen(isUpdate: false);
      } else {

      }*/
    }
  }
}
