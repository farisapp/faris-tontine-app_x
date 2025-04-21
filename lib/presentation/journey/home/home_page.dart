import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:faris/controller/auth_controller.dart';
import 'package:faris/controller/last_tontine_controller.dart';
import 'package:faris/controller/user_controller.dart';
import 'package:faris/presentation/journey/home/components/bloc_categorie.dart';
import 'package:faris/presentation/journey/home/components/bloc_profil.dart';

class HomePage extends StatelessWidget {

  HomePage({Key? key}) : super(key: key);

  Future<void> _loadData(bool reload) async {

    Future.delayed(new Duration(seconds: 0), () {
      Get.find<LastTontineController>().getLastTontine(reload);
    });

    if(Get.find<AuthController>().isLoggedIn()) {
      await Get.find<UserController>().getUserInfo();
      //await Get.find<NotificationController>().getNotificationList(reload);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    _loadData(true);
    return Scaffold(
      backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Image.asset(
            "assets/images/logo.png",
            height: 40, // Réduis la taille de l'image si nécessaire
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 40, // Réduire la hauteur de l'AppBar (par défaut : 56)
        ),
        body: RefreshIndicator(
        onRefresh: () async {
          await _loadData(true);
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            GetBuilder<UserController>(builder: (userController) {
          if (userController.userInfo != null) {
          final String usernom = userController.userInfo!.prenom ?? '';
          return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
          "Bonjour $usernom 👋,\nPar quel service êtes-vous interessé(e)?",
          style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          ),
          ),
          const SizedBox(height: 6),
          ],
          );
          } else {
          return const SizedBox.shrink();
          }
          }),
                SizedBox(height: 6,),
                GetBuilder<UserController>(builder: (userController) {
                  if(userController.userInfo != null){
                    return BlocCategorie(tontineCount: userController.userInfo!.isMemberCount!,);
                  } else{
                    return SizedBox(
                      width: Get.width,
                      height: 100,
                      child: SizedBox.shrink()//Center(child: CircularProgressIndicator(),),
                    );
                  }
                }),
                SizedBox(height: 10,),
                /*TitreWidget(titre: "RECEMMENT CREES", lineColor: Colors.cyan,),
                SizedBox(height: 20,),
                GetBuilder<LastTontineController>(builder: (lastTontineController) {
                  if(lastTontineController.tontineLoaded){
                    if(lastTontineController.lastTontines!.isEmpty){
                      return Center(child: EmptyBoxWidget(titre: "Aucune tontine disponible", icon: "assets/icons/coins_gris.svg", iconType: "svg",));
                    }else{
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: lastTontineController.lastTontines!.length,
                        itemBuilder: (context, index){
                          return TontineListTile(tontine: lastTontineController.lastTontines![index], press:
                              () => Get.to(() => TontineDetailsPage(tontine: lastTontineController.lastTontines![index])));
                        },
                      );
                    }
                  }else if(lastTontineController.hasError){
                    return Center(
                      child: AppErrorWidget(
                        errorType: lastTontineController.appErrorType,
                        onPressed: () async {
                          await Get.find<LastTontineController>().getLastTontine(true);
                        },
                      ),
                    );
                  }else{
                    return SizedBox(
                        width: size.width,
                        height: 150,
                        child: Center(child: CircularProgressIndicator(),)
                    );
                  }
                })*/
              ],
            ),
          ),
        ),
      )
    );
  }
}
