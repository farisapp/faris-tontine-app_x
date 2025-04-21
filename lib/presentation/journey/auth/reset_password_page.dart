import 'package:faris/controller/auth_controller.dart';
import 'package:faris/presentation/theme/theme_color.dart';
import 'package:faris/presentation/widgets/custom_snackbar.dart';
import 'package:faris/presentation/widgets/round_textbutton.dart';
import 'package:faris/route/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class ResetPasswordPage extends StatelessWidget {
  final String? resetToken;
  final String? number;
  final bool? fromPasswordChange;

  ResetPasswordPage({Key? key, required this.resetToken, required this.number, required this.fromPasswordChange}) : super(key: key);

  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  final _formKey  = new  GlobalKey<FormState>();

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
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.5),
                        borderRadius: BorderRadius.circular(10)),
                    child: Form(
                      key: _formKey,
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
                              child: Material(
                                elevation: 5.0,
                                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                color: Colors.white,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                      hintText: "Nouveau mot de passe",
                                      hintStyle: TextStyle(color: Colors.black),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 32.0, vertical: 14.0),
                                      suffixIcon: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Material(
                                          elevation: 5,
                                          color: AppColor.kTontinet_primary,
                                          borderRadius: BorderRadius.circular(30),
                                          child: Icon(
                                            Icons.lock_outline,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      border: InputBorder.none),
                                  obscureText: true,
                                  style:
                                  TextStyle(color: Colors.black, fontSize: 16.0),
                                  //cursorColor: couleurVerte,
                                  controller: _passwordController,
                                  validator: (value) {
                                    if(value!.isEmpty){
                                      return "Veuillez renseignez votre mot de passe";
                                    }
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Material(
                                elevation: 5.0,
                                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                color: Colors.white,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                      hintText: "Confirmer le mot de passe",
                                      hintStyle: TextStyle(color: Colors.black),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 32.0, vertical: 14.0),
                                      suffixIcon: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Material(
                                          elevation: 5,
                                          color: AppColor.kTontinet_primary,
                                          borderRadius: BorderRadius.circular(30),
                                          child: Icon(
                                            Icons.lock_outline,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      border: InputBorder.none),
                                  obscureText: true,
                                  style:
                                  TextStyle(color: Colors.black, fontSize: 16.0),
                                  //cursorColor: couleurVerte,
                                  controller: _confirmPasswordController,
                                  validator: (value) {
                                    if(value!.isEmpty){
                                      return "Veuillez renseignez votre mot de passe";
                                    }
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GetBuilder<AuthController>(builder: (authController) {
                              return authController.resetLoading ? Center(child: CircularProgressIndicator(),) : Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
                                child: RoundTextButton(
                                    titre: "Valider",
                                    backgroundColor: AppColor.kTontinet_primary,
                                    textColor: Colors.white,
                                    height: 50,
                                    onPressed: () async {
                                      if(_formKey.currentState!.validate()){
                                        String _newPassword = _passwordController.text.trim();
                                        String _confirmPassword = _confirmPasswordController.text.trim();
                                        if(_newPassword != _confirmPassword){
                                          showCustomSnackBar(context, "Les mots de passe ne correspondent pas.");
                                        }else{
                                          authController.resetPassword(resetToken!, number!, _newPassword, _confirmPassword).then((value) async {
                                            if(value.isSuccess){
                                              Get.offAllNamed(RouteHelper.getAuthRoute());
                                            }else{
                                              showCustomSnackBar(context, value.message);
                                            }

                                          });
                                        }

                                      }
                                    }
                                ),
                              );
                            }),
                            SizedBox(height: 5,),
                          ],
                        ),
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
