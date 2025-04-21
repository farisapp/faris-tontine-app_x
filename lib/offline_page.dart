import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:faris/FarisPay/preselect_pay_page.dart';

class OfflinePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mode Hors-Ligne"),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[100], // Fond légèrement gris
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône principale
              Icon(Icons.wifi_off, size: 100, color: Colors.redAccent),
              SizedBox(height: 20),

              // Texte d'information
              Text(
                "Pas de connexion internet ?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
              SizedBox(height: 40),

              // Bouton pour accéder aux fonctionnalités hors-ligne (Carré)
              ElevatedButton.icon(
                onPressed: () {
                  // Naviguer vers PreselectPayPage
                  Get.to(() => PreselectPayPage());
                },
                icon: Icon(Icons.offline_bolt, size: 24, color: Colors.white),
                label: Text("Cliquez ici pour accéder aux fonctionnalités sans internet"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // Rend le bouton complètement carré
                  ),
                  elevation: 5,
                ),
              ),


              SizedBox(height: 20),

              // Bouton Réessayer (en bas)
              OutlinedButton.icon(
                onPressed: () {
                  // Relance la vérification de connexion
                  Get.offNamed('/splash');
                },
                icon: Icon(Icons.refresh, size: 24, color: Colors.blue),
                label: Text(
                  "Réessayer",
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue, width: 2), // Contour bleu
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Bouton Quitter avec confirmation
              ElevatedButton.icon(
                onPressed: () {
                  _showExitConfirmation(context);
                },
                icon: Icon(Icons.exit_to_app, size: 24, color: Colors.red),
                label: Text(
                  "Quitter",
                  style: TextStyle(color: Colors.red),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.redAccent),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Méthode pour afficher une boîte de confirmation avant de quitter
  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmer"),
          content: Text("Voulez-vous vraiment quitter l'application ?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Annuler", style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                SystemNavigator.pop(); // Quitte l'application
              },
              child: Text("Quitter", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
