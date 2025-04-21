import 'package:clipboard/clipboard.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';

import 'col_tontine_page.dart';
import 'indiv_tontine_page.dart';
import 'tontine_page.dart';

class AddTontineSuccessPage extends StatelessWidget {
  final String? code_tontine;
  final String? tontineID;
  final String? type;
  final int? status;

  const AddTontineSuccessPage({
    Key? key,
    required this.code_tontine,
    this.tontineID,
    this.status,
    this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String successMessage;
    Widget actionButton;
    bool showCodeWidget = false;

    if (type == "EPARGNE COLLECTIVE") {
      successMessage = "Votre épargne collective Faris a été créée avec succès !";
      actionButton = ElevatedButton.icon(
        onPressed: () {
          Get.to(() => ColTontinePage(), transition: Transition.rightToLeftWithFade);
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        icon: Icon(Icons.list, color: Colors.white),
        label: Text("Voir vos épargnes collectives",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      );
      showCodeWidget = true;
    } else if (type == "TONTINE EN GROUPE") {
      successMessage = "Votre tontine en groupe a été créée avec succès !";
      actionButton = ElevatedButton.icon(
        onPressed: () {
          Get.to(() => TontinePage(), transition: Transition.rightToLeftWithFade);
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        icon: Icon(Icons.list, color: Colors.white),
        label: Text("Voir vos tontines en groupe",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      );
      showCodeWidget = true;
    } else {
      // Pour l'épargne individuelle
      successMessage = "Votre épargne individuelle a été créée avec succès !";
      actionButton = ElevatedButton.icon(
        onPressed: () {
          Get.to(() => IndivTontinePage(), transition: Transition.rightToLeftWithFade);
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        icon: Icon(Icons.list, color: Colors.white),
        label: Text("Voir vos épargnes individuelles",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      );
      showCodeWidget = false;
    }

    String displayCode = code_tontine ?? "Code indisponible";

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(Icons.clear, color: Colors.orange),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Animation de succès
              Lottie.asset(
                'assets/animations/success.json',
                width: 200,
                height: 200,
                repeat: false,
              ),
              SizedBox(height: 20),
              // Message de confirmation
              Text(
                successMessage,
                style: TextStyle(color: Colors.black, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              if (showCodeWidget) ...[
                // Affichage du code avec possibilité de le copier en appuyant longuement
                GestureDetector(
                  onLongPress: () {
                    FlutterClipboard.copy(displayCode).then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Code copié dans le presse-papier !'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    });
                  },
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: Radius.circular(5),
                    strokeWidth: 2,
                    color: Colors.green,
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          displayCode,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Appuyez longtemps pour copier le code",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
              ],
              // Bouton d'action spécifique selon le type
              actionButton,
              SizedBox(height: 20),
              // Bouton Fermer
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close, color: Colors.white),
                label: Text(
                  "Fermer",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
