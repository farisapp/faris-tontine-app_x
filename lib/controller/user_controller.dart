import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:faris/data/core/api_checker.dart';
import 'package:faris/data/models/response_model.dart';
import 'package:faris/data/models/user_model.dart';
import 'package:faris/data/repositories/user_repo.dart';
import 'package:http/http.dart' as http;

class UserController extends GetxController implements GetxService {

  final UserRepo userRepo;

  UserController({required this.userRepo});

  User? _userInfo;
  ImagePicker? _picker;
  XFile? _image;
  File? _pickedImage;
  bool _isLoading = false;

  User? get userInfo => _userInfo;
  ImagePicker? get picker => _picker;
  XFile? get image => _image;
  File? get pickedImage => _pickedImage;
  bool get isLoading => _isLoading;

  Future<ResponseModel> getUserInfo() async {
    _image = null;
    ResponseModel _responseModel;
    Response response = await userRepo.getUserInfo();
    if (response.statusCode == 200) {
      _userInfo = User.fromJson(response.body['user']);
      _responseModel = ResponseModel(true, 'successful');
    } else {
      _responseModel = ResponseModel(false, response.statusText);
      ApiChecker.CheckApi(response);
    }
    update();
    return _responseModel;
  }

  Future<ResponseModel> updateUserInfo(User updateUser, String token) async {
    _isLoading = true;
    update();
    ResponseModel _responseModel;
    http.StreamedResponse response = await userRepo.updateProfile(updateUser, _image, token);
    _isLoading = false;
    if (response.statusCode == 200) {
      Map map = jsonDecode(await response.stream.bytesToString());
      String message = map["message"];
      _userInfo = updateUser;
      _responseModel = ResponseModel(true, message);
      _image = null;
      getUserInfo();
      print(message);
    } else {
      //print(response.stream.bytesToString());
      _responseModel = ResponseModel(false, '${response.statusCode} ${response.reasonPhrase}');
      print('${response.statusCode} ${response.reasonPhrase}');
    }
    update();
    return _responseModel;
  }

  Future<ResponseModel> changePassword(String oldPassword, String newPassword, String confirmPassword) async {
    _isLoading = true;
    update();
    ResponseModel _responseModel;
    Response response = await userRepo.changePassword(oldPassword, newPassword, confirmPassword);
    _isLoading = false;
    if (response.statusCode == 200) {
      String message = response.body["message"];
      _responseModel = ResponseModel(true, message);
    } else {
      _responseModel = ResponseModel(false, response.statusText);
    }
    update();
    return _responseModel;
  }

  void pickImage() async {
    _image = await _picker?.pickImage(source: ImageSource.gallery);
    //_pickedImage = File(_image!.path);
    update();
  }

  void initData() {
    _picker = ImagePicker();
  }

}