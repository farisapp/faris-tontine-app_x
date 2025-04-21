import 'dart:async';
import 'dart:io';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:faris/common/app_constant.dart';
import 'package:faris/common/notification_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:faris/controller/main_controller.dart';
import 'package:faris/presentation/journey/home/home_page.dart';
import 'package:faris/presentation/journey/notification/notification_page.dart';
import 'package:faris/presentation/journey/profil/profil_page.dart';
import 'package:faris/presentation/theme/theme_color.dart';
import 'package:new_version_plus/new_version_plus.dart';

class MainPage extends StatefulWidget {

  int pageIndex = 0;

  MainPage({Key? key, required this.pageIndex}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}


class _MainPageState extends State<MainPage> {
  MainController mainController = Get.put(MainController());
  int _pageIndex = 0;
  late PageController _pageController;
  List<Widget> _screens = [];
  bool _canExit = false;
  String release = "";

  GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //NotificationHelper.requestNotificationPermission();
    _pageIndex = widget.pageIndex;
    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      HomePage(),
      NotificationPage(),
      ProfilPage()
    ];

    final newVersion = NewVersionPlus(androidId: AppConstant.APP_PLAYSTORE_PACKAGE, androidPlayStoreCountry: "fr_FR" );
    basicStatusCheck(newVersion);

  }

  basicStatusCheck(NewVersionPlus newVersion) async {
    final version = await newVersion.getVersionStatus();
    if (version != null) {
      if(version.canUpdate){
        newVersion.showUpdateDialog(
            context: context,
            versionStatus: version!,
            dialogText: "Vous pouvez mettre Faris à jour de la version ${version.localVersion} à ${version.storeVersion}.",
            dialogTitle: "Mise à jour disponible",
            updateButtonText: "Mettre à jour",
            dismissButtonText: "Annuler",
            allowDismissal: true,
            dismissAction: () {
              exit(0);
            },
            launchModeVersion: LaunchModeVersion.external,
        );
      }
      /*release = version.releaseNotes ?? "";
      print("Nouvelle version => $release");
      setState(() {});*/
    }



  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_pageIndex != 0) {
          _setPage(0);
          return false;
        } else {
          if(_canExit) {
            return true;
          }else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Veuillez tapez encore sur la touche de retour pour quitter", style: TextStyle(color: Colors.white)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 2),
              margin: EdgeInsets.all(5),
            ));
            _canExit = true;
            Timer(Duration(seconds: 2), () {
              _canExit = false;
            });
            return false;
          }
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: SizedBox.expand(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _screens.length,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index){
              return _screens[index];
            },
          ),
        ),
        bottomNavigationBar: BottomNavyBar(
          selectedIndex: _pageIndex,
          showElevation: false,
          onItemSelected: (index) {
            _setPage(index);
            //mainController.pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.ease);
          },
          items: [
            BottomNavyBarItem(
              icon: Icon(CupertinoIcons.home, color: AppColor.kTontinet_primary),
              title: Text("Accueil", style: TextStyle(color: AppColor.kTontinet_primary, fontSize: 11),),
              activeColor: AppColor.kTontinet_primary_light,
            ),
            BottomNavyBarItem(
                icon: Icon(CupertinoIcons.bell, color: AppColor.kTontinet_primary,),
                title: Text("Notifications", style: TextStyle(color: AppColor.kTontinet_primary, fontSize: 11),),
                activeColor: AppColor.kTontinet_primary_light
            ),
            BottomNavyBarItem(
                icon: Icon(CupertinoIcons.profile_circled, color: AppColor.kTontinet_primary),
                title: Text("Profil", style: TextStyle(color: AppColor.kTontinet_primary, fontSize: 11),),
                activeColor: AppColor.kTontinet_primary_light
            )
          ],
        ),
      ),
    );
  }

  void _setPage(int pageIndex) {
    setState(() {
      _pageController.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }
}
