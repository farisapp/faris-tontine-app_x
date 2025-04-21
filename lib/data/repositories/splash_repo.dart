
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:faris/common/app_constant.dart';
import 'package:faris/data/core/api_client.dart';
import 'package:http/http.dart' as http;

class SplashRepo {
  ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  SplashRepo({required this.sharedPreferences, required this.apiClient});

  Future<Response> getConfigData() async {
    Response _response = await apiClient.getData(AppConstant.APP_SETTINGS_URI);
    return _response;
  }

  Future<http.Response> getShortLink(String longUrl) async {
    return await http.post(Uri.parse(AppConstant.SHORT_LINK_URI), body: {'url': longUrl});
  }

  Future<bool> initSharedData() {
    if(!sharedPreferences.containsKey(AppConstant.NOTIFICATION)) {
      sharedPreferences.setBool(AppConstant.NOTIFICATION, true);
    }
    if(!sharedPreferences.containsKey(AppConstant.INTRO)) {
      sharedPreferences.setBool(AppConstant.INTRO, true);
    }
    if(!sharedPreferences.containsKey(AppConstant.NOTIFICATION_COUNT)) {
      sharedPreferences.setInt(AppConstant.NOTIFICATION_COUNT, 0);
    }
    return Future.value(true);
  }

  void disableIntro() {
    sharedPreferences.setBool(AppConstant.INTRO, false);
  }

  bool showIntro() {
    return sharedPreferences.getBool(AppConstant.INTRO)!;
  }
}