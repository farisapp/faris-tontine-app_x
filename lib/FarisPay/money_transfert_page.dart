import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

import '../utils/ussd_helper.dart';

class MoneyTransferPage extends StatefulWidget {
  const MoneyTransferPage({Key? key}) : super(key: key);

  @override
  _MoneyTransferPageState createState() => _MoneyTransferPageState();
}

class _MoneyTransferPageState extends State<MoneyTransferPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  String selectedOperator = "Orange Money"; // Opérateur de destination par défaut
  String selectedPaymentMethod = "Orange Money"; // Moyen de paiement par défaut
  String phoneErrorMessage = ""; // Message d'erreur pour le numéro
  String amountErrorMessage = ""; // Message d'erreur pour le montant
  double totalAmount = 0.0; // Montant total (montant + frais)

  // Liste des opérateurs de destination
  final List<Map<String, dynamic>> operators = [
    {"name": "Orange Money", "logo": "assets/images/orange_money.png"},
    {"name": "Moov Money", "logo": "assets/images/moov_money.png"},
    {"name": "Telecel Money", "logo": "assets/images/telecel.png"},
  ];

  // Liste des moyens de paiement
  final List<Map<String, dynamic>> paymentMethods = [
    {"name": "Orange Money", "logo": "assets/images/orange_money.png"},
    {"name": "Moov Money", "logo": "assets/images/moov_money.png"},
  ];

  // Références pour les opérateurs de destination
  final Map<String, String> operatorReferences = {
    "Orange Money": "111",
    "Moov Money": "112",
    "Telecel Money": "113",
  };

  // Codes USSD par moyen de paiement
  final Map<String, String> paymentUssdCodes = {
    "Orange Money": "*144*4*7*4068903*{reference}{number}*{amount}#",
    "Moov Money": "*555*4*7*5*1*{reference}{number}*{amount}#",
  };

  // Préfixes valides pour chaque opérateur
  final Map<String, List<String>> operatorPrefixes = {
    "Orange Money": [
      "05",
      "06",
      "07",
      "54",
      "55",
      "56",
      "57",
      "64",
      "65",
      "66",
      "67",
      "74",
      "75",
      "76",
      "77"
    ],
    "Moov Money": [
      "50",
      "51",
      "52",
      "53",
      "60",
      "61",
      "62",
      "63",
      "70",
      "71",
      "72",
      "73"
    ],
    "Telecel Money": ["58", "68", "69", "78", "79"],
  };

  // Couleurs des bordures et du bouton selon l'opérateur
  final Map<String, Color> operatorColors = {
    "Orange Money": Colors.orange,
    "Moov Money": Colors.purple,
    "Telecel Money": Colors.blue,
  };

  @override
  Widget build(BuildContext context) {
    Color selectedColor = operatorColors[selectedOperator] ?? Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Transfert Mobile Money",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Montant à envoyer
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                calculateTotalAmount(value);
              },
              decoration: InputDecoration(
                labelText: "Montant à transférer",
                prefixIcon: Icon(Icons.money, color: selectedColor),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: selectedColor, width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: selectedColor, width: 2.0),
                ),
              ),
            ),
            // Message d'erreur pour le montant
            if (amountErrorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  amountErrorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),
            // Affichage du total si le montant est valide
            if (totalAmount > 0 && amountErrorMessage.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Total à payer frais inclus: ${totalAmount.toStringAsFixed(0)} F",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: selectedColor,
                  ),
                ),
              ),
            const SizedBox(height: 30),

            // Opérateur destinataire
            const Text(
              "Sélectionner l'opérateur de destination",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
                color: Colors.deepOrangeAccent,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: operators.map((operator) {
                final bool isSelected = selectedOperator == operator["name"];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedOperator = operator["name"];
                      phoneErrorMessage = "";
                      validatePhoneNumber(_phoneNumberController.text);
                    });
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        operator["logo"],
                        width: 50,
                        height: 50,
                      ),
                      Text(
                        operator["name"],
                        style: TextStyle(
                          color: isSelected ? Colors.red : Colors.grey,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // Numéro du bénéficiaire
            TextField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ],
              onChanged: (value) {
                validatePhoneNumber(value);
              },
              decoration: InputDecoration(
                labelText: "N° du bénéficiaire",
                prefixText: "+226 ",
                suffixIcon: Icon(Icons.contact_phone, color: selectedColor),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: selectedColor, width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: selectedColor, width: 2.0),
                ),
              ),
            ),
            if (phoneErrorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  phoneErrorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                  ),
                ),
              ),
            const SizedBox(height: 30),

            // Choix du moyen de paiement
            const Text(
              "Choisir le compte de paiement",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedPaymentMethod,
              items: paymentMethods.map((method) {
                return DropdownMenuItem<String>(
                  value: method["name"],
                  child: Row(
                    children: [
                      Image.asset(
                        method["logo"],
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 8),
                      Text(method["name"]),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value!;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  const TextSpan(text: "Veuillez lancer l'appel avec votre carte sim "),
                  TextSpan(
                    text: selectedPaymentMethod == "Orange Money" ? "Orange" : "Moov",
                    style: TextStyle(
                      color: selectedPaymentMethod == "Orange Money" ? Colors.orange : Colors.purple,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Bouton Envoyer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _validateAndTransfer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedColor,
                  padding: const EdgeInsets.all(16.0),
                ),
                child: const Text(
                  "Envoyer",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bouton Copier le code USSD
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  final String phoneNumber = _phoneNumberController.text.trim();
                  final String amount = _amountController.text.trim();

                  if (phoneNumber.isEmpty || amount.isEmpty) {
                    _showSnackBar("Veuillez remplir tous les champs avant de copier le code.");
                    return;
                  }

                  final String localPhoneNumber = phoneNumber.startsWith("+226")
                      ? phoneNumber.substring(4)
                      : phoneNumber;

                  final String? ussdTemplate = paymentUssdCodes[selectedPaymentMethod];
                  final String? reference = operatorReferences[selectedOperator];

                  if (ussdTemplate == null || reference == null) {
                    _showSnackBar("Erreur de configuration.");
                    return;
                  }

                  final String ussdCode = ussdTemplate
                      .replaceAll("{number}", localPhoneNumber)
                      .replaceAll("{amount}", totalAmount.toStringAsFixed(0))
                      .replaceAll("{reference}", reference);

                  Clipboard.setData(ClipboardData(text: ussdCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Code USSD copié dans le presse-papier")),
                  );
                },
                icon: const Icon(Icons.copy, color: Colors.blue),
                label: const Text(
                  "Copier le code USSD",
                  style: TextStyle(color: Colors.blue),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                  side: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Nous contacter sur le numéro +22674249090 (Whatsapp) si vous ne recevez pas votre transfert à temps",
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
    );
  }

  void calculateTotalAmount(String amount) {
    if (amount.isEmpty || double.tryParse(amount) == null) {
      setState(() {
        totalAmount = 0.0;
        amountErrorMessage = "Veuillez entrer un montant valide.";
      });
      return;
    }

    double baseAmount = double.parse(amount);

    if (baseAmount < 200) {
      setState(() {
        amountErrorMessage = "Le montant minimum de transfert est de 200 FCFA.";
        totalAmount = 0.0;
      });
    } else {
      setState(() {
        totalAmount = (baseAmount + (baseAmount * 3.9 / 100)).ceilToDouble();
        amountErrorMessage = "";
      });
    }
  }

  void validatePhoneNumber(String phoneNumber) {
    String localPhoneNumber = phoneNumber.startsWith("+226")
        ? phoneNumber.substring(4)
        : phoneNumber;

    if (!RegExp(r'^\d{8}$').hasMatch(localPhoneNumber)) {
      setState(() {
        phoneErrorMessage = "Le numéro doit contenir 8 chiffres.";
      });
      return;
    }

    final List<String>? validPrefixes = operatorPrefixes[selectedOperator];
    if (validPrefixes == null ||
        !validPrefixes.any((prefix) => localPhoneNumber.startsWith(prefix))) {
      setState(() {
        phoneErrorMessage = "Le numéro saisi n'est pas un numéro $selectedOperator.";
      });
    } else {
      setState(() {
        phoneErrorMessage = "";
      });
    }
  }

  void _validateAndTransfer() {
    // Si une erreur de montant est présente, on affiche le message d'erreur
    if (amountErrorMessage.isNotEmpty) {
      _showSnackBar(amountErrorMessage);
      return;
    }

    // Vérification du numéro de téléphone
    if (phoneErrorMessage.isNotEmpty) {
      _showSnackBar(phoneErrorMessage);
      return;
    }

    final String amount = _amountController.text.trim();
    final String phoneNumber = _phoneNumberController.text.trim();

    if (amount.isEmpty || double.tryParse(amount) == null || double.parse(amount) <= 0) {
      _showSnackBar("Veuillez entrer un montant valide.");
      return;
    }

    double amountValue = double.parse(amount);
    if (amountValue < 100) {
      _showSnackBar("Le montant minimum de transfert est de 100 FCFA.");
      return;
    }

    final String localPhoneNumber = phoneNumber.startsWith("+226")
        ? phoneNumber.substring(4)
        : phoneNumber;
    final String? ussdTemplate = paymentUssdCodes[selectedPaymentMethod];
    final String? reference = operatorReferences[selectedOperator];

    if (ussdTemplate == null || reference == null) {
      _showSnackBar("Erreur de configuration.");
      return;
    }

    final String ussdCode = ussdTemplate
        .replaceAll("{number}", localPhoneNumber)
        .replaceAll("{amount}", totalAmount.toStringAsFixed(0))
        .replaceAll("{reference}", reference);

    _executeUssd(ussdCode);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _executeUssd(String ussdCode) {
    UssdHelper.showUssdDialog(context, ussdCode);
  }

}
