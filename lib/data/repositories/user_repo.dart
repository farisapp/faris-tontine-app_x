import 'dart:io';

import 'package:get/get.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:image_picker/image_picker.dart';
import 'package:faris/common/app_constant.dart';
import 'package:faris/data/core/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:faris/data/models/user_model.dart';

class UserRepo {

  final ApiClient apiClient;

  UserRepo({required this.apiClient});

  Future<Response> getUserInfo() async {
    return await apiClient.getData(AppConstant.USER_INFO_URI);
  }

  Future<http.StreamedResponse> updateProfile(User userInfo, XFile? data, String token) async {
    http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse('${AppConstant.BASE_URL}${AppConstant.UPDATE_PROFILE_URI}'));
    request.headers.addAll(<String,String>{'Authorization': 'Bearer $token'});
    if(GetPlatform.isMobile && data != null) {
      File _file = File(data.path);
      request.files.add(http.MultipartFile('avatar', _file.readAsBytes().asStream(), _file.lengthSync(), filename: _file.path.split('/').last));
    }
    Map<String, String> _fields = Map();
    _fields.addAll(<String, String>{
      'nom': userInfo.nom ?? "", 'prenom': userInfo.prenom ?? "", 'email': userInfo.email ?? ""
    });
    print("${_fields.toString()}");
    request.fields.addAll(_fields);
    http.StreamedResponse response = await request.send();
    return response;
  }

  Future<Response> changePassword(String oldPassword, String newPassword, String confirmPassword) async {
    return await apiClient.postData(AppConstant.UPDATE_PASSWORD_URI, {'old_password': oldPassword, 'new_password': newPassword,
      'confirm_password': confirmPassword});
  }

  Future<Response> searchUser(String numero) async {
    return await apiClient.getData('${AppConstant.SEARCH_USER_URI}?numero=${numero}');
  }

  Future<Response> getUserRequests() async {
    return await apiClient.getData('${AppConstant.USER_REQUEST_LIST}');
  }
}