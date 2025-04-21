import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../../controller/tontine_details_controller.dart';
import '../../../data/models/body/RetraitBody.dart';
import '../../../data/models/tontine_model.dart';
import '../../../presentation/widgets/custom_loader.dart';
import '../../../presentation/widgets/custom_snackbar.dart';

class IndivRetirerPage extends StatefulWidget {
  final Tontine tontine;

  const IndivRetirerPage({Key? key, required this.tontine}) : super(key: key);

  @override
  State<IndivRetirerPage> createState() => _IndivRetirerPageState();
}

class _IndivRetirerPageState extends State<IndivRetirerPage> {
  final detailController = Get.find<TontineDetailsController>();

  // Champs de texte
  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _numeroPaiementController = TextEditingController();
  final TextEditingController _nomCompteMobileController = TextEditingController();

  // Clé pour le formulaire
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialise le champ montant avec le total cotisé moins le montant retiré
    _montantController.text = (widget.tontine.totalMontantCotise - (widget.tontine.montantRetire ?? 0)).toString();
  }

  // Boîte de dialogue de confirmation
  Future<void> _showConfirmationDialog(BuildContext context) async {
    final bool isPenaltyApplicable = widget.tontine.totalMontantCotise! < (widget.tontine.montantTotalTontine ?? 0);
    final bool isBlockedAndNotCompleted = (widget.tontine.isBlocked == true) &&
        (widget.tontine.totalMontantCotise! < (widget.tontine.montantTotalTontine ?? 0));

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        if (isBlockedAndNotCompleted)
          return AlertDialog(
            title: const Text("Retrait impossible", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            content: const Text(
              "Ce compte est bloqué. Le retrait ne sera possible qu'une fois tous les paiements terminés.",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              )
            ],
          );

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
              // Avertissement en cas de pénalité
              if (isPenaltyApplicable) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 32,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Votre épargne n’est pas terminée. Si vous retirez maintenant, une pénalité de 10% sera appliquée.",
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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

  // Envoi du formulaire avec vérification que le montant disponible est > 0
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final int montantDisponible = int.parse(_montantController.text.trim());

      // Vérification que le montant disponible n'est pas nul
      if (montantDisponible <= 0) {
        showCustomSnackBar(context, "Retrait impossible : Votre compte affiche 0 FCFA.");
        return;
      }

      FocusScope.of(context).unfocus();
      Get.dialog(CustomerLoader(), barrierDismissible: false);

      final body = RetraitBody(
        tontine: widget.tontine.id,
        montant: montantDisponible,
        operateur: detailController.selectedProvider,
        numero: _numeroPaiementController.text.trim(),
        nomCompte: _nomCompteMobileController.text.trim(),
      );

      detailController.sendCreditRequest(body).then((result) async {
        Get.back(); // Ferme le loader
        if (result.isSuccess) {
          // Met à jour le montant retiré côté serveur avant de vider les champs
          await updateMontantRetire(widget.tontine.id!, montantDisponible);

          _numeroPaiementController.clear();
          _montantController.clear();
          _nomCompteMobileController.clear();

          Get.offNamed('/tontineDetails', arguments: widget.tontine);

          Get.snackbar(
            "Succès",
            "Votre demande de retrait a été envoyée. Vous recevrez un dépôt de FARIS BUSINESS GROUP dans moins de 10 minutes.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            duration: const Duration(seconds: 10),
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

  // Fonction pour mettre à jour le montant retiré sur le serveur
  Future<void> updateMontantRetire(int tontineId, int montant) async {
    final response = await http.post(
      Uri.parse("https://apps.farisbusinessgroup.com/api/update_retrait.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"tontine_id": tontineId, "montant": montant}),
    );

    try {
      final json = jsonDecode(response.body);
      if (json['status'] != true) {
        print("Erreur lors de la mise à jour du montant retiré : ${json['message']}");
      }
    } catch (e) {
      print("Erreur lors du décodage du JSON : $e");
    }
  }

  // Widget champ ombré
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
        color: Colors.white, // Fond blanc
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Formulaire de retrait",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
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
                // Montant total cotisé (affiché comme montant disponible)
                Text(
                  "Montant total cotisé",
                  style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildShadowedField(
                  controller: _montantController,
                  validator: (value) => null, // readOnly donc pas de validation
                  readOnly: true,
                ),
                const SizedBox(height: 20),

                // Moyen de paiement
                Text(
                  "Choisir le moyen de paiement",
                  style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
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

                // Numéro pour dépot mobile money
                Text(
                  "Numéro pour dépot mobile money",
                  style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
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
                  "Assurez-vous de l'exactitude du numéro, car le montant est non remboursable en cas d'erreur de saisi.",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
                const SizedBox(height: 20),

                // Nom figurant sur le compte Mobile Money
                Text(
                  "Nom figurant sur le compte Mobile Money (*)",
                  style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
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

                // Condition : Au moins 3 cotisations pour pouvoir retirer
                if ((detailController.cotisations?.length ?? 0) >= 3)
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
                  )
                else
                  Center(
                    child: Text(
                      "Vous devez cotiser au moins 3 fois avant de pouvoir effectuer un retrait.",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
