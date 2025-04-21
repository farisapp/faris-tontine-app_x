import 'package:faris/controller/auth_controller.dart';
import 'package:faris/controller/user_controller.dart';
import 'package:faris/presentation/theme/theme_color.dart';
import 'package:faris/presentation/widgets/custom_snackbar.dart';
import 'package:faris/route/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class EditPasswordPage extends StatelessWidget {

  EditPasswordPage({Key? key}) : super(key: key);

  final FocusNode _oldPasswordFocus = FocusNode();
  final FocusNode _newPasswordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Changez de mot de passe",
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

        return Scrollbar(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
              child: Center(
                child: SizedBox(
                  width: Get.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Ancien mot de passe", style: TextStyle(color: AppColor.kTontinet_secondary, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10,),
                      TextField(
                        controller: _oldPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(),
                            contentPadding: const EdgeInsets.all(10.0),
                            floatingLabelBehavior: FloatingLabelBehavior.never,

                        ),
                        textCapitalization: TextCapitalization.words,
                        autofocus: false,
                        focusNode: _oldPasswordFocus,
                        onSubmitted: (value) => FocusScope.of(context).requestFocus(_newPasswordFocus),
                      ),
                      SizedBox(height: 20,),
                      Text("Nouveau mot de passe", style: TextStyle(color: AppColor.kTontinet_secondary, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10,),
                      TextField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(),
                            contentPadding: const EdgeInsets.all(10.0),
                            floatingLabelBehavior: FloatingLabelBehavior.never
                        ),
                        textCapitalization: TextCapitalization.words,
                        autofocus: false,
                        focusNode: _newPasswordFocus,
                        onSubmitted: (value) => FocusScope.of(context).requestFocus(_confirmPasswordFocus),
                      ),
                      SizedBox(height: 20,),
                      Text("Confirmer le mot de passe", style: TextStyle(color: AppColor.kTontinet_secondary, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10,),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(),
                            contentPadding: const EdgeInsets.all(10.0),
                            floatingLabelBehavior: FloatingLabelBehavior.never
                        ),
                        autofocus: false,
                        focusNode: _confirmPasswordFocus,
                      ),
                      SizedBox(height: 20,),
                      !userController.isLoading ? TextButton(
                          onPressed: () {
                            _updatePassword(context, userController);
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
        );
      }),
    );
  }

  void _updatePassword(BuildContext context, UserController userController) async {
    String _oldPassword = _oldPasswordController.text.trim();
    String _newPassword = _newPasswordController.text.trim();
    String _confirmPassword = _confirmPasswordController.text.trim();

    if(_oldPassword.isEmpty){
      showCustomSnackBar(context, "Entrez votre ancien mot de passe");
    }else if(_newPassword.isEmpty){
      showCustomSnackBar(context, "Entrez votre nouveau mot de passe");
    }else if(_confirmPassword.isEmpty){
      showCustomSnackBar(context, "Veuillez confirmer le mot de passe");
    }else{
      await userController.changePassword(_oldPassword, _newPassword, _confirmPassword).then((result) {
        if(result.isSuccess){
          showCustomSnackBar(context, result.message, isError: false);
          Get.find<AuthController>().clearSharedData();
          Future.delayed(Duration(seconds: 2), () {
            Get.offAllNamed(RouteHelper.getAuthRoute());
          });
        }else{
          showCustomSnackBar(context, result.message);
        }
      });

    }
  }
}
