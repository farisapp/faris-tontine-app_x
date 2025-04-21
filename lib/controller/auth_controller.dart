
import 'package:faris/data/core/api_checker.dart';
import 'package:get/get.dart';
import 'package:faris/data/models/body/signup_body.dart';
import 'package:faris/data/models/response_model.dart';
import 'package:faris/data/repositories/auth_repo.dart';

class AuthController extends GetxController {

  final AuthRepo authRepo;

  AuthController({required this.authRepo}){
    _notification = authRepo.isNotificationActive();
  }

  bool _isLoading = false;
  bool _resetLoading = false;
  bool _notification = true;
  bool _acceptTerms = true;
  String _verificationCode = '';
  bool _isActiveRememberMe = false;


  bool get isLoading => _isLoading;
  bool get resetLoading => _resetLoading;
  bool get notification => _notification;
  bool get acceptTerms => _acceptTerms;
  String get verificationCode => _verificationCode;
  bool get isActiveRememberMe => _isActiveRememberMe;

  Future<ResponseModel> registration(SignUpBody signUpBody) async {
    _isLoading = true;
    update();
    Response response = await authRepo.register(signUpBody);
    ResponseModel responseModel;
    if(response.statusCode == 200){
      authRepo.saveUserToken(response.body['token']);
      await authRepo.updateToken();
      responseModel = ResponseModel(true, response.body['token']);
    }else{
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }


  Future<ResponseModel> login(String phone, String password) async{
    _isLoading = true;
    update();

    Response response = await authRepo.login(phone: phone, password: password);
    ResponseModel responseModel;
    if(response.statusCode == 200){
      authRepo.saveUserToken(response.body['token']);
      await authRepo.updateToken();
      responseModel = ResponseModel(true, '${response.body['token']}');
    }else{
      responseModel = ResponseModel(false, response.body['message']);
    }
    _isLoading = false;
    update();
    return responseModel;
  }


  void navigate() async {
    if(Get.find<AuthController>().isLoggedIn()){
      //await Get.find<MetaDataController>().getFavoriteList();
      //await Get.find<MetaDataController>().getLikeDislikeList();
    }
    //Get.offAllNamed(AppRoutes.getInitialRoute());
  }

  Future<ResponseModel> forgetPassword(String phone) async {
    _resetLoading = true;
    update();
    Response response = await authRepo.forgetPassword(phone);
    ResponseModel responseModel;
    if(response.statusCode == 200){
      responseModel = ResponseModel(true, response.body['message']);
    }else{
      responseModel = ResponseModel(false, response.statusText);
    }
    _resetLoading = false;
    update();
    return responseModel;
  }

  Future<void> updateToken() async {
    await authRepo.updateToken();
  }

  Future<ResponseModel> verifyToken(String phone) async {
    _resetLoading = true;
    update();
    Response response = await authRepo.verifyToken(phone, _verificationCode);
    ResponseModel responseModel;
    if(response.statusCode == 200){
      responseModel = ResponseModel(true, response.body["message"]);
    }else{
      responseModel = ResponseModel(false, response.statusText);
    }
    _resetLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> resetPassword(String resetToken, String phone, String password, String confirmPassword) async {
    _resetLoading = true;
    update();
    Response response = await authRepo.resetPassword(resetToken, phone, password, confirmPassword);
    ResponseModel responseModel;
    if(response.statusCode == 200){
      responseModel = ResponseModel(true, response.body["message"]);
    }else{
      responseModel = ResponseModel(false, response.statusText);
    }
    _resetLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> checkPhone(String phone) async {
    _isLoading = true;
    update();
    Response response = await authRepo.checkPhone(phone);
    ResponseModel responseModel;
    if(response.statusCode == 200){
      responseModel = ResponseModel(true, response.body["token"]);
    }else{
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> verifyEmail(String phone, String token) async {
    _isLoading = true;
    update();
    Response response = await authRepo.verifyPhone(phone, _verificationCode);
    ResponseModel responseModel;
    if(response.statusCode == 200){
      authRepo.saveUserToken(token);
      await authRepo.updateToken();
      responseModel = ResponseModel(true, response.body["message"]);
    }else{
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }


  void updateVerificationCode(String query){
    _verificationCode = query;
    update();
  }

  void toogleTerms() {
    _acceptTerms = !_acceptTerms;
    update();
  }

  void toogleRememberMe() {
    _isActiveRememberMe = !_isActiveRememberMe;
    update();
  }

  bool isLoggedIn() {
    return authRepo.isLoggedIn();
  }

  void clearSharedData() {
    authRepo.clearSharedData();
    update();
  }

  void saveUserPhoneAndPassword(String phone, String password){
    authRepo.saveUserPhoneAndPassword(phone, password);
    update();
  }

  String getUserPhone() {
    return authRepo.getUserPhone();
  }

  String getUserPassword() {
    return authRepo.getUserPassword();
  }

  Future<bool> clearUsertPhoneAndPassword() async {
    return authRepo.clearUserNumberAndPassword();
  }

  String getUserToken() {
    return authRepo.getUserToken();
  }

  bool setNotificationActive(bool isActive){
    print("NOTIFICATION => $isActive");
    _notification = isActive;
    authRepo.setNotificationActive(isActive);
    update();
    return _notification;
  }
  
}