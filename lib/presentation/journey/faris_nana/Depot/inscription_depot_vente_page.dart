import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
class InscriptionDepotVente extends StatefulWidget {
  const InscriptionDepotVente({super.key});

  @override
  _InscriptionDepotVenteState createState() => _InscriptionDepotVenteState();
}

class _InscriptionDepotVenteState extends State<InscriptionDepotVente> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Controllers pour les champs
  final TextEditingController nameController = TextEditingController();
  final TextEditingController entrepriseController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController adresseController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productDescriptionController = TextEditingController();
  final TextEditingController productQuantityController = TextEditingController();
  final TextEditingController productPriceController = TextEditingController();

  // Liste des images sélectionnées
  List<File> selectedImages = [];

  // 🔹 Sélectionner une image
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImages.add(File(pickedFile.path));
      });
    }
  }

  // 🔹 Supprimer une image
  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  // 🔹 Passer à l'étape suivante
  void _nextPage() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _currentStep++;
        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      });
    }
  }

  // 🔹 Revenir à l'étape précédente
  void _previousPage() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      });
    }
  }
// 🔹 Étape 3 : Téléchargement d'images
  Widget _buildStep3() {
    return _buildStepContent(
      "Ajoutez des images (vous pouvez importer plusieurs images",
      [
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.upload),
          label: const Text("Ajouter une image"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: selectedImages.asMap().entries.map((entry) {
            int index = entry.key;
            File image = entry.value;
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(image, width: 100, height: 100, fit: BoxFit.cover),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.cancel, color: Colors.orange),
                    onPressed: () => _removeImage(index),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
// 🔹 Étape 4 : Confirmation avant soumission
  Widget _buildStep4() {
    return _buildStepContent(
      "Confirmer et Soumettre",
      [
        const Text(
          "Merci d'avoir rempli le formulaire de dépot de stock de marchandises chez nous.\n Nous allons examiner votre demande de Dépot vente et vous contacter pour une fructueuse collaboration.\n Vous pouvez cliquez sur Soumettre et revenir voir le statut de votre demande dans 'Mes Dépots Vente'.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
            ],
    );
  }
// 🔹 Étape 1 : Informations personnelles
// 🔹 Étape 1 : Informations Personnelles
  Widget _buildStep1() {
    return _buildStepContent(
      "Informations Personnelles",
      [
        _buildTextField(nameController, "Votre nom et prénom", Icons.person, isRequired: true),
        _buildTextField(entrepriseController, "Nom de votre entreprise", Icons.business), // Facultatif
        _buildTextField(phoneController, "Votre contact téléphonique", Icons.phone, isRequired: true, isNumeric: true, length: 8),
        _buildTextField(adresseController, "Votre adresse de résidence", Icons.location_on), // Facultatif
        _buildTextField(emailController, "Adresse mail", Icons.email), // Facultatif
      ],
    );
  }

// 🔹 Étape 2 : Détails du produit
  Widget _buildStep2() {
    return _buildStepContent(
      "Détails du Produit",
      [
        _buildTextField(productNameController, "Nom du produit", Icons.shopping_bag, isRequired: true),
        _buildTextField(productDescriptionController, "Description du produit", Icons.description, maxLines: 3), // Facultatif
        _buildTextField(productQuantityController, "Quantité", Icons.confirmation_num, isNumeric: true), // Facultatif
        _buildTextField(productPriceController, "Prix unitaire (FCFA)", Icons.money, isRequired: true, isNumeric: true),
      ],
    );
  }

  // 🔹 Soumettre le formulaire
  void _submitForm() async {
    final apiUrl = "https://apps.farisbusinessgroup.com/api/add_depot_vente.php";

    if (!_formKey.currentState!.validate()) {
      Get.snackbar("Erreur", "Veuillez remplir tous les champs obligatoires.",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      var request = http.MultipartRequest("POST", Uri.parse(apiUrl));

      // Ajouter les champs texte
      request.fields['user_id'] = "1"; // ID utilisateur statique ou dynamique
      request.fields['nom_complet'] = nameController.text.trim();
      request.fields['nom_entreprise'] = entrepriseController.text.trim();
      request.fields['telephone'] = phoneController.text.trim();
      request.fields['adresse'] = adresseController.text.trim();
      request.fields['email'] = emailController.text.trim();
      request.fields['produit_nom'] = productNameController.text.trim();
      request.fields['produit_description'] = productDescriptionController.text.trim();
      request.fields['quantite'] = productQuantityController.text.trim().isEmpty ? "1" : productQuantityController.text.trim();
      request.fields['prix'] = productPriceController.text.trim();

      // Ajouter les images
      for (int i = 0; i < selectedImages.length && i < 3; i++) {
        String fileName = selectedImages[i].path.split('/').last;
        request.files.add(await http.MultipartFile.fromPath(
          'image${i + 1}',
          selectedImages[i].path,
          filename: fileName,
        ));
      }

      // Envoyer la requête
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      if (jsonResponse["status"] == "success") {
        Get.snackbar("Succès", jsonResponse["message"], backgroundColor: Colors.green, colorText: Colors.white);
        Get.offAllNamed("/home");
      } else {
        Get.snackbar("Erreur", jsonResponse["message"], backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Erreur", "Échec de la soumission : $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // 🔹 Construire les étapes du formulaire
  Widget _buildStepContent(String title, List<Widget> fields) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
          const SizedBox(height: 10),
          ...fields,
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 🔹 Construire les champs de texte
// 🔹 Fonction pour créer les champs de texte avec validation
  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isRequired = false, bool isNumeric = false, int? length, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        inputFormatters: isNumeric
            ? [
          FilteringTextInputFormatter.digitsOnly,
          if (length != null) LengthLimitingTextInputFormatter(length),
        ]
            : [],
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.orange),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (val) {
          if (isRequired && (val == null || val.isEmpty)) {
            return "Ce champ est obligatoire";
          }
          if (isNumeric && length != null && val != null && val.length != length) {
            return "Doit contenir exactement $length chiffres";
          }
          return null;
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inscription Dépôt Vente", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: "Voir mes Dépôts-Vente",
            onPressed: () {
              Get.toNamed("/mes-depots-vente");
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            LinearProgressIndicator(value: (_currentStep + 1) / 4, color: Colors.orange),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            FloatingActionButton.extended(
              onPressed: _previousPage,
              backgroundColor: Colors.grey,
              label: const Text("Précédent"),
              icon: const Icon(Icons.arrow_back),
            ),
          Spacer(),
          FloatingActionButton.extended(
            onPressed: _currentStep == 3 ? _submitForm : _nextPage,
            backgroundColor: Colors.orange,
            label: Text(_currentStep == 3 ? "Soumettre" : "Suivant"),
            icon: Icon(_currentStep == 3 ? Icons.send : Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}
