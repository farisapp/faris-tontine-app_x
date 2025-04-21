import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'payment_page.dart'; // Import de la page de paiement

class VisaUbaRechargePage extends StatefulWidget {
  const VisaUbaRechargePage({Key? key}) : super(key: key);

  @override
  State<VisaUbaRechargePage> createState() => _VisaUbaRechargePageState();
}

class _VisaUbaRechargePageState extends State<VisaUbaRechargePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _numeroClientController = TextEditingController();
  final TextEditingController _dernierChiffresController = TextEditingController();

  // Déclaration des FocusNode pour surveiller le focus de chaque champ
  final FocusNode _numeroClientFocusNode = FocusNode();
  final FocusNode _dernierChiffresFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Ajout de listeners pour mettre à jour l'UI en cas de changement de focus
    _numeroClientFocusNode.addListener(() {
      setState(() {});
    });
    _dernierChiffresFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _montantController.dispose();
    _numeroClientController.dispose();
    _dernierChiffresController.dispose();
    _numeroClientFocusNode.dispose();
    _dernierChiffresFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recharge VISA UBA", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🟢 Montant à recharger (validation : montant >= 1000 F)
              _buildTextField(
                controller: _montantController,
                label: "Montant à recharger",
                icon: Icons.money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer un montant.";
                  }
                  double? montant = double.tryParse(value);
                  if (montant == null || montant < 1000) {
                    return "Le montant doit être d'au moins 1000 F.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // 🟢 Numéro client (10 chiffres)
              _buildTextField(
                controller: _numeroClientController,
                focusNode: _numeroClientFocusNode,
                label: "Numéro client (10 chiffres)",
                icon: Icons.account_circle,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer votre numéro client.";
                  }
                  if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                    return "Le numéro client doit contenir exactement 10 chiffres.";
                  }
                  return null;
                },
                inputFormatters: [LengthLimitingTextInputFormatter(10)],
              ),
              // Affichage de l'image annotée pour le numéro client uniquement si le champ est en focus
              if (_numeroClientFocusNode.hasFocus) ...[
                const SizedBox(height: 10),
                Image.asset('assets/images/annotated_visa_front.png'),
                const SizedBox(height: 10),
              ],

              // 🟢 4 derniers chiffres de la carte
              _buildTextField(
                controller: _dernierChiffresController,
                focusNode: _dernierChiffresFocusNode,
                label: "4 derniers chiffres de la carte",
                icon: Icons.credit_card,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer les 4 derniers chiffres.";
                  }
                  if (!RegExp(r'^\d{4}$').hasMatch(value)) {
                    return "Ce champ doit contenir exactement 4 chiffres.";
                  }
                  return null;
                },
                inputFormatters: [LengthLimitingTextInputFormatter(4)],
              ),
              // Affichage de l'image annotée pour les 4 derniers chiffres uniquement si le champ est en focus
              if (_dernierChiffresFocusNode.hasFocus) ...[
                const SizedBox(height: 10),
                Image.asset('assets/images/annotated_visa_back.png'),
                const SizedBox(height: 10),
              ],

              const SizedBox(height: 20),
              // 🟢 Bouton de validation
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _validerRecharge,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.all(16.0),
                  ),
                  child: const Text(
                    "Valider et payer",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Création des champs de saisie avec leur validation et possibilité d'utiliser un FocusNode
  Widget _buildTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.orange),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: validator,
      inputFormatters: inputFormatters,
    );
  }

  // Vérification du formulaire et redirection vers PaymentPage si validation réussie
  void _validerRecharge() {
    if (_formKey.currentState!.validate()) {
      Get.to(() => PaymentPage(
        numero: "${_numeroClientController.text}-${_dernierChiffresController.text}",
        montant: _montantController.text,
        service: "VISA UBA",
        dernierChiffreCarte: _dernierChiffresController.text,
      ));
    }
  }
}
