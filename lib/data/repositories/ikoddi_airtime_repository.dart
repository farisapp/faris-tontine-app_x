import 'dart:convert';

import 'package:get/get_connect/http/src/response/response.dart';
import 'package:faris/common/app_constant.dart';
import 'package:faris/data/core/api_client.dart';

class IkkodiAirtimeRepository {
  final ApiClient apiClient;

  IkkodiAirtimeRepository({required this.apiClient});

  Future<Response> getMobileCreditPlansList() async {
    return await apiClient
        .getData('${AppConstant.MOBILE_CREDIT_PLANS_LIST_URI}');
  }

  Future<Response> getInternetPlansList() async {
    return await apiClient.getData('${AppConstant.INTERNET_PLANS_LIST_URI}');
  }

  Future<Response> getBuyAirtimeHistoryList() async {
    return await apiClient
        .getData('${AppConstant.BUY_AIRTIME_HISTORY_LIST_URI}');
  }

  Future<Response> buyAirtime(Map<String, dynamic> buyAirtimeData) async {
    return await apiClient.postData(
        '${AppConstant.BUY_AIRTIME_URI}', jsonEncode(buyAirtimeData));
  }
}
