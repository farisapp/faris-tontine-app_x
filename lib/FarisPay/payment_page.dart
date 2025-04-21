import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/ussd_helper.dart';

class PaymentPage extends StatefulWidget {
  final String service; // "SONABEL" ou "VISA UBA"
  final String numero; // Numéro du compteur SONABEL ou numéro client UBA
  final String montant; // Montant à payer
  final String? dernierChiffreCarte; // Optionnel pour UBA (4 derniers chiffres)

  const PaymentPage({
    Key? key,
    required this.service,
    required this.numero,
    required this.montant,
    this.dernierChiffreCarte,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPaymentMethod = "Orange Money"; // Moyen de paiement par défaut
  double totalAmount = 0.0; // Montant total avec les frais

  // Liste des moyens de paiement
  final List<Map<String, dynamic>> paymentMethods = [
    {"name": "Orange Money", "logo": "assets/images/orange_money.png"},
    {"name": "Moov Money", "logo": "assets/images/moov_money.png"},
  ];

  // Référence 1 (fixe) selon le service
  final Map<String, String> serviceReferences = {
    "SONABEL": "333",
    "VISA UBA": "222",
  };

  // Référence 2 selon le moyen de paiement
  final Map<String, String> paymentReferences = {
    "Orange Money": "444",
    "Moov Money": "555",
  };

  // Codes USSD pour chaque moyen de paiement
  final Map<String, String> paymentUssdCodes = {
    "Orange Money": "*144*4*7*4068903*{ref1}{numero}*{amount}#",
    "Moov Money": "*555*4*7*5*1*{ref1}{numero}*{amount}#",
  };

  @override
  void initState() {
    super.initState();
    _calculateTotalAmount(widget.montant);
  }

  // Calcul des frais avec la nouvelle logique pour VISA UBA
  void _calculateTotalAmount(String amount) {
    if (amount.isEmpty || double.tryParse(amount) == null) {
      setState(() {
        totalAmount = 0.0;
      });
      return;
    }
    double baseAmount = double.parse(amount);

    if (widget.service == "VISA UBA") {
      // Le montant minimal de paiement doit être de 1000 F
      if (baseAmount < 1000) {
        baseAmount = 1000;
      }
      if (baseAmount < 50000) {
        // Frais fixe de 1690 F pour les montants de moins de 50 000 F
        totalAmount = baseAmount + 1690;
      } else if (baseAmount >= 50000 && baseAmount < 75000) {
        // 3,4 % de frais entre 50 000 F et 75 000 F
        totalAmount = baseAmount + (baseAmount * 3.4 / 100);
      } else if (baseAmount >= 75000 && baseAmount < 100000) {
        // 2,6 % de frais entre 75 000 F et 100 000 F
        totalAmount = baseAmount + (baseAmount * 2.6 / 100);
      } else {
        // 1,9 % de frais à partir de 100 000 F
        totalAmount = baseAmount + (baseAmount * 1.9 / 100);
      }
    } else {
      // Exemple de logique pour d'autres services (ici 3,4 %)
      totalAmount = baseAmount + (baseAmount * 3.4 / 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Choisir le moyen de paiement",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          // Bouton d'info en AppBar (si besoin de consulter ces informations en popup)
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Informations sur les frais UBA"),
                    content: const Text(
                      "Pour un paiement VISA UBA :\n\n"
                          "• Montant minimum : 1000 F\n"
                          "• Moins de 50 000 F : frais fixe de 1690 F\n"
                          "• Entre 50 000 F et 75 000 F : 3,4 % de frais\n"
                          "• Entre 75 000 F et 100 000 F : 2,6 % de frais\n"
                          "• À partir de 100 000 F : 1,9 % de frais",
                    ),
                    actions: [
                      TextButton(
                        child: const Text("OK"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre du paiement
            Text(
              widget.service == "SONABEL"
                  ? "Recharge CASHPOWER SONABEL"
                  : "Recharge Carte Visa UBA",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            // Affichage du numéro
            Text(
              "Numéro : ${widget.numero}",
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            // Affichage des 4 derniers chiffres pour VISA UBA si applicable
            if (widget.service == "VISA UBA" && widget.dernierChiffreCarte != null)
              Text(
                "Carte Visa UBA : **** **** **** ${widget.dernierChiffreCarte}",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
            Text(
              "Montant : ${widget.montant} F CFA",
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red),
            ),
            if (totalAmount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Total à payer frais inclus : ${totalAmount.toStringAsFixed(0)} F",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange),
                ),
              ),
            // Tableau des frais pour VISA UBA affiché sous le total
            if (widget.service == "VISA UBA")
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Barème des frais :",
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("• Moins de 50 000 F : frais fixe de 1690 F"),
                          Text("• Entre 50 000 F et 75 000 F : 3,4 % de frais"),
                          Text("• Entre 75 000 F et 100 000 F : 2,6 % de frais"),
                          Text("• À partir de 100 000 F : 1,9 % de frais"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            // Choix du moyen de paiement
            const Text("Sélectionner le compte de paiement :",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
                      const SizedBox(width: 15),
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
                labelText: "Moyen de paiement",
              ),
            ),
            const SizedBox(height: 15),
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
            const SizedBox(height: 20),
            // Bouton Payer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _executeUssd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.all(16.0),
                ),
                child: const Text(
                  "Payer",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Bouton Copier le code USSD
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  String? ussdTemplate = paymentUssdCodes[selectedPaymentMethod];
                  String? ref1 = serviceReferences[widget.service];
                  String? ref2 = paymentReferences[selectedPaymentMethod];

                  if (ussdTemplate == null || ref1 == null || ref2 == null) {
                    _showSnackBar("Erreur de configuration.");
                    return;
                  }

                  String numeroAUtiliser = widget.numero;
                  String extra = "";
                  if (widget.service == "VISA UBA" && widget.dernierChiffreCarte != null) {
                    extra = widget.dernierChiffreCarte!;
                  }

                  String ussdCode = ussdTemplate
                      .replaceAll("{ref1}", ref1)
                      .replaceAll("{numero}", numeroAUtiliser)
                      .replaceAll("{extra}", extra)
                      .replaceAll("{amount}", totalAmount.toStringAsFixed(0));

                  Clipboard.setData(ClipboardData(text: ussdCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Code USSD copié dans le presse-papier")),
                  );
                },
                icon: const Icon(Icons.copy, color: Colors.orange),
                label: const Text("Copier le code USSD", style: TextStyle(color: Colors.orange)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                  side: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _executeUssd() async {
    String? ussdTemplate = paymentUssdCodes[selectedPaymentMethod];
    String? ref1 = serviceReferences[widget.service];
    String? ref2 = paymentReferences[selectedPaymentMethod];

    if (ussdTemplate == null || ref1 == null || ref2 == null) {
      _showSnackBar("Erreur de configuration.");
      return;
    }

    String numeroAUtiliser = widget.numero;
    String extra = widget.service == "VISA UBA" && widget.dernierChiffreCarte != null
        ? widget.dernierChiffreCarte!
        : "";

    String ussdCode = ussdTemplate
        .replaceAll("{ref1}", ref1)
        .replaceAll("{numero}", numeroAUtiliser)
        .replaceAll("{extra}", extra)
        .replaceAll("{amount}", totalAmount.toStringAsFixed(0));

    await UssdHelper.showUssdDialog(context, ussdCode);
  }


  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
