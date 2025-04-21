import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:faris/controller/auth_controller.dart';
import 'package:faris/controller/notification_controller.dart';
import 'package:faris/presentation/theme/theme_color.dart';
import 'package:faris/presentation/widgets/empty_box_widget.dart';
import 'package:faris/presentation/widgets/not_loggin_widget.dart';


class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  void _loadData() async {
    Get.find<NotificationController>().clearNotification();
    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<NotificationController>().getNotificationList(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    _loadData();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Image.asset("assets/images/logo.png", height: 45,),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColor.kTontinet_primary_light),
        leading: SizedBox.shrink(),
        centerTitle: true,
      ),
      body: Get.find<AuthController>().isLoggedIn() ? GetBuilder<NotificationController>(builder: (notificationController) {
        if(notificationController.notificationList != null) {
          notificationController.saveSeenNotificationCount(notificationController.notificationList!.length);
        }
        return notificationController.notificationList != null ? notificationController.notificationList!.length > 0 ? Padding(
          padding: const EdgeInsets.only(top: 20),
          child: RefreshIndicator(
              onRefresh: () async {
                await notificationController.getNotificationList(true);
              },
            child: ListView.separated(
                itemCount: notificationController.notificationList!.length,
                separatorBuilder: (context, index){
                  return Divider(color: Colors.grey.withOpacity(0.3),);
                },
                itemBuilder: (context, index){
                  return Container(
                    width: size.width,
                    child: ListTile(
                      leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: AppColor.kTontinet_iconColor,
                              shape: BoxShape.circle
                          ),
                          child: Center(child: Icon(Icons.notifications, color: AppColor.kTontinet_primary,))
                      ),
                      title: Text("${notificationController.notificationList![index].data!.title}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),),
                      subtitle: Text("${notificationController.notificationList![index].data!.description}",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                }
            )
          ),
        ) : EmptyBoxWidget(titre: "Aucune notification", icon: "assets/animations/empty_notifications.json", iconType: "lottie") : Center(child: CircularProgressIndicator(),);
      })
       : NotLoginWidget(
            onPressed: () {

            }
        )
    );
  }
}
