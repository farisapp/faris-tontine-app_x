import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../controller/tontine_details_controller.dart';
import '../../../data/models/body/RetraitBody.dart';
import '../../../data/models/tontine_model.dart';
import '../../../presentation/widgets/custom_loader.dart';
import '../../../presentation/widgets/custom_snackbar.dart';
import 'package:faris/controller/user_controller.dart';

class ColRetirerPage extends StatefulWidget {
  final Tontine tontine;

  const ColRetirerPage({Key? key, required this.tontine}) : super(key: key);

  @override
  State<ColRetirerPage> createState() => _ColRetirerPageState();
}

class _ColRetirerPageState extends State<ColRetirerPage> {
  final detailController = Get.find<TontineDetailsController>();

  // Contrôleurs de texte pour le formulaire
  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _numeroPaiementController = TextEditingController();
  final TextEditingController _nomCompteMobileController = TextEditingController();

  // Clé du formulaire
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Remplir le champ montant avec le total cotisé de la tontine
    _montantController.text =
        (widget.tontine.totalMontantCotise - (widget.tontine.montantRetire ?? 0)).toString();

    // Vérifier les membres non cotisés
    detailController.checkMembersPaidFirstPeriod();

    // Afficher l'avertissement après la première frame si certains membres n'ont pas encore cotisé
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (detailController.membresNonCotises.isNotEmpty) {
        bool? proceed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                "Tout le monde n'a pas encore cotisé",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${detailController.membresNonCotises.length} membre(s) n'ont pas encore cotisé :",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 100,
                    child: SingleChildScrollView(
                      child: Text(
                        detailController.membresNonCotises
                            .map((m) => "• ${m.displayName}")
                            .join("\n"),
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Voulez-vous continuer avec la demande de retrait ?",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("ANNULER", style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("CONTINUER", style: TextStyle(color: Colors.green)),
                ),
              ],
            );
          },
        );
        if (proceed != true) {
          Navigator.of(context).pop(); // Ferme la page si l'utilisateur annule
        }
      }
    });
  }

  // Boîte de dialogue de confirmation
  Future<void> _showConfirmationDialog(BuildContext context) async {
    final bool isPenaltyApplicable =
        widget.tontine.totalMontantCotise! < widget.tontine.montantTotalTontine;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Confirmation",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Êtes-vous sûr(e) de vouloir envoyer la demande de retrait ?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
                ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bouton Annuler
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "ANNULER",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                // Bouton Confirmer
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _submitForm();
                    },
                    child: const Text(
                      "CONFIRMER",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> updateMontantRetire(int tontineId, int montant) async {
    final response = await http.post(
      Uri.parse("https://apps.farisbusinessgroup.com/api/update_retrait.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"tontine_id": tontineId, "montant": montant}),
    );

    final json = jsonDecode(response.body);
    if (json['status'] != true) {
      print("Erreur lors de la mise à jour du montant retiré : ${json['message']}");
    }
  }

  // Envoi du formulaire de retrait
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      int paiementsEffectues = (widget.tontine.totalMontantCotise - (widget.tontine.montantRetire ?? 0));

      // Vérifier si le montant des paiements effectués est inférieur ou égal à zéro
      if (paiementsEffectues <= 0) {
        showCustomSnackBar(
          context,
          "Retrait impossible : Votre compte affiche 0 FCFA.",
        );
        return;
      }
      // Exécution du retrait
      FocusScope.of(context).unfocus();
      Get.dialog(CustomerLoader(), barrierDismissible: false);

      final body = RetraitBody(
        tontine: widget.tontine.id,
        montant: paiementsEffectues,
        operateur: detailController.selectedProvider,
        numero: _numeroPaiementController.text.trim(),
        nomCompte: _nomCompteMobileController.text.trim(),
      );

      detailController.sendCreditRequest(body).then((result) async {
        Get.back(); // Ferme le loader

        if (result.isSuccess) {
          _numeroPaiementController.clear();
          _montantController.clear();
          _nomCompteMobileController.clear();

          // 🔁 Mise à jour du montant retiré côté serveur
          await updateMontantRetire(widget.tontine.id!, paiementsEffectues);

          Get.offAllNamed('/ColTontinePage');

          Get.snackbar(
            "Succès",
            "Votre demande de retrait a été envoyée. Vous recevrez un dépôt dans moins de 10 minutes.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            duration: const Duration(seconds: 7),
          );
        } else {
          showCustomSnackBar(context, result.message);
        }
      }).catchError((error) {
        Get.back();
        showCustomSnackBar(context, "Une erreur est survenue : $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Récupération du numéro de téléphone de l'utilisateur connecté via UserController
    final String currentUserPhone =
        Get.find<UserController>().userInfo?.telephone?.trim() ?? "";

    // Récupération et normalisation du numéro du créateur de la tontine
    final String creatorPhone =
        widget.tontine.createur?.telephone?.trim() ?? "";

    print("Creator phone: '$creatorPhone' - Current user phone: '$currentUserPhone'");
    print("Tontine type: '${widget.tontine.type}'");

    // Pour une tontine individuelle, seul le créateur peut effectuer le retrait.
    if ((widget.tontine.type?.toUpperCase() ?? "") != "GROUPE" &&
        creatorPhone != currentUserPhone) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Accès refusé",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.orange,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        body: const Center(
          child: Text(
            "C'est l'organisateur de l'épargne collective qui effectue le retrait. Il renseigne le numéro qui doit recevoir le dépôt",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
      );
    }

    // Si la vérification est validée, on affiche le formulaire de retrait.
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Formulaire de retrait",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Montant total cotisé",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildShadowedField(
                  controller: _montantController,
                  validator: (value) => null,
                  readOnly: true,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Choisir le moyen de paiement",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                GetBuilder<TontineDetailsController>(builder: (logic) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: logic.selectedProvider,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: logic.providers!.map((String provider) {
                        Widget icon;
                        if (provider.toLowerCase().contains("orange")) {
                          icon = Image.asset(
                            "assets/images/orange_money.png",
                            width: 40,
                            height: 40,
                          );
                        } else if (provider.toLowerCase().contains("moov")) {
                          icon = Image.asset(
                            "assets/images/moov_money.png",
                            width: 24,
                            height: 24,
                          );
                        } else {
                          icon = const Icon(Icons.payment, color: Colors.black);
                        }
                        return DropdownMenuItem(
                          value: provider,
                          child: Row(
                            children: [
                              icon,
                              const SizedBox(width: 8),
                              Text(provider, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          logic.setSelectedProvider(newValue);
                        }
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Sélectionnez un moyen de paiement";
                        }
                        return null;
                      },
                    ),
                  );
                }),
                const SizedBox(height: 20),
                const Text(
                  "Numéro pour dépot mobile money",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildShadowedField(
                  controller: _numeroPaiementController,
                  hintText: "Ex: 76757472",
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Champ obligatoire";
                    }
                    if (!RegExp(r'^\d{8}$').hasMatch(value.trim())) {
                      return "Le numéro doit contenir 8 chiffres";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 5),
                const Text(
                  "Assurez-vous de l'exactitude du numéro, car le montant est non remboursable en cas d'erreur de saisie.",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Nom figurant sur le compte Mobile Money (*)",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildShadowedField(
                  controller: _nomCompteMobileController,
                  hintText: "Ex: KONE MAMADOU",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Champ obligatoire";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showConfirmationDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("RETIRER"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget générique pour un champ avec effet d'ombrage
  Widget _buildShadowedField({
    required TextEditingController controller,
    required String? Function(String?)? validator,
    bool readOnly = false,
    TextInputType? keyboardType,
    String hintText = '',
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
        ),
        validator: validator,
      ),
    );
  }
}