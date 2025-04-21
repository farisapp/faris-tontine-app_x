import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:faris/controller/auth_controller.dart';
import 'package:faris/controller/splash_controller.dart';
import 'package:faris/presentation/journey/main_page.dart';
import 'package:faris/route/routes.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.find<SplashController>().disableIntro();
    return Scaffold(
      body: IntroductionScreen(
        pages: [
          PageViewModel(
            title: "Atteignez le sommet avec Faris !",
            bodyWidget: Center(
              child: Text(
                  "Allez au sommet et organisez votre vie avec l'application Faris.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
            image: Image.asset("assets/images/intro1.png", height: 200,)
          ),
          PageViewModel(
              title: "Epargnez pour vos projets",
              bodyWidget: Center(
                child: Text(
                  "Épargne, facilité d’achats, déplacements et bien d’autres services avec Faris!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
              image: Image.asset("assets/images/intro2.png", height: 200,)
          ),
          PageViewModel(
              title: "Restez connecté(e)s",
              bodyWidget: Center(
                child: Text(
                  "Vous accèderez à tous ces services avec un seul compte!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
              image: Image.asset("assets/images/intro3.png", height: 200,)
          ),
          PageViewModel(
              title: "Notifications",
              bodyWidget: Center(
                child: Text(
                  "Soyez informé(e) de chaque action ou évènement dans votre application",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
              image: Image.asset("assets/images/intro4.png", height: 200,)
          ),
        ],
        showSkipButton: true,
        showNextButton: true,
        nextFlex: 1,
        dotsFlex: 2,
        //skipStyle: 1,
        animationDuration: 1000,
        curve: Curves.fastOutSlowIn,
        dotsDecorator: DotsDecorator(
          spacing: EdgeInsets.all(5),
          activeColor: Color(0xFFFFC700),
          activeSize: Size.square(10),
          size: Size.square(5),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          )
        ),
        skip: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
              color: Color(0xFF22215B),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade500,
                    blurRadius: 40,
                    offset: Offset(4, 4)
                )
              ]
          ),
          child: Center(
            child: Text(
              "Passez",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),
        next: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Color(0xFF22215B), width: 2)
          ),
          child: Center(
            child: Icon(Icons.navigate_next, color: Color(0xFF22215B),),
          ),
        ),
        done: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: Color(0xFF22215B),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade500,
                blurRadius: 40,
                offset: Offset(4, 4)
              )
            ]
          ),
          child: Center(
            child: Text(
                "Terminé",
                style: TextStyle(
                  color: Colors.white,
                    fontSize: 12,
                  fontWeight: FontWeight.bold
                ),
            ),
          ),
        ),
        onDone: (){
          if(Get.find<AuthController>().isLoggedIn()){
            Get.toNamed(RouteHelper.getMainRoute(RouteHelper.ONBOARDING));
          }else{
            Get.toNamed(RouteHelper.getAuthRoute());
          }
        },
      ),
    );
  }
}

