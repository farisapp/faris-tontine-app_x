import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ModeSelectionPage extends StatelessWidget {
  const ModeSelectionPage({Key? key}) : super(key: key);

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  void _navigateOnline(BuildContext context) async {
    bool isConnected = await _checkInternetConnection();
    if (isConnected) {
      // Naviguer vers la page d'accueil en ligne
      Get.offNamed('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Pas de connexion Internet. Veuillez réessayer."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateOffline() {
    // Naviguer vers une page hors-ligne
    Get.offNamed('/offline');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mode de Navigation"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Choisissez votre mode de navigation",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _navigateOnline(context),
              icon: Icon(Icons.wifi),
              label: Text("Mode En Ligne"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _navigateOffline,
              icon: Icon(Icons.wifi_off),
              label: Text("Mode Hors-Ligne"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
                backgroundColor: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
