
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:faris/data/models/app_error_model.dart';

class AppErrorWidget extends StatelessWidget {
  final AppErrorType errorType;
  final VoidCallback onPressed;

  const AppErrorWidget({
    Key? key,
    required this.errorType,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            errorType == AppErrorType.api ? 'assets/animations/api_error.json' : 'assets/animations/no_internet.json',
            width: 200,
            height: 200,
          ),
          SizedBox(height: 10,),
          Text(
            errorType == AppErrorType.api
                ? "Une erreur s'est produite"
                : "Vérifiez votre connexion intenet",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          SizedBox(height: 5,),
          TextButton(
            child: Text("Réessayez"),
            style: TextButton.styleFrom(
                foregroundColor: Colors.white, side: BorderSide(width: 1, color: Colors.red),
                minimumSize: Size(155, 35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: Colors.red
            ),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}