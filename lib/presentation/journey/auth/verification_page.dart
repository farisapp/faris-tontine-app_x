import 'dart:async';

import 'package:faris/controller/auth_controller.dart';
import 'package:faris/presentation/theme/theme_color.dart';
import 'package:faris/presentation/widgets/custom_snackbar.dart';
import 'package:faris/presentation/widgets/round_textbutton.dart';
import 'package:faris/route/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerificationPage extends StatefulWidget {
  final String? number;
  final String? token;
  final bool? fromSignUp;
  final String? password;

  const VerificationPage({Key? key, this.token, this.fromSignUp, this.password, required this.number}) : super(key: key);

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {

  String? _number;
  late Timer _timer;
  int _seconds = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _number = widget.number!.startsWith('226') ? widget.number : '226'+widget.number!.substring(2, widget.number!.length);
    _startTimer();
  }

  void _startTimer() {
    _seconds = 60;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _seconds = _seconds - 1;
      if(_seconds == 0) {
        timer.cancel();
        _timer.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<AuthController>(builder: (authController) {
        return SingleChildScrollView(
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
                              child: Column(
                                children: [
                                 SizedBox(
                                   width: Get.width,
                                   height: 60,
                                   child:  PinCodeTextField(
                                     appContext: context,
                                     length: 4,
                                     keyboardType: TextInputType.number,
                                     animationType: AnimationType.slide,
                                     pinTheme: PinTheme(
                                       shape: PinCodeFieldShape.box,
                                       fieldHeight: 60,
                                       fieldWidth: 60,
                                       borderWidth: 1,
                                       borderRadius: BorderRadius.circular(5),
                                       selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                       selectedFillColor: Colors.white,
                                       inactiveColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                       inactiveFillColor: Theme.of(context).disabledColor.withOpacity(0.2),
                                       activeColor: Theme.of(context).primaryColor.withOpacity(0.4),
                                       activeFillColor: Theme.of(context).disabledColor.withOpacity(0.2),
                                     ),
                                     animationDuration: Duration(milliseconds: 300),
                                     backgroundColor: Colors.transparent,
                                     enableActiveFill: true,
                                     onChanged: authController.updateVerificationCode,
                                     beforeTextPaste: (text) => true,
                                   ),
                                 ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Vous n'avez pas reçu votre code?",
                                        style: TextStyle(color: AppColor.kTontinet_secondary, fontSize: 12),
                                      ),
                                      SizedBox(width: 2,),
                                      TextButton(
                                          onPressed: _seconds < 1 ? ()  {
                                            authController.forgetPassword(widget.number!).then((value) {
                                              if(value.isSuccess){
                                                _startTimer();
                                                showCustomSnackBar(context, "Code de réinitialisation envoyé avec succès.", isError: false);
                                              }else{
                                                showCustomSnackBar(context, value.message);
                                              }
                                            });
                                          }: null,
                                          child: Text("Re-envoyer ${_seconds > 0 ? ' ($_seconds)' : ''}")
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            GetBuilder<AuthController>(builder: (authController) {
                              if(authController.verificationCode.length == 4 && authController.resetLoading){
                                return Center(child: CircularProgressIndicator(),);
                              }else{
                                return authController.isLoading ? Center(child: CircularProgressIndicator(),) : Padding(
                                  padding: const EdgeInsets.only(left: 10, right: 10),
                                  child: RoundTextButton(
                                      titre: "Vérifier le code",
                                      backgroundColor: AppColor.kTontinet_primary,
                                      textColor: Colors.white,
                                      height: 50,
                                      onPressed: () {
                                        if(authController.verificationCode.length != 4){
                                          showCustomSnackBar(context, "Veuillez renseigner le code!");
                                        }else{
                                          authController.verifyToken(widget.number!).then((value) {
                                            if(value.isSuccess){
                                              Get.toNamed(RouteHelper.getResetPasswordRoute(widget.number!, authController.verificationCode, "reset-password"));
                                            }else{
                                              showCustomSnackBar(context, value.message);
                                            }
                                          });
                                        }

                                      }
                                  ),
                                );
                              }
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
        );
      }),
    );
  }
}
