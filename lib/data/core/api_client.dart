import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:faris/common/app_constant.dart';
import 'package:faris/data/models/error_response.dart';

class ApiClient extends GetConnect implements GetxService {
  String appBaseUrl;
  final SharedPreferences sharedPreferences;

  String? token;
  Map<String, String>? _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    baseUrl = appBaseUrl;
    //print("BASE URL => $baseUrl");
    timeout = Duration(seconds: 30);
    token = sharedPreferences.getString(AppConstant.TOKEN);
    //print('Token: $token');
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Updated': '${AppConstant.APP_UPDATED}',
      'App-Version': '${AppConstant.APP_VERSION}'
    };
  }

  void updateHeader(String? token){
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'App-Version': '${AppConstant.APP_VERSION}'
    };
  }

  Future<Response> getData(String uri,
      {Map<String, dynamic>? query,
        String? contentType,
        Map<String, String>? headers,
        Function(dynamic)? decoder}) async {
    try {
      if (Foundation.kDebugMode) {
        print('GetX call: $uri\nToken: $token');
      }
      Response response = await get(
        uri,
        contentType: contentType,
        query: query,
        headers: headers ?? _mainHeaders,
        decoder: decoder,
      ).timeout(const Duration(seconds: 60)); // ✅ ICI

      response = handleResponse(response);

      if (Foundation.kDebugMode) {
        print('GetX Response: [${response.statusCode}] $uri\n${response.body}');
      }

      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> postData(String uri, dynamic body, {Map<String, dynamic>? query, String? contentType, Map<String, String>? headers,
    Function(dynamic)? decoder, Function(double)? uploadProgress}) async {
    try {
      if(Foundation.kDebugMode){
        print('GetX call: $uri\nToken: $token');
        print('GetX body: $body');
      }
      Response response = await post(
        uri,
        body,
        query: query,
        contentType: contentType,
        headers: headers ?? _mainHeaders,
        decoder: decoder,
        uploadProgress: uploadProgress,
      ).timeout(const Duration(seconds: 60));
      response = handleResponse(response);
      if(Foundation.kDebugMode){
        print('GetX Response: [${response.statusCode}] $uri\n${response.body}');
      }
      return response;
    }catch (e){
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> putData(String uri, dynamic body, {Map<String, dynamic>? query, String? contentType, Map<String, String>? headers,
    Function(dynamic)? decoder, Function(double)? uploadProgress}) async {
    try {
      if(Foundation.kDebugMode){
        print('GetX call: $uri\nToken: $token');
        print('GetX body: $body');
      }
      Response response = await put(
        uri, body,
        query: query,
        contentType: contentType,
        headers: headers ?? _mainHeaders,
        decoder: decoder,
        uploadProgress: uploadProgress,
      ).timeout(const Duration(seconds: 60));
      response = handleResponse(response);
      if(Foundation.kDebugMode){
        print('GetX Response: [${response.statusCode}] $uri\n${response.body}');
      }
      return response;
    }catch (e){
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> deleteData(String uri, {Map<String, dynamic>? query, String? contentType, Map<String, String>? headers, Function(dynamic)? decoder}) async {
    try {
      if(Foundation.kDebugMode){
        print('GetX call: $uri\nToken: $token');
      }
      Response response = await delete(
        uri,
        contentType: contentType,
        query: query,
        headers: headers ?? _mainHeaders,
        decoder: decoder,
      ).timeout(const Duration(seconds: 60));
      response = handleResponse(response);
      if(Foundation.kDebugMode){
        print('GetX Response: [${response.statusCode}] $uri\n${response.body}');
      }
      return response;
    }catch (e){
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Response handleResponse(Response response) {
    Response _response = response;
    if(_response.hasError && _response.body != null && response.body is !String) {
      if(_response.body.toString().startsWith('{errors: [{code:')){
        ErrorResponse _errorResponse = ErrorResponse.fromJson(_response.body);
        _response = Response(statusCode: _response.statusCode, body: _response.body, statusText: _errorResponse.errors[0].message);
      }else if(_response.body.toString().startsWith('{error')){
        _response = Response(statusCode: _response.statusCode, body: _response.body, statusText: _response.body['message']);
      }
    }else if(_response.hasError && _response.body == null){
      _response = Response(statusCode: 0, statusText: 'Echec de la connexion au serveur');
    }
    return _response;
  }
}
