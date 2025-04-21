
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:faris/common/app_constant.dart';
import 'package:faris/data/core/api_client.dart';

class NotificationRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  NotificationRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response> getNotificationList() async {
    return await apiClient.getData(AppConstant.NOTIFICATION_URI);
  }

  void saveSeenNotificationCount(int count) {
    sharedPreferences.setInt(AppConstant.NOTIFICATION_COUNT, count);
  }

  int? getSeenNotificationCount() {
    return sharedPreferences.getInt(AppConstant.NOTIFICATION_COUNT);
  }

}