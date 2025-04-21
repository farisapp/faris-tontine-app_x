import 'package:faris/controller/ikoddi_airtime_controller.dart';
import 'package:faris/data/repositories/ikoddi_airtime_repository.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:faris/common/app_constant.dart';
import 'package:faris/controller/add_tontine_controller.dart';
import 'package:faris/controller/auth_controller.dart';
import 'package:faris/controller/contact_controller.dart';
import 'package:faris/controller/cotiser_controller.dart';
import 'package:faris/controller/last_tontine_controller.dart';
import 'package:faris/controller/notification_controller.dart';
import 'package:faris/controller/request_tontine_controller.dart';
import 'package:faris/controller/splash_controller.dart';
import 'package:faris/controller/tontine_controller.dart';
import 'package:faris/controller/tontine_details_controller.dart';
import 'package:faris/controller/user_controller.dart';
import 'package:faris/data/core/api_client.dart';
import 'package:faris/data/repositories/auth_repo.dart';
import 'package:faris/data/repositories/faris_tontine_repo.dart';
import 'package:faris/data/repositories/notification_repo.dart';
import 'package:faris/data/repositories/splash_repo.dart';
import 'package:faris/data/repositories/user_repo.dart';

import '../controller/indiv_add_tontine_controller.dart';

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  // Injection des dépendances partagées
  Get.lazyPut(() => sharedPreferences);
  Get.lazyPut(() => ApiClient(
      appBaseUrl: AppConstant.BASE_URL, sharedPreferences: Get.find()));

  // Repositories
  Get.lazyPut(
      () => AuthRepo(sharedPreferences: Get.find(), apiClient: Get.find()),
      fenix: true);
  Get.lazyPut(() => FarisTontineRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => UserRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(
      () => NotificationRepo(
          apiClient: Get.find(), sharedPreferences: Get.find()),
      fenix: true);
  Get.lazyPut(() => IkkodiAirtimeRepository(apiClient: Get.find()),
      fenix: true);
  Get.lazyPut(
      () => SplashRepo(apiClient: Get.find(), sharedPreferences: Get.find()),
      fenix: true);

  // Controllers
  Get.lazyPut(() => SplashController(splashRepo: Get.find()), fenix: true);
  Get.lazyPut(() => AuthController(authRepo: Get.find()), fenix: true);
  Get.lazyPut(() => UserController(userRepo: Get.find()));
  Get.lazyPut(() => AddTontineController(farisTontineRepo: Get.find()));
  Get.lazyPut(() => IndivAddTontineController(farisTontineRepo: Get.find()));
  Get.lazyPut(() => LastTontineController(farisTontineRepo: Get.find()));
  Get.lazyPut(() => TontineDetailsController(farisTontineRepo: Get.find()),
      fenix: true);
  Get.lazyPut(() => CotiserController(farisTontineRepo: Get.find()),
      fenix: true);
  Get.lazyPut(() => TontineController(farisTontineRepo: Get.find()),
      fenix: true);
  Get.lazyPut(
      () => RequestTontineController(
          farisTontineRepo: Get.find(), userRepo: Get.find()),
      fenix: true);
  Get.lazyPut(
      () => ContactController(userRepo: Get.find(), tontineRepo: Get.find()),
      fenix: true);
  Get.lazyPut(() => NotificationController(notificationRepo: Get.find()),
      fenix: true);
  Get.lazyPut(
      () => IkoddiAirtimeController(ikoddiAirtimeRepository: Get.find()),
      fenix: true);
}
