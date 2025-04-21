import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controller/farisnana_controller.dart';
import '../../../utils/ussd_helper.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/progress_dialog.dart';
import 'faris_nana_Demande_page.dart';
import 'package:faris/controller/cotiser_controller.dart';
import 'package:faris/data/models/body/cotiser_body.dart';

class AddFarisNanaAchat extends StatefulWidget {
  const AddFarisNanaAchat({Key? key}) : super(key: key);

  @override
  _AddFarisNanaAchatState createState() => _AddFarisNanaAchatState();
}

class _AddFarisNanaAchatState extends State<AddFarisNanaAchat> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Champs
  final TextEditingController nomArticleCtrl = TextEditingController();
  final TextEditingController boutiqueCtrl = TextEditingController();
  final TextEditingController nomVendeurCtrl = TextEditingController();
  final TextEditingController prixArticleCtrl = TextEditingController();
  final TextEditingController nbrSouhaiteCtrl = TextEditingController();
  final TextEditingController descriptionCtrl = TextEditingController();
  final TextEditingController votreNomCtrl = TextEditingController();
  final TextEditingController numVendeurCtrl = TextEditingController();
  final TextEditingController telephoneClientCtrl = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  // Liste d’opérateurs (Orange / Moov)
  final List<Map<String, String>> _providers = [
    {
      "libelle": "Orange Money",
      "slug": "orange money",
      "logo": "assets/images/orange_money.png",
    },
    {
      "libelle": "Moov Money",
      "slug": "moov money",
      "logo": "assets/images/moov_money.png",
    },
  ];
  String _selectedProvider = "orange money"; // Par défaut : Orange

  bool isProcessing = false;

  // IDs fictifs pour l’exemple
  final int _tontineId = 3161;
  final int _periodeId = 44635;
  // Suppression de la variable fixe _montant

  /// Fonction qui calcule le montant de paiement en fonction du prix de l'article
  double getPaymentAmount() {
    double price = double.tryParse(prixArticleCtrl.text) ?? 0.0;
    if (price <= 25000) {
      return 1025;
    } else if (price < 100000) {
      return 0.07 * price;
    } else {
      return 4900;
    }
  }

  /// ------------------------------------------------------------------------
  /// Navigation Step 0..3
  /// ------------------------------------------------------------------------
  void _nextPage() {
    if (_formKey.currentState!.validate()) {
      if (_currentStep == 2) {
        // Étape 2 => Confirmation => on affiche la popup
        _showPaymentWarningPopup();
      } else {
        setState(() {
          _currentStep++;
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
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Popup d’avertissement avant d’arriver à l’étape 3 (paiement)
  void _showPaymentWarningPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: const [
              Icon(Icons.warning, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Text("Avertissement", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
            ],
          ),
          content: Text(
            "Afin de nous prouver la sincérité de votre démarche et pour que nous puissions examiner votre demande, "
                "vous devez payer un montant de ${getPaymentAmount().toStringAsFixed(0)} F, calculé en fonction du prix du bien. Ce montant est remboursable en cas de non satisfaction.\n\n"
                "Vous pouvez aussi annuler votre demande à tout moment et recevoir votre remboursement.",
            textAlign: TextAlign.justify,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler", style: TextStyle(color: Colors.grey, fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _currentStep = 3; // passer à l’écran de paiement
                });
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text("Continuer", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  /// ------------------------------------------------------------------------
  /// Étape 3 : Paiement => On clique sur "VALIDER"
  Future<void> _validatePayment() async {
    if (isProcessing) return;
    isProcessing = true;

    if (!_formKey.currentState!.validate()) {
      isProcessing = false;
      return;
    }
    if (!mounted) return;

    // On récupère le controller
    CotiserController cotiserController = Get.find<CotiserController>();
    final paymentAmount = getPaymentAmount();

    if (_selectedProvider == "moov money") {
      // 1) init Moov => si succès => bottom sheet OTP
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => ProgressDialog(message: "Paiement Moov..."),
      );

      cotiserController
          .makeRequestInitMoovOtp(
        phone: telephoneClientCtrl.text.trim(),
        amount: paymentAmount.toStringAsFixed(0),
      )
          .then((result) {
        Navigator.pop(context); // Ferme le loader
        isProcessing = false;

        if (result.isSuccess) {
          // Ouvrir second bottom sheet pour saisir l’OTP
          if (result.message != null) {
            _buildMoovOtpConfirmSheet(result.message!);
            showCustomSnackBar(context, "Code OTP Moov envoyé par SMS", isError: false);
          } else {
            showCustomSnackBar(context, "Réponse Moov inattendue: message null", isError: true);
          }
        } else {
          showCustomSnackBar(context, "Echec init Moov: ${result.message}", isError: true);
        }
      });
    } else {
      // 2) Orange => un seul call direct
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ProgressDialog(message: "Paiement Orange..."),
      );

      // Body pour Orange
      CotiserBody body = CotiserBody(
        tontine: _tontineId,
        periode: _periodeId,
        montant: paymentAmount,
        provider: "orange money",
        telephone: telephoneClientCtrl.text.trim(),
        code_otp: _codeController.text.trim().isEmpty ? "000000" : _codeController.text.trim(),
      );

      cotiserController.cotiser(body).then((result) {
        Navigator.pop(context);
        isProcessing = false;

        if (result.isSuccess) {
          showCustomSnackBar(context, "✅ Paiement Orange validé avec succès !", isError: false);
          _showPaymentSuccess();
        } else {
          showCustomSnackBar(context, "❌ Paiement Orange échoué : ${result.message}", isError: true);
        }
      });
    }
  }


  /// 2e bottom sheet : l’utilisateur saisit l’OTP Moov
  void _buildMoovOtpConfirmSheet(String messageMoov) {
    final parts = messageMoov.split(';'); // "transId;requestId"
    final transId = parts[0];
    final reqId = parts[1];

    // On vide le code OTP
    _codeController.text = "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
            top: 10,
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: _buildMoovOtpForm(transId, reqId),
          ),
        );
      },
    );
  }

  /// Champ pour saisir l’OTP final
  Widget _buildMoovOtpForm(String transId, String reqId) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 15),
        const Text("Confirmation OTP (Moov)", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
        const Divider(),
        TextFormField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Entrez le code OTP Moov",
            border: OutlineInputBorder(),
            filled: true,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => _confirmMoovPayment(transId, reqId),
                style: TextButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                child: const Text("VALIDER"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: const Text("ANNULER"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  /// Appel final Moov => envoie code_otp + trans_id + request_id
  void _confirmMoovPayment(String transId, String reqId) {
    final otp = _codeController.text.trim();
    if (otp.isEmpty) {
      showCustomSnackBar(context, "Veuillez saisir le code OTP Moov", isError: true);
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProgressDialog(message: "Confirmation Moov..."),
    );

    final cotiserController = Get.find<CotiserController>();
    CotiserBody body = CotiserBody(
      tontine: _tontineId,
      periode: _periodeId,
      montant: getPaymentAmount(),
      provider: "moov money",
      telephone: telephoneClientCtrl.text.trim(),
      code_otp: otp,
      trans_id: transId,
      request_id: reqId,
    );

    cotiserController.cotiser(body, provider: "moov money").then((result) {
      Navigator.pop(context);
      if (result.isSuccess) {
        Navigator.pop(context); // Fermer bottom sheet
        showCustomSnackBar(context, "Payement effectué avec succès", isError: false);
        _showPaymentSuccess();
      } else {
        showCustomSnackBar(context, "Echec paiement: ${result.message}", isError: true);
      }
    });
  }

  /// Message de succès => enregistrement
  void _showPaymentSuccess() {
    if (!mounted) return;
    double paymentAmount = getPaymentAmount();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Paiement réussi", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          content: Text(
            "Votre paiement de ${paymentAmount.toStringAsFixed(0)} F a été effectué avec succès.\n"
                "Cliquez sur OK pour enregistrer votre demande maintenant.",
            textAlign: TextAlign.justify,
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (!mounted) return;
                Navigator.pop(context);
                _submitForm(); // Ensuite on enregistre
              },
              child: const Text("OK", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  /// Envoi final (FarisnanaController)
  Future<void> _submitForm() async {
    if (!mounted) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }
    nomVendeurCtrl.text = boutiqueCtrl.text;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext c) => ProgressDialog(message: "Enregistrement en cours..."),
    );

    try {
      int result = await FarisnanaController().ajoutDemandeArticle(
        nomArticleCtrl.text,
        boutiqueCtrl.text,
        nomVendeurCtrl.text,
        prixArticleCtrl.text,
        "",
        numVendeurCtrl.text.trim().isEmpty ? "Non renseigné" : numVendeurCtrl.text.trim(),
        descriptionCtrl.text,
        nbrSouhaiteCtrl.text,
        telephoneClientCtrl.text,
      );

      Navigator.pop(context);
      if (!mounted) return;

      if (result == 1) {
        _showSuccessDialog();
      } else {
        showCustomSnackBar(context, "Erreur lors de l'enregistrement. Réessayez.", isError: true);
      }
    } catch (e) {
      Navigator.pop(context);
      showCustomSnackBar(context, "Erreur : $e", isError: true);
    }
  }

  /// Confirmation d’enregistrement
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Succès", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          content: const Text("Votre demande a été enregistrée avec succès ! Nous vous contacterons pour la suite."),
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
  void _resetForm() {
    // Réinitialiser les validations et champs du formulaire
    _formKey.currentState?.reset();

    // Vider tous les controllers
    nomArticleCtrl.clear();
    boutiqueCtrl.clear();
    nomVendeurCtrl.clear();
    prixArticleCtrl.clear();
    nbrSouhaiteCtrl.clear();
    descriptionCtrl.clear();
    votreNomCtrl.clear();
    numVendeurCtrl.clear();
    telephoneClientCtrl.clear();
    _codeController.clear();

    // Réinitialiser l'étape et remettre la PageView à la première page
    setState(() {
      _currentStep = 0;
      _pageController.jumpToPage(0);
    });
  }

  // -------------------------------------------------------------------------
  // Le build: 4 steps
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Acheter un bien à tempérament", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: "Voir les demandes",
            onPressed: () => Get.to(() => FarisNanaDemandePage()),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Bandeau explicatif + progression
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
                        "Vous ne touvez pas le bien recherché dans notre liste ? Dites nous ce que vous souhaitez acheter en plusieurs tranches et nous le mettrons à votre disposition! "
                            "Si vous connaissez aussi un commercçant qui vend le produit désiré mettez-nous en contact en renseignant ce formulaire.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.orange.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            LinearProgressIndicator(
              value: (_currentStep + 1) / 4,
              color: Colors.orange,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildFirstStep(),
                  _buildSecondStep(),
                  _buildConfirmationStep(),
                  _buildPaymentStep(),
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
          FloatingActionButton.extended(
            onPressed: _nextPage,
            backgroundColor: Colors.orangeAccent,
            label: Text(_currentStep == 3 ? "" : "Suivant"),
            icon: Icon(_currentStep == 3 ? Icons.send : Icons.arrow_forward),
          ),
        ],
      ),
      bottomNavigationBar: _currentStep == 0
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () => Get.to(() => FarisNanaDemandePage()),
          icon: const Icon(Icons.list, color: Colors.white),
          label: const Text("Voir mes demandes"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      )
          : null,
    );
  }

  // -------------------------------------------------------------------------
  // Étape 0
  // -------------------------------------------------------------------------
  Widget _buildFirstStep() {
    return _buildStepContent(
      "Informations du produit",
      [
        _buildTextField(nomArticleCtrl, "Nom du bien ou article recherché", Icons.shopping_cart, isRequired: true),
        _buildTextField(boutiqueCtrl, "Nom de la boutique ou du vendeur ", Icons.store),
        _buildTextField(numVendeurCtrl, "Numéro du vendeur (facultatif)", Icons.phone, isNumeric: true),
        _buildTextField(prixArticleCtrl, "Prix approximatif du bien (F) ", Icons.attach_money, isNumeric: true),
        _buildTextField(nbrSouhaiteCtrl, "Nombre de tranches souhaitées", Icons.format_list_numbered, isNumeric: true),
        _buildTextField(descriptionCtrl, "Description du bien ou de l'article", Icons.description, maxLines: 3),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Étape 1
  // -------------------------------------------------------------------------
  Widget _buildSecondStep() {
    return _buildStepContent(
      "Vos informations",
      [
        _buildTextField(votreNomCtrl, "Votre nom", Icons.person),
        _buildTextField(telephoneClientCtrl, "Votre contact *", Icons.phone_android, isNumeric: true, length: 8, isRequired: true),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Étape 2 : Confirmation
  // -------------------------------------------------------------------------
  Widget _buildConfirmationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.orange, size: 80),
          const SizedBox(height: 10),
          const Text("Confirmation", textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 10),
          const Text(
            "Vérifiez vos informations avant de valider.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          ElevatedButton.icon(
            onPressed: _previousPage,
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text("Modifier"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Étape 3 : Paiement (Orange / Moov)
  // -------------------------------------------------------------------------
  Widget _buildPaymentStep() {
    double paymentAmount = getPaymentAmount();
    int montantUssd = paymentAmount.floor(); // 🔁 utilisé partout
    String ussdCode = '*144*4*6*$montantUssd#';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Sélectionnez votre opérateur",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
          const SizedBox(height: 10),
          _buildProviderChoice(),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Text("Payer ${paymentAmount.toStringAsFixed(0)} FCFA", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text("Numéro de téléphone de paiement", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextFormField(
            controller: telephoneClientCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Ex: 70000000",
              filled: true,
              border: OutlineInputBorder(),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
            validator: (val) {
              if (val == null || val.isEmpty) {
                return "Veuillez entrer votre numéro de téléphone";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          if (_selectedProvider == "orange money") ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Code de validation (OTP)", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => UssdHelper.launchUssd(context: context, ussdCode: ussdCode),
                  child: const Text("Générer le code OTP", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            TextFormField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Entrez le code OTP Orange",
                filled: true,
                border: OutlineInputBorder(),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return "Veuillez entrer le code OTP (ou le générer)";
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
          ],

          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _validatePayment,
                  style: TextButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check_circle_outline),
                      SizedBox(width: 5),
                      Text("VALIDER"),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.cancel),
                      SizedBox(width: 5),
                      Text("ANNULER"),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: ussdCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Code USSD copié dans le presse-papier")),
                );
              },
              icon: const Icon(Icons.copy, color: Colors.blue),
              label: const Text("Copier le code USSD", style: TextStyle(color: Colors.blue)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16.0),
                side: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildProviderChoice() {
    return SizedBox(
      height: 50,
      child: Row(
        children: List.generate(_providers.length, (index) {
          final slug = _providers[index]['slug']!;
          final libelle = _providers[index]['libelle']!;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(libelle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              avatar: CircleAvatar(
                backgroundColor: Colors.white,
                child: Image.asset(_providers[index]['logo']!),
              ),
              backgroundColor: Colors.blueGrey,
              selectedColor: Colors.teal,
              selected: _selectedProvider == slug,
              onSelected: (value) {
                setState(() {
                  _selectedProvider = slug;
                });
              },
            ),
          );
        }),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Helpers UI
  // -------------------------------------------------------------------------
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isRequired = false, bool isNumeric = false, int? length, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumeric
            ? [
          FilteringTextInputFormatter.digitsOnly,
          if (length != null) LengthLimitingTextInputFormatter(length),
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

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
        ],
      ),
    );
  }
}
