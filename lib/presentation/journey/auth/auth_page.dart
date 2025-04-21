import 'package:faris/presentation/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:faris/presentation/widgets/round_textbutton.dart';
import 'package:faris/route/routes.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Stack(
            children: [
              Image.asset(
                "assets/images/cover1.jpg",
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.white.withOpacity(.1),
                      Colors.black.withOpacity(.7)
                    ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              ),
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Container(
                  height: 300,
                  width: double.infinity,
                  child: SvgPicture.asset(
                    "assets/images/world_map.svg",
                    color: Colors.white,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                    padding: EdgeInsets.only(top: 25, bottom: 25),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.5),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SizedBox(
                              height: 100,
                              child: Image.asset("assets/images/logo.png"),
                            ),
                          ),
                        ),
                        SizedBox(height: 20,),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: RoundTextButton(
                              titre: "Connectez-vous",
                              backgroundColor: AppColor.kTontinet_primary,
                              textColor: Colors.white,
                              height: 50,
                              onPressed: () {
                                Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.ONBOARDING));
                              }
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                          child: RoundTextButton(
                              titre: "Créer un compte",
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              height: 50,
                              onPressed: () {
                                Get.toNamed(RouteHelper.getSignUpRoute());
                              }
                          ),
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
