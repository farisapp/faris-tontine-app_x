import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:faris/controller/cotiser_controller.dart';
import 'package:faris/data/models/body/cotiser_body.dart';
import '../../../widgets/custom_snackbar.dart';
import '../../../widgets/progress_dialog.dart';
import 'faris_Depot_controller.dart';
import 'faris_nana_Depot_page.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class AddFarisDepotAchat extends StatefulWidget {
  const AddFarisDepotAchat({Key? key}) : super(key: key);

  @override
  _AddFarisDepotAchatState createState() => _AddFarisDepotAchatState();
}

class _AddFarisDepotAchatState extends State<AddFarisDepotAchat> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Controllers pour les champs
  final TextEditingController nomArticleCtrl = TextEditingController();
  final TextEditingController boutiqueCtrl = TextEditingController();
  final TextEditingController mail = TextEditingController();
  final TextEditingController prixArticleCtrl = TextEditingController();
  final TextEditingController nbrSouhaiteCtrl = TextEditingController();
  final TextEditingController descriptionCtrl = TextEditingController();
  final TextEditingController votreNomCtrl = TextEditingController();
  final TextEditingController numVendeurCtrl = TextEditingController();
  final TextEditingController telephoneClientCtrl = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController adresseResidenceCtrl = TextEditingController(); // ✅ Ajout du contrôleur
  void _nextPage() {
    if (_formKey.currentState!.validate()) {
      print("🔹 Étape actuelle: $_currentStep");

      if (_currentStep == 2) { // Dernière étape = Soumission du formulaire
        _submitForm(); // 🔹 Soumettre directement
      } else {
        setState(() {
          _currentStep++;
          print("🔹 Passage à l'étape $_currentStep");
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }

    }
  }


  void _previousPage() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _showPaymentSuccess() {
    if (!mounted) return; // ✅ Vérifie que la page est encore active avant d'afficher la boîte de dialogue

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Paiement réussi", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          content: const Text(
            "Votre paiement de 100 FCFA a été effectué avec succès.\n"
                "Votre Depot sera maintenant enregistrée.",
            textAlign: TextAlign.justify,
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (!mounted) return; // ✅ Vérifie que la page est encore active avant de fermer le dialogue
                Navigator.pop(context);
                _submitForm(); // ✅ Soumet le formulaire après confirmation
              },
              child: const Text("OK", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _processPayment(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Paiement en cours...", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.orange), // 🔄 Indicateur de chargement
              const SizedBox(height: 15),
              const Text(
                "Veuillez patienter pendant le traitement de votre paiement...",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        );
      },
    );

    // Simuler un délai pour le paiement (remplacer par API Mobile Money)
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context); // Fermer le loader
      _showPaymentSuccess(); // ✅ Afficher la confirmation de paiement
    });
  }

  void _showPaymentWarning() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Paiement requis", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Un paiement de 100 FCFA est requis pour valider votre Depot.\n"
                    "Veuillez effectuer le paiement ci-dessous pour continuer.",
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _processPayment(context); // 🔹 Lance le processus de paiement
                },
                icon: const Icon(Icons.payment, color: Colors.white),
                label: const Text("Payer 100 FCFA"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Fermer la boîte de dialogue
              child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }
  void _submitFormWithoutPayment() {
    // Attribuer automatiquement le nom du vendeur à partir de la boutique
    mail.text = mail.text;  // ✅ Assigne la valeur avant soumission

    // Debug : Vérifier les données envoyées
    debugPrint("🔹 Envoi des données à l'API (Sans paiement) :");
    debugPrint("🔹 Nom Article : ${nomArticleCtrl.text}");
    debugPrint("🔹 Boutique : ${boutiqueCtrl.text}");
    debugPrint("🔹 Nom Vendeur (Auto) : ${mail.text}"); // ✅ Doit être égal à Boutique
    debugPrint("🔹 Prix Article : ${prixArticleCtrl.text}");
    debugPrint("🔹 Numéro Vendeur : ${numVendeurCtrl.text}");
    debugPrint("🔹 Description : ${descriptionCtrl.text}");
    debugPrint("🔹 Nombre souhaité : ${nbrSouhaiteCtrl.text}");
    debugPrint("🔹 Téléphone Client : ${telephoneClientCtrl.text}");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext c) {
        return ProgressDialog(message: "Enregistrement en cours...");
      },
    );

    try {
      FarisDepotController().ajoutDepotArticle(
        nomArticleCtrl.text,
        boutiqueCtrl.text,
        mail.text, // ✅ Prend la valeur de Boutique
        prixArticleCtrl.text,
        "", // Prix souhaité supprimé
        numVendeurCtrl.text,
        descriptionCtrl.text,
        nbrSouhaiteCtrl.text,
        telephoneClientCtrl.text,
      ).then((result) {
        Navigator.pop(context);
        if (result == 1) {
          _showSuccessDialog();
        } else {
          showCustomSnackBar(context, "Erreur lors de l'enregistrement. Réessayez.", isError: true);
        }
      });
    } catch (e) {
      Navigator.pop(context);
      showCustomSnackBar(context, "Erreur : ${e.toString()}", isError: true);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Succès", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          content: const Text("Votre Depot a été enregistrée avec succès ! Nous vous contacterons pour la suite de la procédure."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Ferme la boîte de dialogue
                _resetForm(); // Réinitialise le formulaire
              },
              child: const Text("OK", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
  Widget _buildPaymentStep() {
    return SingleChildScrollView( // ✅ Ajout du défilement
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                const Text(
                  "Payer 100 FCFA",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Champ numéro de téléphone
          const Text(
            "Numéro de téléphone de paiement",
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: telephoneClientCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Entrez votre numéro de téléphone",
              filled: true,
              border: OutlineInputBorder(),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8), // Limite à 8 chiffres
            ],
            validator: (val) => val == null || val.isEmpty
                ? "Veuillez entrer votre numéro de téléphone"
                : null,
          ),
          const SizedBox(height: 20),

          // Champ OTP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Code de validation (OTP)",
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => _callNumber("100"), // Appeler le code USSD
                child: const Text(
                  "Générer le code OTP",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          TextFormField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Entrez le code OTP",
              filled: true,
              border: OutlineInputBorder(),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (val) => val == null || val.isEmpty
                ? "Veuillez entrer le code OTP"
                : null,
          ),
          const SizedBox(height: 20),


       ],
      ),
    );
  }
  void _resetForm() {
    // Réinitialiser l'état du formulaire (les messages d'erreur, etc.)
    _formKey.currentState?.reset();

    // Vider les controllers
    nomArticleCtrl.clear();
    boutiqueCtrl.clear();
    mail.clear();
    prixArticleCtrl.clear();
    nbrSouhaiteCtrl.clear();
    descriptionCtrl.clear();
    votreNomCtrl.clear();
    numVendeurCtrl.clear();
    telephoneClientCtrl.clear();
    _codeController.clear();
    adresseResidenceCtrl.clear();

    // Réinitialiser l'étape et remettre la PageView à la première page
    setState(() {
      _currentStep = 0;
      _pageController.jumpToPage(0);
    });
  }
  Future<void> _submitForm() async {
    if (!mounted) return; // ✅ Vérifie que la page est toujours active

    if (!_formKey.currentState!.validate()) {
      return;
    }

    mail.text = mail.text; // Associe le vendeur à la boutique

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext c) {
        return ProgressDialog(message: "Enregistrement en cours...");
      },
    );

    try {
      int result = await FarisDepotController().ajoutDepotArticle(
        nomArticleCtrl.text,
        boutiqueCtrl.text,
        mail.text,
        prixArticleCtrl.text,
        "", // Pas de prix souhaité
        numVendeurCtrl.text,
        descriptionCtrl.text,
        nbrSouhaiteCtrl.text,
        telephoneClientCtrl.text,
      );

      if (!mounted) return; // ✅ Vérifie que la page est toujours active

      Navigator.pop(context); // Ferme le ProgressDialog

      if (result == 1) {
        _showSuccessDialog();
      } else {
        showCustomSnackBar(context, "Erreur lors de l'enregistrement. Réessayez.", isError: true);
      }
    } catch (e) {
      if (!mounted) return; // ✅ Vérifie que la page est encore active

      Navigator.pop(context);
      showCustomSnackBar(context, "Erreur : ${e.toString()}", isError: true);
    }
  }


  /// 📞 Appel USSD pour générer le code OTP
  Future<void> _callNumber(String montant) async {
    String ussdCode = '*144*4*6*$montant#';
    String encoded = Uri.encodeComponent(ussdCode);
    String url = 'tel:$encoded';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Code USSD", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.orange.shade50,
                ),
                child: Text(
                  ussdCode,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.blue),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: ussdCode));
                      Navigator.pop(context);
                      showCustomSnackBar(context, "Code copié dans le presse-papiers", isError: false);
                    },
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: ussdCode));
                      Navigator.pop(context);
                      showCustomSnackBar(context, "Code USSD copié. Veuillez le coller dans l'application Téléphone.", isError: false);
                    },
                    icon: const Icon(Icons.call),
                    label: const Text("Appeler"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fermer", style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }
  bool isProcessing = false;
  Future<void> _validatePayment() async {
    if (isProcessing) return;
    isProcessing = true;

    if (!_formKey.currentState!.validate()) {
      isProcessing = false;
      return;
    }

    if (!mounted) return; // ✅ Vérifie que la page est encore active

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(message: "Paiement en cours..."),
    );

    try {
      CotiserController cotiserController = Get.find<CotiserController>();

      int tontineId = 3161;
      int periodeId = 44635;

      CotiserBody body = CotiserBody(
        tontine: tontineId,
        periode: periodeId,
        montant: 100,
        provider: "orange money",
        telephone: telephoneClientCtrl.text.trim(),
        code_otp: _codeController.text.trim().isEmpty ? "000000" : _codeController.text.trim(),
      );

      cotiserController.cotiser(body).then((result) {
        if (!mounted) return; // ✅ Vérifie que la page est toujours active avant d'afficher le message

        if (Navigator.canPop(context)) Navigator.pop(context); // Ferme le ProgressDialog
        isProcessing = false;

        if (result.isSuccess) {
          showCustomSnackBar(context, "✅ Paiement validé avec succès !", isError: false);
          _showPaymentSuccess(); // ✅ Affiche le message sans navigation immédiate
        } else {
          showCustomSnackBar(context, "❌ Paiement échoué : ${result.message}", isError: true);
        }
      });
    } catch (e) {
      if (!mounted) return; // ✅ Évite l'accès au contexte si la page est déjà fermée

      if (Navigator.canPop(context)) Navigator.pop(context);
      showCustomSnackBar(context, "❌ Erreur API : ${e.toString()}", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ Ajout de cette ligne
      appBar: AppBar(
        title: const Text("Inscription Dépôt-vente", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18, // Réduction de la taille du texte
        )),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: "Voir mes Dépôt-ventes",
            onPressed: () {
              Get.to(() => FarisNanaDepotPage()); // Navigation vers la page de Depots
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
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
                        "Vous êtes commerçant, mais vous n'avez pas encore de magasin ou de boutique pour stocker votre marchandise? "
                            "Nous stockons votre marchandise dans notre magasin, vous faites la promotion et nous livrons les produits achetés à vos clients. Vous aurez également un dispositif de suivi de votre stock.",
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
            ),
            LinearProgressIndicator(value: (_currentStep + 1) / 4, color: Colors.orange), // ✅ Correction de la progression
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildSecondStep(), // 🔄 Déplacé en premier
                  _buildFirstStep(),  // 🔄 Déplacé en deuxième
                  _buildConfirmationStep(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0) // 🔙 Bouton "Précédent" visible seulement après la 1ère étape
            FloatingActionButton.extended(
              onPressed: _previousPage,
              backgroundColor: Colors.grey.shade700,
              label: const Text("Précédent"),
              icon: const Icon(Icons.arrow_back),
            ),
          Spacer(), // Espace entre les boutons
          FloatingActionButton.extended(
            onPressed: () {
              if (_currentStep == 2) { // 🔹 Dernière étape = soumission
                _submitForm();
              } else {
                _nextPage();
              }
            },
            backgroundColor: Colors.orangeAccent,
            label: Text(_currentStep == 2 ? "Envoyer" : "Suivant"), // 🔴 Modifier l'étape 2
            icon: Icon(_currentStep == 2 ? Icons.send : Icons.arrow_forward),
          ),

        ],
      ),
      bottomNavigationBar: _currentStep == 0 // ✅ Afficher seulement sur la 1ère page
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () {
            Get.to(() => FarisNanaDepotPage()); // 🔹 Navigation vers la liste des Depots
          },
          icon: const Icon(Icons.list, color: Colors.white),
          label: const Text("Voir mes Dépôt-ventes"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      )
          : null, // ✅ Masquer pour les autres étapes

    );
  }



  Widget _buildFirstStep() {
    return _buildStepContent(
      "Détails du produit",
      [
        _buildTextField(nomArticleCtrl, "Nom du produit *", Icons.shopping_bag, isRequired: true),
        _buildTextField(descriptionCtrl, "Description du produit", Icons.description, maxLines: 3),
        _buildTextField(nbrSouhaiteCtrl, "Quantité", Icons.confirmation_num, isNumeric: true),
        _buildTextField(prixArticleCtrl, "Prix unitaire (FCFA) *", Icons.money, isRequired: true, isNumeric: true),
      ],
    );
  }

  Widget _buildSecondStep() {
    return _buildStepContent(
      "Informations personnelles",
      [
        _buildTextField(votreNomCtrl, "Votre nom ou prénom *", Icons.person, isRequired: true),
        _buildTextField(boutiqueCtrl, "Nom de votre entreprise (facultatif)", Icons.business, isRequired: false), // Ajouté ici
        _buildTextField(telephoneClientCtrl, "Votre contact teléphonique *", Icons.phone, isRequired: true, isNumeric: true, length: 8),
        _buildTextField(adresseResidenceCtrl, "Votre adresse de résidence", Icons.location_on, isRequired: false), // Ajouté ici
        _buildTextField(mail, "Adresse mail", Icons.email, isRequired: false),
      ],
    );
  }

  Widget _buildConfirmationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ✅ Icône de confirmation
          const Icon(
            Icons.check_circle_outline,
            color: Colors.orange,
            size: 80,
          ),
          const SizedBox(height: 10),

          // ✅ Titre et sous-titre
          const Text(
            "Confirmation",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Vérifiez vos informations avant de valider.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 20),

          // ✅ Carte de confirmation (Informations du formulaire)
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConfirmationRow("Nom de l'article", nomArticleCtrl.text),
                  _buildConfirmationRow("Boutique", boutiqueCtrl.text),
                  _buildConfirmationRow("Prix", "${prixArticleCtrl.text} FCFA"),
                  _buildConfirmationRow("Nombre de tranches", nbrSouhaiteCtrl.text.isEmpty ? "Non spécifié" : nbrSouhaiteCtrl.text),
                  _buildConfirmationRow("Votre Nom", votreNomCtrl.text.isEmpty ? "Non renseigné" : votreNomCtrl.text),
                  _buildConfirmationRow("Votre Contact", telephoneClientCtrl.text),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ✅ Bouton Modifier
          ElevatedButton.icon(
            onPressed: _previousPage, // Retour à l'étape précédente
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text("Modifier"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 20), // ✅ Ajout d'un espace pour éviter l'overflow
        ],
      ),
    );
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
        ],
      ),
    );
  }


  Widget _buildStepContent(String title, List<Widget> fields) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...fields,
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isRequired = false, bool isNumeric = false, int? length, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumeric
            ? [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(length), // Validation à 8 chiffres
        ]
            : [],
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.orange),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (val) {
          if (isRequired && (val == null || val.isEmpty)) {
            return "Champ obligatoire";
          }
          if (isNumeric && length != null && val != null && val.length != length) {
            return "Le numéro doit contenir exactement $length chiffres";
          }
          return null;
        },
      ),
    );
  }
}