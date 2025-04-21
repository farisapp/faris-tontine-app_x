import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'dart:convert';

class SoumettreCNIBPage extends StatefulWidget {
  final String riderId;
  final String nom;
  final String cnib;
  final String telephone;

  SoumettreCNIBPage({required this.riderId, required this.nom, required this.cnib, required this.telephone});

  @override
  _SoumettreCNIBPageState createState() => _SoumettreCNIBPageState();
}

class _SoumettreCNIBPageState extends State<SoumettreCNIBPage> {
  File? _rectoImage;
  File? _versoImage;
  File? _photoProfil;
  final picker = ImagePicker();

  Future<void> _pickImage(String type) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (type == 'recto') {
          _rectoImage = File(pickedFile.path);
        } else if (type == 'verso') {
          _versoImage = File(pickedFile.path);
        } else if (type == 'profil') {
          _photoProfil = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _uploadData() async {
    print("🔹 Tentative d'envoi des données...");

    if (_rectoImage == null || _versoImage == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Erreur"),
          content: Text("Veuillez sélectionner les images recto et verso"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    // Afficher l'indicateur de progression
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      print("🔹 Préparation de la requête...");
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("https://apps.farisbusinessgroup.com/api/Livraison/upload_cnib.php"),
      );

      request.fields['cnib'] = widget.cnib;

      print("🔹 Ajout des images...");
      request.files.add(await http.MultipartFile.fromPath("cnib_recto", _rectoImage!.path));
      request.files.add(await http.MultipartFile.fromPath("cnib_verso", _versoImage!.path));

      if (_photoProfil != null) {
        request.files.add(await http.MultipartFile.fromPath("photo_profil", _photoProfil!.path));
      }

      print("🔹 Envoi de la requête...");
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);

      // Fermer l'indicateur de progression
      Navigator.pop(context);

      print("🔹 Réponse du serveur : $jsonResponse");

      if (response.statusCode == 200 && jsonResponse['success']) {
        // Affichage d'une boîte de dialogue de succès
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text("Succès"),
            content: Text(jsonResponse['message'] ?? "Images envoyées avec succès"),
          ),
        );

        // Après 2 secondes, fermer la boîte de dialogue et quitter la page
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context); // Ferme la boîte de dialogue de succès
          Navigator.pop(context); // Ferme la page SoumettreCNIBPage et revient à ProfilRiderPage
        });
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Erreur"),
            content: Text(jsonResponse['message'] ?? "Échec de l'envoi"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Fermer l'indicateur de progression en cas d'exception
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Erreur"),
          content: Text("Exception : $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Soumettre CNIB & Photo de Profil"), backgroundColor: Colors.orange),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Nom: ${widget.nom}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("CNIB: ${widget.cnib}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("Téléphone: ${widget.telephone}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            _rectoImage == null
                ? Text("Aucune image Recto sélectionnée", style: TextStyle(color: Colors.grey))
                : Image.file(_rectoImage!, height: 100),
            ElevatedButton.icon(
              onPressed: () => _pickImage('recto'),
              icon: Icon(Icons.photo_library),
              label: Text("Choisir Image Recto"),
            ),
            SizedBox(height: 10),
            _versoImage == null
                ? Text("Aucune image Verso sélectionnée", style: TextStyle(color: Colors.grey))
                : Image.file(_versoImage!, height: 100),
            ElevatedButton.icon(
              onPressed: () => _pickImage('verso'),
              icon: Icon(Icons.photo_library),
              label: Text("Choisir Image Verso"),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _uploadData,
              icon: Icon(Icons.upload),
              label: Text("Soumettre", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}
