import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/ussd_helper.dart';

class MoovPaymentDetailsPage extends StatefulWidget {
  final String offerTitle;
  final String description;
  final String price;
  final String validity;
  final String phoneNumber;
  final String reference;

  MoovPaymentDetailsPage({
    Key? key,
    required this.offerTitle,
    required this.description,
    required this.price,
    required this.validity,
    required this.phoneNumber,
    required this.reference,
  }) : super(key: key);

  @override
  _MoovPaymentDetailsPageState createState() => _MoovPaymentDetailsPageState();
}

class _MoovPaymentDetailsPageState extends State<MoovPaymentDetailsPage> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? phoneErrorMessage;

  String _selectedPaymentMethod = "Orange Money"; // Default value

  // Liste des préfixes valides pour Moov
  final List<String> moovPrefixes = [
    "50", "51", "52", "53", "60", "61", "62", "63", "70", "71", "72", "73"
  ];

  // Liste des modes de paiement avec logos
  final List<Map<String, dynamic>> paymentMethods = [
    {
      "name": "Moov Money",
      "logo": "assets/images/moov_money.png",
    },
    {
      "name": "Orange Money",
      "logo": "assets/images/orange_money.png",
    },
  ];

  @override
  void initState() {
    super.initState();
    _phoneNumberController.text = widget.phoneNumber; // Initialiser le numéro par défaut

    // Ajout d'un listener pour la validation en temps réel
    _phoneNumberController.addListener(() {
      final input = _phoneNumberController.text.trim();
      if (input.isNotEmpty) {
        setState(() {
          if (_isMoovNumber(input)) {
            phoneErrorMessage = null;
          } else {
            phoneErrorMessage =
            "Le numéro saisi n'est pas un numéro Moov. Veuillez vérifier.";
          }
        });
      } else {
        setState(() {
          phoneErrorMessage = null;
        });
      }
    });
  }

  // Vérifie si le numéro appartient à Moov
  bool _isMoovNumber(String phoneNumber) {
    if (phoneNumber.length < 2) return false;
    final prefix = phoneNumber.substring(0, 2);
    return moovPrefixes.contains(prefix);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Achat de forfaits internet Moov",
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
                            "assets/images/moov_money.png",
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              widget.offerTitle,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
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
              // Montant (non modifiable)
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
                      initialValue: widget.price,
                      readOnly: true,
                      decoration: InputDecoration(
                        suffixText: "FCFA",
                        suffixStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              // Numéro de téléphone (modifiable)
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
                        errorStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          height: 1.5,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer un numéro de téléphone.";
                        }
                        if (value.length != 8) {
                          return "Le numéro doit contenir exactement 8 chiffres.";
                        }
                        if (!_isMoovNumber(value.trim())) {
                          return "Le numéro saisi n'est pas un numéro Moov. Veuillez vérifier.";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              // Méthode de paiement (Dropdown avec logos)
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
                      items: paymentMethods
                          .map((method) => DropdownMenuItem<String>(
                        value: method["name"],
                        child: Row(
                          children: [
                            Image.asset(
                              method["logo"],
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(method["name"]),
                          ],
                        ),
                      ))
                          .toList(),
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
                          const TextSpan(
                              text: "Veuillez lancer l'appel avec votre carte sim "),
                          TextSpan(
                            text: _selectedPaymentMethod == "Orange Money"
                                ? "Orange"
                                : "Moov",
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

              const SizedBox(height: 16),
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
                    backgroundColor: Colors.purple,
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
                    String phoneNumber = _phoneNumberController.text.trim();
                    String amount = widget.price;
                    String reference;

                    if (widget.reference == '2055') {
                      reference = "333$phoneNumber";
                    } else {
                      reference = "115$phoneNumber";
                    }

                    String ussdCode = _selectedPaymentMethod == "Moov Money"
                        ? '*555*4*7*5*1*$reference*$amount#'
                        : '*144*4*7*4068903*$reference*$amount#';

                    Clipboard.setData(ClipboardData(text: ussdCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Code USSD copié dans le presse-papier")),
                    );
                  },
                  icon: const Icon(Icons.copy, color: Colors.purple),
                  label: const Text(
                    "Copier le code USSD",
                    style: TextStyle(color: Colors.purple),
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

  /// Exécute l'appel USSD ou affiche la fenêtre bonus si c'est samedi et que le forfait contient "Bonus"
  void _executeUssd() {
    String phoneNumber = _phoneNumberController.text.trim();
    String amount = widget.price;

    if (phoneNumber.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs.")),
      );
      return;
    }

    // Cas spécial pour la référence 2055
    if (widget.reference == '2055') {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: Colors.white,
            title: Text(
              "Information",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.purple,
                fontSize: 18,
              ),
            ),
            content: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                children: [
                  TextSpan(
                    text:
                    "Vous allez recevoir des unités sur votre numéro $phoneNumber, tapez ensuite ",
                  ),
                  TextSpan(
                    text: "*146*17#",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text:
                    " pour profiter de 3 Gigas à 990F pour Whatsapp et Facebook.",
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer la fenêtre
                  _callUssd(); // Lancer l'appel USSD
                },
                child: Text(
                  "Continuer",
                  style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      // Pour les autres références, conserver la logique existante
      if (DateTime.now().weekday == 6 && widget.offerTitle.contains("Bonus")) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              backgroundColor: Colors.white,
              title: Text(
                "Information",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                  fontSize: 18,
                ),
              ),
              content: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: "Comme c'est Samedi, vous allez recevoir des unités sur votre numéro $phoneNumber, tapez ensuite ",
                    ),
                    TextSpan(
                      text: "*146*1002#",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: " pour avoir 100% de bonus internet Moov!",
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Fermer la fenêtre
                    _callUssd(); // Lancer l'appel USSD
                  },
                  child: Text(
                    "Continuer",
                    style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        _callUssd();
      }
    }
  }

  /// Fonction pour générer la référence, le code USSD et lancer l'appel
  void _callUssd() {
    String phoneNumber = _phoneNumberController.text.trim();
    String amount = widget.price;

    String reference;
    if (widget.reference == '2055') {
      reference = "333$phoneNumber";
    } else {
      reference = "115$phoneNumber";
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

    // Appel uniforme Android / iOS
    UssdHelper.showUssdDialog(context, ussdCode);
  }
}