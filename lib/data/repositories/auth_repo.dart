
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:faris/common/app_constant.dart';
import 'package:faris/data/core/api_client.dart';
import 'package:faris/data/models/body/signup_body.dart';

class AuthRepo {
  
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  AuthRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response> register(SignUpBody signUpBody) async {
    return await apiClient.postData('${AppConstant.REGISTER_URI}', signUpBody.toJson());
  }

  Future<Response> login({String? phone, String? password}) async {
    return await apiClient.postData('${AppConstant.LOGIN_URI}', {"telephone": phone, "password": password});
  }

  Future<Response> updatePassword({String? phone, String? password}) async {
    return await apiClient.postData('${AppConstant.UPDATE_PASSWORD_URI}', {"telephone": phone, "password": password});
  }

  Future<Response> updateToken() async {
    String? _deviceToken;
    if(GetPlatform.isIOS){
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
          alert: true, announcement: false, badge: true, carPlay: false,
          criticalAlert: false, provisional: false, sound: true
      );
      if(settings.authorizationStatus == AuthorizationStatus.authorized){
        _deviceToken = await _saveDeviceToken();
      }
    }else{
      _deviceToken = await _saveDeviceToken();
    }
    FirebaseMessaging.instance.subscribeToTopic(AppConstant.TOPIC);

    return await apiClient.postData('${AppConstant.TOKEN_URI}', {"_method": "put", "cm_firebase_token": _deviceToken});
  }


  Future<String> _saveDeviceToken() async {
    String? _deviceToken = '';
    if(GetPlatform.isIOS){
      _deviceToken = await FirebaseMessaging.instance.getAPNSToken();
    }else{
      _deviceToken = await FirebaseMessaging.instance.getToken();
    }
    if(_deviceToken != null) {
      print('Device token => '+_deviceToken);
    }
    return _deviceToken!;
  }

  Future<Response> forgetPassword(String phone) async {
    return await apiClient.postData('${AppConstant.FORGET_PASSWORD_URI}', {"telephone": phone});
  }

  Future<Response> verifyToken(String phone, String token) async {
    return await apiClient.postData('${AppConstant.VERIFY_TOKEN_URI}', {"telephone": phone, "reset_token": token});
  }

  Future<Response> resetPassword(String resetToken, String phone, String password, String confirmPassword) async {
    return await apiClient.postData('${AppConstant.RESET_PASSWORD_URI}',
        {"_method": "put", "reset_token": resetToken, "telephone": phone, "password": password, "confirm_password": confirmPassword});
  }

  Future<Response> checkPhone(String phone) async {
    return await apiClient.postData('${AppConstant.CHECK_EMAIL_URI}', {"telephone": phone});
  }

  Future<Response> verifyPhone(String phone, String token) async {
    return await apiClient.postData('${AppConstant.VERIFY_EMAIL_URI}', {"telephone": phone, "token": token});
  }

  Future<bool> saveUserToken(String token) async {
    apiClient.token = token;
    apiClient.updateHeader(token);
    return await sharedPreferences.setString(AppConstant.TOKEN, token);
  }

  String getUserToken(){
    return sharedPreferences.getString(AppConstant.TOKEN) ?? "";
  }

  bool isLoggedIn() {
    return sharedPreferences.containsKey(AppConstant.TOKEN);
  }

  bool clearSharedData() {
    sharedPreferences.remove(AppConstant.TOKEN);
    apiClient.token = null;
    apiClient.updateHeader(null);
    print("CLEAR SHARE DATA OK");
    return true;
  }

  Future<void> saveUserPhoneAndPassword(String phone, String password) async {
    try {
      await sharedPreferences.setString(AppConstant.USER_PASSWORD, password);
      await sharedPreferences.setString(AppConstant.USER_TELEPHONE, phone);
    }catch(e){
      throw e;
    }
  }

  String getUserPhone(){
    return sharedPreferences.getString(AppConstant.USER_TELEPHONE) ?? "";
  }

  String getUserPassword(){
    return sharedPreferences.getString(AppConstant.USER_PASSWORD) ?? "";
  }

  bool isNotificationActive() {
    return sharedPreferences.getBool(AppConstant.NOTIFICATION) ?? true;
  }

  bool? setNotificationActive(bool isActive) {
    if(isActive) {
      updateToken();
    }else{
      FirebaseMessaging.instance.unsubscribeFromTopic(AppConstant.TOPIC);
    }
    sharedPreferences.setBool(AppConstant.NOTIFICATION, isActive);
  }

  Future<bool> clearUserNumberAndPassword() async {
    await sharedPreferences.remove(AppConstant.USER_PASSWORD);
    return await sharedPreferences.remove(AppConstant.USER_TELEPHONE);
  }
}