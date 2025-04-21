
import 'package:get/get.dart';
import 'package:faris/data/core/api_checker.dart';
import 'package:faris/data/models/notification_model.dart';
import 'package:faris/data/repositories/notification_repo.dart';

class NotificationController extends GetxController implements GetxService {

  final NotificationRepo notificationRepo;

  NotificationController({required this.notificationRepo});

  List<Notification>? _notificationList;
  List<Notification>? get notificationList => _notificationList;

  Future<int> getNotificationList(bool reload) async {
    if(_notificationList == null || reload) {
      Response response = await notificationRepo.getNotificationList();
      if (response.statusCode == 200) {
        _notificationList = [];
        List<dynamic> _notifications = response.body.reversed.toList();
        _notifications.forEach((notification) => _notificationList!.add(Notification.fromJson(notification)));
      } else {
        ApiChecker.CheckApi(response);
      }
      update();
    }
    return _notificationList != null ? _notificationList!.length  : 0;
  }

  void saveSeenNotificationCount(int count) {
    notificationRepo.saveSeenNotificationCount(count);
  }

  int? getSeenNotificationCount() {
    return notificationRepo.getSeenNotificationCount();
  }

  void clearNotification() {
    _notificationList = null;
  }

}