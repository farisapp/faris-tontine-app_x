import 'package:faris/controller/auth_controller.dart';
import 'package:faris/presentation/theme/theme_color.dart';
import 'package:faris/presentation/widgets/custom_snackbar.dart';
import 'package:faris/presentation/widgets/round_textbutton.dart';
import 'package:faris/route/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({Key? key}) : super(key: key);

  TextEditingController _phoneController = TextEditingController();

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
              /*Positioned(
                top: 330,
                left: 0,
                right: 0,
                child: Image.asset("assets/images/logo.png", height: 150,),
              ),*/
              Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.5),
                        borderRadius: BorderRadius.circular(10)),
                    child: SingleChildScrollView(
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
                          /*Padding(
                              padding: const EdgeInsets.only(top: 20.0, left: 20),
                              child: Text(
                                "Connexion",
                                style: TextStyle(
                                    color: Color(0xFF4b2c20),
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),*/
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Material(
                                      elevation: 5.0,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(30.0),
                                          bottomLeft: Radius.circular(30.0)),
                                      color: Colors.white,
                                      child: Container(
                                        height: 48,
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: Image.asset(
                                                  "assets/icons/burkina_faso.png"),
                                            ),
                                            Text(
                                              "+226",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16.0),
                                            )
                                          ],
                                        ),
                                      )),
                                  flex: 1,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Material(
                                    elevation: 5.0,
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(30.0),
                                        bottomRight: Radius.circular(30.0)),
                                    color: Colors.white,
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                          hintText: "75000000",
                                          hintStyle: TextStyle(color: Colors.black),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 10.0, vertical: 14.0),
                                          suffixIcon: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Material(
                                              elevation: 5,
                                              color: AppColor.kTontinet_primary,
                                              borderRadius:
                                              BorderRadius.circular(30),
                                              child: Icon(
                                                Icons.phone,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          border: InputBorder.none),
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16.0),
                                      //cursorColor: couleurVerte,
                                      keyboardType: TextInputType.phone,
                                      controller: _phoneController,
                                      validator: (value) {
                                        if(value!.isEmpty){
                                          return "Veuillez renseignez votre numéro de téléphone";
                                        }
                                      },
                                    ),
                                  ),
                                  flex: 2,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          GetBuilder<AuthController>(builder: (authController) {
                            return authController.resetLoading ? Center(child: CircularProgressIndicator(),) : Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: RoundTextButton(
                                  titre: "Réinitialiser",
                                  backgroundColor: AppColor.kTontinet_primary,
                                  textColor: Colors.white,
                                  height: 50,
                                  onPressed: () {
                                    _forgetPassword(context, authController);
                                  }
                              ),
                            );
                          }),
                          SizedBox(height: 5,),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 15, bottom: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Get.toNamed(RouteHelper.getSignUpRoute());
                                  },
                                  child: Text("Connectez-vous!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  void _forgetPassword(BuildContext context, AuthController authController) async {
    String phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      showCustomSnackBar(context, 'Entrez votre numéro de téléphone');
    }else if (phone.length < 8 || phone.length > 8) {
      showCustomSnackBar(context, "Le numéro de téléphone doit contenir 8 chiffres");
    }else if (!phone.isNumericOnly) {
      showCustomSnackBar(context, 'Le numéro de téléphone ne doit pas contenir des caractères spéciaux');
    }else {
      phone = '226$phone';
      authController.forgetPassword(phone).then((status) async {
        if (status.isSuccess) {
          Get.offAllNamed(RouteHelper.getVerificationRoute(phone, "", RouteHelper.FORGOT_PASSWORD, ""));
        }else {
          showCustomSnackBar(context, status.message);
        }
      });
    }
  }
}
