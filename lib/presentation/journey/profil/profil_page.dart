import 'package:faris/common/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:faris/controller/auth_controller.dart';
import 'package:faris/controller/user_controller.dart';
import 'package:faris/presentation/journey/profil/edit_password_page.dart';
import 'package:faris/presentation/journey/profil/request_join_tontine_page.dart';
import 'package:faris/presentation/journey/profil/user_request_list_page.dart';
import 'package:faris/presentation/theme/theme_color.dart';
import 'package:faris/presentation/widgets/round_textbutton.dart';
import 'package:faris/presentation/widgets/setting_tile.dart';
import 'package:faris/route/routes.dart';


class ProfilPage extends StatelessWidget {

  const ProfilPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool _isLoggedIn = Get.find<AuthController>().isLoggedIn();
    if(_isLoggedIn && Get.find<UserController>().userInfo == null){
      Get.find<UserController>().getUserInfo();
    }
    return Scaffold(
      appBar: AppBar(
        title: Image.asset("assets/images/logo.png", height: 45,),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColor.kTontinet_primary_light),
        leading: SizedBox.shrink(),
        centerTitle: true,
      ),
      body:  GetBuilder<UserController>(builder: (userController) {
        return (_isLoggedIn && Get.find<UserController>().userInfo == null) ? Center(child: CircularProgressIndicator(),) : Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 4,
                                    color:
                                    Theme.of(context).scaffoldBackgroundColor),
                                boxShadow: [
                                  BoxShadow(
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      color: Colors.black.withOpacity(0.1),
                                      offset: Offset(0, 10))
                                ],
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: Get.find<UserController>().userInfo!.avatar != null ? NetworkImage(AppConstant.BASE_IMAGE_URL+"/${Get.find<UserController>().userInfo!.avatar}") : AssetImage("assets/images/no_image.jpeg") as ImageProvider,
                                    fit: BoxFit.cover)),
                          ),
                          /*Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 4,
                                      color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                    ),
                                    color: AppColor.kTontinet_primary,
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                ))*/
                        ],
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${userController.userInfo?.displayName ?? ""}",
                              style: TextStyle(
                                  color: AppColor.kTontinet_primary_light,
                                  fontSize: 18,
                                  fontFamily: GoogleFonts.raleway(
                                      fontWeight: FontWeight.w800)
                                      .fontFamily),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "",
                              style: TextStyle(
                                  color: AppColor.kTontinet_primary_light,
                                  fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),),
                SizedBox(height: 20,),
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5.0,
                            offset: Offset(0, 2)
                        )
                      ]
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8, top: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("Vous avez créé", style: TextStyle(fontSize: 11, color: Colors.black, fontFamily:
                                GoogleFonts.raleway(fontWeight: FontWeight.w800).fontFamily), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                                SizedBox(height: 4,),
                                Text("${userController.userInfo!.hasTontineCount}", style: TextStyle(fontSize: 20, color: AppColor.kTontinet_primary, fontFamily:
                                GoogleFonts.raleway(fontWeight: FontWeight.w800).fontFamily), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                                SizedBox(height: 4,),
                                Text("Épargnes", style: TextStyle(fontSize: 11, color: Colors.black, fontFamily:
                                GoogleFonts.raleway(fontWeight: FontWeight.w700).fontFamily), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                              ],
                            ),
                          )
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.4),),
                      ),
                      Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8, top: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("Vous êtes membre de", style: TextStyle(fontSize: 11, color: Colors.black, fontFamily:
                                GoogleFonts.raleway(fontWeight: FontWeight.w800).fontFamily), maxLines: 1, overflow: TextOverflow.ellipsis,),
                                SizedBox(height: 4,),
                                Text("${userController.userInfo!.isMemberCount}", style: TextStyle(fontSize: 20, color: AppColor.kTontinet_primary, fontFamily:
                                GoogleFonts.raleway(fontWeight: FontWeight.w800).fontFamily), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                                SizedBox(height: 4,),
                                Text("Épargnes", style: TextStyle(fontSize: 11, color: Colors.black, fontFamily:
                                GoogleFonts.raleway(fontWeight: FontWeight.w700).fontFamily), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                              ],
                            ),
                          )
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20,),
                Column(
                  children: [
                    GetBuilder<AuthController>(builder: (authController) {
                      return SettingTile(
                        titre: "Notifications",
                        icon: Icons.notifications,
                        color: Colors.orange,
                        isButtonActive: authController.notification,
                        onPressed: (){
                          authController.setNotificationActive(!authController.notification);
                        },
                      );
                    }),
                    Divider(color: Colors.grey.withOpacity(0.3),),
                    SettingTile(
                      titre: "Modifier mot de passe",
                      icon: Icons.lock,
                      color: Colors.brown,
                      onPressed: (){
                        Get.to(() => EditPasswordPage(), transition: Transition.cupertino);
                      },
                    ),
                    SettingTile(
                      titre: "Editer votre profil",
                      icon: Icons.edit,
                      color: Colors.orange,
                      onPressed: (){
                        Get.toNamed(RouteHelper.getUpdateProfileRoute());
                      },
                    ),
                    SettingTile(
                      titre: "Déconnexion",
                      icon: Icons.exit_to_app,
                      color: Colors.red,
                      onPressed: (){
                        _confirmLogout();
                      },
                    ),
                    Divider(color: Colors.grey.withOpacity(0.3)),
                    SettingTile(
                      titre: "Tutos",
                      icon: Icons.book_online_outlined,
                      color: Colors.teal,
                      onPressed: (){
                        Get.toNamed(RouteHelper.getHtmlRoute('tuto'));
                      },
                    ),
                    SettingTile(
                      titre: "FAQ",
                      icon: Icons.help_outline,
                      color: Colors.blueGrey,
                      onPressed: (){
                        Get.toNamed(RouteHelper.getHtmlRoute('faq'));
                      },
                    ),

                    /*SettingsGroup(
                        title: "GENERALE",
                        children: [
                          SizedBox(height: 10,),
                          AccountSettings(),
                          NotificationSettings(),
                          buildLogout(),
                          buildDeleteCount()
                        ]
                    ),*/
                    SizedBox(height: 32,),
                    /*SettingsGroup(
                        title: "FEEDBACK",
                        children: [
                          SizedBox(height: 10,),
                          buildReportBug(),
                          buildSendFeeback()
                        ]
                    ),*/
                  ],

                )
              ],
            ),
          ),
        );
      }),
    );
  }

  /* Widget buildLogout(){
    return SimpleSettingsTile(
      title: "Déconnexion",
      subtitle: "",
      leading: IconWidget(icon: Icons.logout, color: Colors.blueAccent),
      onTap: () {},
    );
  }
  Widget buildDeleteCount(){
    return SimpleSettingsTile(
      title: "Supprimer mon compte",
      subtitle: "",
      leading: IconWidget(icon: Icons.delete, color: Colors.redAccent),
      onTap: () {},
    );
  }

  Widget buildReportBug(){
    return SimpleSettingsTile(
      title: "Signaler une erreur",
      subtitle: "",
      leading: IconWidget(icon: Icons.bug_report, color: Colors.teal),
      onTap: () {},
    );
  }
  Widget buildSendFeeback(){
    return SimpleSettingsTile(
      title: "Evaluer l'application",
      subtitle: "",
      leading: IconWidget(icon: Icons.thumb_up, color: Colors.purple),
      onTap: () {},
    );
  }*/

  _confirmLogout() {
    return Get.defaultDialog(
        title: "Déconnexion",
        middleText: "Êtes vous sûr de vouloir vous déconnecter ?",
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RoundTextButton(
                titre: "OUI",
                width: 80,
                height: 40,
                onPressed: () {
                  Get.find<AuthController>().clearSharedData();
                  Get.offAllNamed(RouteHelper.getSignInRoute("profil"));
                },
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 14,
              ),
              SizedBox(width: 10,),
              RoundTextButton(
                titre: "NON",
                width: 80,
                height: 40,
                backgroundColor: Colors.grey,
                textColor: Colors.black,
                fontSize: 14,
                onPressed: () {
                  Get.back();
                },
              )
            ],
          ),
        ]);
  }

}
