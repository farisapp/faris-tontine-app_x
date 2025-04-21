import 'package:faris/presentation/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:faris/controller/auth_controller.dart';
import 'package:faris/data/models/body/signup_body.dart';
import 'package:faris/presentation/widgets/custom_snackbar.dart';
import 'package:faris/presentation/widgets/round_textbutton.dart';
import 'package:faris/route/routes.dart';

class SignupPage extends StatefulWidget {

  SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  TextEditingController _phoneController = TextEditingController();
  TextEditingController _nomController = TextEditingController();
  TextEditingController _prenomController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordRepeatController = TextEditingController();

  final _formKey  = new  GlobalKey<FormState>();

  bool checkboxValue = false;

  @override
  Widget build(BuildContext context) {
    //final authController = Get.find<AuthController>()
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
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
                  top:100,
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
                  top: 80,
                  left: 0,
                  right: 0,
                  child: Text(
                    "Faris",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 100.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Tangerine",
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),*/
                Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                      padding: EdgeInsets.only(bottom: 20),
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
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0, left: 20),
                                child: Text(
                                  "Créer un compte",
                                  style: TextStyle(
                                      color: AppColor.kTontinet_secondary,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
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
                                        ),
                                      ),
                                      flex: 2,
                                    ),
                                  ],
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
                                        hintText: "Nom",
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
                                              Icons.person_outline,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        border: InputBorder.none),
                                    style:
                                    TextStyle(color: Colors.black, fontSize: 16.0),
                                    //cursorColor: couleurVerte,
                                    controller: _nomController,
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
                                        hintText: "Prénom(s)",
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
                                              Icons.person_outline,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        border: InputBorder.none),
                                    style:
                                    TextStyle(color: Colors.black, fontSize: 16.0),
                                    //cursorColor: couleurVerte,
                                    controller: _prenomController,

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
                                        hintText: "Adresse email (Optionnelle)",
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
                                              Icons.email_outlined,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        border: InputBorder.none),
                                    style:
                                    TextStyle(color: Colors.black, fontSize: 16.0),
                                    //cursorColor: couleurVerte,
                                    controller: _emailController,
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
                                        hintText: "Mot de passe",
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
                                        hintText: "Confirmer le Mot de passe",
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
                                    controller: _passwordRepeatController,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              FormField<bool>(
                                builder: (state) {
                                  return Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Checkbox(
                                              value: checkboxValue,
                                              onChanged: (value) {
                                                setState(() {
                                                  checkboxValue = value!;
                                                  state.didChange(value);
                                                });
                                              }),
                                          const Text("J'accepte les ", style: TextStyle(color: Colors.black),),
                                          InkWell(
                                              onTap: () => Get.toNamed(RouteHelper.getHtmlRoute('terms-and-condition')),
                                              child: Text("termes et conditions.", style: TextStyle(color: AppColor.kTontinet_primary),)
                                          ),
                                        ],
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          state.errorText ?? '',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(color: Theme.of(context).colorScheme.error,fontSize: 12,),
                                        ),
                                      )
                                    ],
                                  );
                                },
                                validator: (value) {
                                  if (!checkboxValue) {
                                    return 'Vous devez accepter les termes et conditions';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              GetBuilder<AuthController>(builder: (authController) {
                                return authController.isLoading ? Center(child: CircularProgressIndicator(),) : Padding(
                                  padding: const EdgeInsets.only(left: 10, right: 10),
                                  child: RoundTextButton(
                                      titre: "Créer mon compte",
                                      backgroundColor: AppColor.kTontinet_primary,
                                      textColor: Colors.white,
                                      height: 50,
                                      onPressed: () async {
                                        _register(context, authController);
                                      }),
                                );
                              }),
                              Padding(
                                padding: const EdgeInsets.only(left: 10, right: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.SIGNUP));
                                      },
                                      child: Text("Connectez-vous!", style: TextStyle(color: AppColor.kTontinet_secondary, fontWeight: FontWeight.bold, fontSize: 14)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _register(BuildContext context, AuthController authController) async {
    String nom = _nomController.text.trim();
    String prenom = _prenomController.text.trim();
    String email = _emailController.text.trim();
    String telephone = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _passwordRepeatController.text.trim();

    if (nom.isEmpty) {
      showCustomSnackBar(context, 'Entrez votre nom');
    }else if ((telephone.length < 8 || telephone.length > 8)) {
      showCustomSnackBar(context, "Le numéro de téléphone doit contenir 8 chiffres");
    }else if (!telephone.isNumericOnly) {
      showCustomSnackBar(context, 'Le numéro de téléphone ne doit pas contenir des  tirets');
    }else if (prenom.isEmpty) {
      showCustomSnackBar(context, 'Entrez votre prénom');
    }else if (email.isNotEmpty && !GetUtils.isEmail(email)) {
      showCustomSnackBar(context, 'Entrez une adresse email valide');
    }else if (telephone.isEmpty) {
      showCustomSnackBar(context, 'Entrez votre numéro de téléphone');
    }else if (password.isEmpty) {
      showCustomSnackBar(context, 'Entrez un mot de passe');
    }else if (password.length < 6) {
      showCustomSnackBar(context, 'Le mot de passe doit contenir 6 caractères');
    }else if (password != confirmPassword) {
      showCustomSnackBar(context, 'Les mots de passe ne correspondent pas');
    }else if (!checkboxValue) {
      showCustomSnackBar(context, 'Vous devez accepter les termes et conditions');
    }else {
      telephone = '226$telephone';
      SignUpBody signUpBody = SignUpBody(nom: nom, prenom: prenom, email: email, telephone: telephone, password: password);
      authController.registration(signUpBody).then((status) async {
        if (status.isSuccess) {
          Get.toNamed(RouteHelper.getInitialRoute());
        }else {
          showCustomSnackBar(context, status.message);
        }
      });
    }
  }
}
