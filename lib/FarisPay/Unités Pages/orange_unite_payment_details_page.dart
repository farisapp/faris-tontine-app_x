import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/ussd_helper.dart';

class OrangeUnitePaymentDetailsPage extends StatefulWidget {
  final String offerTitle;
  final String description;
  final String validity;
  final String phoneNumber;
  final String reference;
  final String? predefinedAmount; // Montant prédéfini optionnel

  OrangeUnitePaymentDetailsPage({
    Key? key,
    required this.offerTitle,
    required this.description,
    required this.validity,
    required this.phoneNumber,
    required this.reference,
    this.predefinedAmount, // Initialiser le montant prédéfini
  }) : super(key: key);

  @override
  _OrangeUnitePaymentDetailsPageState createState() =>
      _OrangeUnitePaymentDetailsPageState();
}

class _OrangeUnitePaymentDetailsPageState
    extends State<OrangeUnitePaymentDetailsPage> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _amountController =
  TextEditingController(text: "1025"); // Montant par défaut
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? phoneErrorMessage;

  String _selectedPaymentMethod = "Orange Money"; // Valeur par défaut

// Liste des préfixes valides
  final List<String> orangePrefixes = ["05", "06", "07", "54", "55", "56", "57", "64", "65", "66", "67", "74", "75", "76", "77"];

  @override
  void initState() {
    super.initState();
    _phoneNumberController.text = widget.phoneNumber; // Initialiser le numéro
    _amountController.text = widget.predefinedAmount ?? ""; // Pré-remplir le montant s'il existe
    // Ajouter un listener pour la validation en temps réel
    _phoneNumberController.addListener(() {
      final input = _phoneNumberController.text.trim();
      if (input.isNotEmpty) {
        setState(() {
          if (_isOrangeNumber(input)) {
            phoneErrorMessage = null; // Pas d'erreur
          } else {
            phoneErrorMessage =
            "Le numéro saisi n'est pas un numéro Orange. Veuillez vérifier.";
          }
        });
      } else {
        setState(() {
          phoneErrorMessage = null; // Réinitialiser si vide
        });
      }
    });
  }

  // Vérifie si le numéro appartient à Orange
  bool _isOrangeNumber(String phoneNumber) {
    if (phoneNumber.length < 2) return false;
    final prefix = phoneNumber.substring(0, 2);
    return orangePrefixes.contains(prefix);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Achat d'unités Orange",
          style: TextStyle(color: Colors.black),
        ),
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
              // Détails de l'offre
              Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/orange_money.png",
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              "${widget.offerTitle}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.description,
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),

              // Montant (modifiable)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Montant",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "Entrez le montant",
                        border: OutlineInputBorder(),
                        suffixText: "FCFA",
                        suffixStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer un montant.";
                        }
                        final amount = int.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return "Veuillez entrer un montant valide.";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              // Numéro de téléphone
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Numéro du bénéficiaire",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                      decoration: InputDecoration(
                        hintText: "Entrez un numéro de téléphone",
                        border: const OutlineInputBorder(),
                        errorText: phoneErrorMessage,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer un numéro de téléphone.";
                        }
                        if (value.length != 8) {
                          return "Le numéro doit contenir exactement 8 chiffres.";
                        }
                        if (!_isOrangeNumber(value.trim())) {
                          return "Le numéro saisi n'est pas un numéro Orange. Veuillez vérifier.";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              // Méthode de paiement
              // Méthode de paiement
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Choix du mode de paiement",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedPaymentMethod,
                      items: [
                        DropdownMenuItem(
                          value: "Moov Money",
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/images/moov_money.png", // Logo de Moov Money
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text("Moov Money"),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Orange Money",
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/images/orange_money.png", // Logo d'Orange Money
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text("Orange Money"),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        children: [
                          const TextSpan(text: "Veuillez lancer l'appel avec votre carte sim "),
                          TextSpan(
                            text: _selectedPaymentMethod == "Orange Money" ? "Orange" : "Moov",
                            style: TextStyle(
                              color: _selectedPaymentMethod == "Orange Money"
                                  ? Colors.orange
                                  : Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Bouton Valider
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _executeUssd();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.all(16.0),
                  ),
                  child: const Text(
                    "Valider",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16), // Espacement entre les deux boutons

              // Bouton Copier le code USSD
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      String phoneNumber = _phoneNumberController.text.trim();
                      String amount = _amountController.text.trim();
                      String reference;

                      if (_selectedPaymentMethod == "Moov Money") {
                        reference = "116$phoneNumber";
                      } else if (_selectedPaymentMethod == "Orange Money") {
                        reference = "116$phoneNumber";
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Méthode de paiement invalide.")),
                        );
                        return;
                      }

                      String ussdCode;
                      if (_selectedPaymentMethod == "Moov Money") {
                        ussdCode = '*555*4*7*5*1*$reference*$amount#';
                      } else if (_selectedPaymentMethod == "Orange Money") {
                        ussdCode = '*144*4*7*4068903*$reference*$amount#';
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Méthode de paiement invalide.")),
                        );
                        return;
                      }

                      Clipboard.setData(ClipboardData(text: ussdCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Code USSD copié dans le presse-papier")),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy, color: Colors.orange),
                  label: const Text(
                    "Copier le code USSD",
                    style: TextStyle(color: Colors.orange),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16.0),
                    side: BorderSide.none, // Supprime le contour
                  ),
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                "Nous déclinons toute responsabilité en cas de modification de l'offre promotionnelle par l'opérateur",
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  /// Fonction pour exécuter le code USSD
  void _executeUssd() {
    String phoneNumber = _phoneNumberController.text.trim();
    String amount = _amountController.text.trim();

    if (phoneNumber.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs.")),
      );
      return;
    }

    String reference = "116$phoneNumber";

    String ussdCode;
    if (_selectedPaymentMethod == "Moov Money") {
      ussdCode = '*555*4*7*5*1*$reference*$amount#';
    } else if (_selectedPaymentMethod == "Orange Money") {
      ussdCode = '*144*4*7*4068903*$reference*$amount#';
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Méthode de paiement invalide.")),
      );
      return;
    }

    UssdHelper.showUssdDialog(context, ussdCode);
  }

}
