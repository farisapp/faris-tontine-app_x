import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../../../../controller/user_controller.dart';
import 'package:flutter/services.dart';

class VenteNanaPage extends StatefulWidget {
  const VenteNanaPage({super.key});

  @override
  _VenteNanaPageState createState() => _VenteNanaPageState();
}

class _VenteNanaPageState extends State<VenteNanaPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  bool _isUploading = false;
  final userId = Get.find<UserController>().userInfo?.id.toString() ?? "1";

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  Map<String, XFile?> _selectedImages = {
    "imageCouverture": null,
    "imageGauche": null,
    "imageDroite": null,
    "imageArriere": null,
    "imageInterieur": null,
  };

  Future<void> _uploadArticle() async {
    if (_titleController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _telephoneController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedImages["imageCouverture"] == null) {
      Get.snackbar(
        "",
        "Veuillez renseigner votre numéro et ajoutez au moins une image de couverture.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey,
        colorText: Colors.white,
      );
      return;
    }

    if (!RegExp(r'^\d{8}$').hasMatch(_telephoneController.text)) {
      Get.snackbar(
        "Erreur",
        "Le numéro de téléphone doit contenir exactement 8 chiffres.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    String articleCode = generateArticleCode();
    var uri =
    Uri.parse("https://apps.farisbusinessgroup.com/api/add_article.php");
    var request = http.MultipartRequest("POST", uri)
      ..fields['user_id'] = userId
      ..fields['code_unique'] = articleCode
      ..fields['nom'] = _titleController.text
      ..fields['quantite'] = "1"
      ..fields['prix_unitaire'] = _priceController.text
      ..fields['telephone'] = _telephoneController.text
      ..fields['commission'] = "5.00"
      ..fields['description'] = _descriptionController.text
      ..fields['user_nom'] = _nomController.text
      ..fields['user_prenom'] = _prenomController.text;

    // Ajouter les images
    for (var key in _selectedImages.keys) {
      if (_selectedImages[key] != null) {
        File imageFile = File(_selectedImages[key]!.path);
        request.files
            .add(await http.MultipartFile.fromPath(key, imageFile.path));
      }
    }

    // Afficher une fenêtre de chargement pendant la publication
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text("Publication en cours...")),
            ],
          ),
        );
      },
    );

    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    try {
      var result = jsonDecode(responseData);

      // Fermer la fenêtre de chargement
      Navigator.pop(context);

      setState(() {
        _isUploading = false;
      });
      if (result["success"] == true) {
        // Afficher une fenêtre de confirmation stylisée
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // coins arrondis
              ),
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    "Succès",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              content: Text(
                "Votre article est publié et vous pouvez le voir dans les offres Nana, mais nous devons d'abord le vérifier!\n\nCode : $articleCode",
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
                textAlign: TextAlign.left,
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Fermer la boîte de dialogue de succès
                    _resetForm(); // Réinitialiser le formulaire
                    Get.back(); // Revenir à la page précédente
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      }
      else {
        Get.snackbar(
          "Erreur",
          result["message"],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Fermer la fenêtre de chargement en cas d'erreur
      Navigator.pop(context);
      setState(() {
        _isUploading = false;
      });
      Get.snackbar(
        "Erreur",
        "Erreur lors de l'ajout de l'article.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _resetForm() {
    setState(() {
      _currentStep = 0;
      _titleController.clear();
      _priceController.clear();
      _telephoneController.clear();
      _descriptionController.clear();
      _nomController.clear();
      _prenomController.clear();
      _selectedImages.updateAll((key, value) => null);
      _pageController.jumpToPage(0);
      _isUploading = false;
    });
  }

  Future<void> _pickImage(String key) async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImages[key] = image;
      });
    }
  }

  String generateArticleCode() {
    int randomNumber = 10000 + (DateTime.now().millisecondsSinceEpoch % 90000);
    return "PN$randomNumber";
  }

  // Ajout du paramètre isRequired (par défaut true)
  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isNumeric = false,
    int? maxLength,
    bool isMultiline = false,
    int? maxLinesCustom,
    bool isRequired = true,
  }) {
    return TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        maxLength: maxLength,
        maxLines: maxLinesCustom ?? (isMultiline ? 5 : 1),
        // ❌ PAS D'inputFormatter pour bloquer à la saisie
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.orange),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          errorMaxLines: 2,
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return "Ce champ est obligatoire";
          }

          if (isNumeric && value != null) {
            // Si la valeur contient des virgules ou espaces → refuser
            if (value.contains(",") || value.contains(" ")) {
              return "Tapez un seul prix sans virgule ou espace, vous pouvez mettre les autres prix dans la description";
            }

            // Vérifie si c’est bien un nombre entier
            if (!RegExp(r'^\d+$').hasMatch(value)) {
              return "Tapez un seul prix sans virgule ou espace, vous pouvez mettre les autres prix dans la description.";
            }

            if (value.length > 8) {
              return "Le prix ne doit pas dépasser 8 chiffres soit 99 999 999";
            }
          }

          return null;
        }
    );
  }

  Widget _buildFirstStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildTextField(
            label: "Nom de l'article",
            icon: Icons.shopping_bag,
            controller: _titleController,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            label: "Décrire votre produit ici",
            icon: Icons.description,
            controller: _descriptionController,
            isMultiline: true,
            maxLength: 150,
            maxLinesCustom: 3,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            label: "Prix (FCFA)",
            icon: Icons.attach_money,
            controller: _priceController,
            isNumeric: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSecondStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildTextField(
            label: "Votre nom",
            icon: Icons.person,
            controller: _nomController,
            isRequired: false, // Optionnel
          ),
          const SizedBox(height: 10),
          _buildTextField(
            label: "Votre prénom",
            icon: Icons.person_outline,
            controller: _prenomController,
            isRequired: false, // Optionnel
          ),
          const SizedBox(height: 10),
          _buildTextField(
            label: "Numéro de téléphone",
            icon: Icons.phone,
            controller: _telephoneController,
            isNumeric: true,
            maxLength: 8,
          ),
          const SizedBox(height: 10),
          Column(
            children: _selectedImages.keys.map((key) {
              return Column(
                children: [
                  _selectedImages[key] != null
                      ? Image.file(File(_selectedImages[key]!.path), height: 100)
                      : ElevatedButton.icon(
                    onPressed: () => _pickImage(key),
                    icon: const Icon(Icons.image, color: Colors.white),
                    label: Text(
                      "Sélectionner $key",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Importer un article en vente"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Afficher le message uniquement dans la première étape
            _currentStep == 0
                ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.handshake, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Vous pouvez importer un article à vendre dans Faris Nana. Dès qu'un de nos clients souscrit pour acheter votre article en plusieurs tranches, nous l'achetons avec vous et nous le gardons à notre niveau pour le client.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
                : Container(),
            // Indicateur de progression
            LinearProgressIndicator(
                value: (_currentStep + 1) / 3, color: Colors.orange),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildFirstStep(),
                  _buildSecondStep(),
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
              backgroundColor: Colors.grey.shade700,
              label: const Text("Précédent"),
              icon: const Icon(Icons.arrow_back),
            ),
          const Spacer(),
          if (_currentStep < 1)
            FloatingActionButton.extended(
              onPressed: _nextPage,
              backgroundColor: Colors.orangeAccent,
              label: const Text("Suivant"),
              icon: const Icon(Icons.arrow_forward),
            ),
          if (_currentStep == 1)
            FloatingActionButton.extended(
              onPressed: _isUploading ? null : _uploadArticle,
              backgroundColor: Colors.orangeAccent,
              label: const Text("Publier l'article"),
              icon: const Icon(Icons.upload),
            ),
        ],
      ),
    );
  }
}
