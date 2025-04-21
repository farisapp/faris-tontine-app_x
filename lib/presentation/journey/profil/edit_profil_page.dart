
import 'dart:io';

import 'package:faris/common/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:faris/controller/auth_controller.dart';
import 'package:faris/controller/user_controller.dart';
import 'package:faris/data/models/response_model.dart';
import 'package:faris/data/models/user_model.dart';
import 'package:faris/presentation/theme/theme_color.dart';
import 'package:faris/presentation/widgets/custom_snackbar.dart';
import 'package:faris/presentation/widgets/not_loggin_widget.dart';

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({Key? key}) : super(key: key);

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final FocusNode _nomFocus = FocusNode();
  final FocusNode _prenomFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();

    _isLoggedIn = Get.find<AuthController>().isLoggedIn();
    if(_isLoggedIn && Get.find<UserController>().userInfo == null) {
      Get.find<UserController>().getUserInfo();
    }
    Get.find<UserController>().initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edition de Profil",
          style: TextStyle(
              color: AppColor.kTontinet_secondary,
              fontSize: 20,
              fontFamily:
              GoogleFonts.lato(fontWeight: FontWeight.w800).fontFamily),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColor.kTontinet_secondary),

        centerTitle: true,
      ),
      body: GetBuilder<UserController>(builder: (userController) {
        if(userController.userInfo != null && _nomController.text.isEmpty){
          _nomController.text = userController.userInfo!.nom ?? '';
          _prenomController.text = userController.userInfo!.prenom ?? '';
          _emailController.text = userController.userInfo!.email ?? '';
          _phoneController.text = userController.userInfo!.telephone ?? '';
        }
        return _isLoggedIn ? userController.userInfo != null ? Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 20),
                child: Stack(
                  children: [
                    ClipOval(

                    ),
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
                              image: userController.image != null ?
                              FileImage(File(userController.image!.path)) :
                              userController.userInfo!.avatar != null ? NetworkImage(AppConstant.BASE_IMAGE_URL+"/${userController.userInfo!.avatar}") :
                              AssetImage("assets/images/no_image.jpeg") as ImageProvider,
                              fit: BoxFit.cover
                          )
                      ),
                    ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () => userController.pickImage(),
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
                          ),
                        ))
                  ],
                )),
            SizedBox(height: 20,),
            Expanded(
                child: Scrollbar(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: SizedBox(
                          width: Get.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Nom de famille", style: TextStyle(color: AppColor.kTontinet_secondary, fontWeight: FontWeight.bold)),
                              SizedBox(height: 10,),
                              TextField(
                                controller: _nomController,
                                decoration: InputDecoration(
                                    filled: true,
                                    border: OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.all(10.0),
                                    floatingLabelBehavior: FloatingLabelBehavior.never
                                ),
                                textCapitalization: TextCapitalization.words,
                                autofocus: false,
                                focusNode: _nomFocus,
                                onSubmitted: (value) => FocusScope.of(context).requestFocus(_prenomFocus),
                              ),
                              SizedBox(height: 20,),
                              Text("Prénom(s)", style: TextStyle(color: AppColor.kTontinet_secondary, fontWeight: FontWeight.bold)),
                              SizedBox(height: 10,),
                              TextField(
                                controller: _prenomController,
                                decoration: InputDecoration(
                                    filled: true,
                                    border: OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.all(10.0),
                                    floatingLabelBehavior: FloatingLabelBehavior.never
                                ),
                                textCapitalization: TextCapitalization.words,
                                autofocus: false,
                                focusNode: _prenomFocus,
                                onSubmitted: (value) => FocusScope.of(context).requestFocus(_emailFocus),
                              ),
                              SizedBox(height: 20,),
                              Text("Email", style: TextStyle(color: AppColor.kTontinet_secondary, fontWeight: FontWeight.bold)),
                              SizedBox(height: 10,),
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                    filled: true,
                                    border: OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.all(10.0),
                                    floatingLabelBehavior: FloatingLabelBehavior.never
                                ),
                                autofocus: false,
                                focusNode: _emailFocus,
                                onSubmitted: (value) => FocusScope.of(context).requestFocus(_phoneFocus),
                              ),
                              SizedBox(height: 20,),
                              Text("Téléphone", style: TextStyle(color: AppColor.kTontinet_secondary, fontWeight: FontWeight.bold)),
                              SizedBox(height: 5,),
                              Text("Le numéro de téléphone n'est pas modifiable", style: TextStyle(color: AppColor.kTontinet_googleColor, fontSize: 10)),
                              SizedBox(height: 10,),
                              TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp('[0-9+]'))],
                                decoration: InputDecoration(
                                    filled: true,
                                    border: OutlineInputBorder(),
                                    disabledBorder: OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.all(10.0),
                                    floatingLabelBehavior: FloatingLabelBehavior.never
                                ),
                                textCapitalization: TextCapitalization.words,
                                autofocus: false,
                                focusNode: _phoneFocus,
                                enabled: false,

                              ),
                              SizedBox(height: 20,),
                              !userController.isLoading ? TextButton(
                                  onPressed: () {
                                    _updateProfile(context, userController);
                                  },
                                  style: TextButton.styleFrom(
                                    //minimumSize: Size(width, height),
                                    foregroundColor: Colors.white, shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    backgroundColor: Colors.green,
                                    //padding: EdgeInsets.symmetric(horizontal: 40)
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle_outline_outlined, color: Colors.white,),
                                      SizedBox(width: 5),
                                      Text("Modifier", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                                    ],
                                  )
                              ) : Center(child: CircularProgressIndicator(),),
                            ],
                          ),
                        ),
                      ),
                    )
                )
            ),
          ],
        ) : Center(child: CircularProgressIndicator(),) : NotLoginWidget(onPressed: () {});
      }),
    );
  }

  void _updateProfile(BuildContext context, UserController userController) async {
    String _nom = _nomController.text.trim();
    String _prenom = _prenomController.text.trim();
    String _email = _emailController.text.trim();
    String _telephone = _phoneController.text.trim();
    if(userController.userInfo?.nom == _nom && userController.userInfo?.prenom == _prenom &&
        userController.userInfo?.email == _email && userController.userInfo?.telephone == _telephone && userController.image == null){
      showCustomSnackBar(context, "Veuillez modifier quelque chose avant d'enregistrer");
    }else if(_nom.isEmpty){
      showCustomSnackBar(context, "Entrez votre nom de famille");
    }else if(_prenom.isEmpty){
      showCustomSnackBar(context, "Entrez votre prénom");
    }else if(_email.isEmpty){
      showCustomSnackBar(context, "Entrez votre adresse email");
    }else if(_telephone.isEmpty){
      showCustomSnackBar(context, "Entrez votre numéro de téléphone");
    }else{
      User userInfo = User(nom: _nom, prenom: _prenom, email: _email, telephone: _telephone);
      ResponseModel _responseModel = await userController.updateUserInfo(userInfo, Get.find<AuthController>().getUserToken());
      if(_responseModel.isSuccess){
        showCustomSnackBar(context, "Profil modifié avec succès", isError: false);
      }else{
        showCustomSnackBar(context, _responseModel.message);
      }
    }
  }
}
