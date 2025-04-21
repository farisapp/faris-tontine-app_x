
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:faris/presentation/theme/theme_color.dart';
import 'package:faris/presentation/widgets/custom_snackbar.dart';

import '../utils/ussd_helper.dart';

class OmSendMoneyPage extends StatefulWidget {
  OmSendMoneyPage({Key? key}) : super(key: key);

  @override
  State<OmSendMoneyPage> createState() => _UssdPageState();
}

class _UssdPageState extends State<OmSendMoneyPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _telephoneController = TextEditingController();
  TextEditingController _montantController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          "Paiement via Orange Money",
          style: TextStyle(
            color: AppColor.kTontinet_secondary,
            fontSize: 20,
            fontFamily: GoogleFonts.raleway(fontWeight: FontWeight.w800).fontFamily,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Entrez les détails et appuyez sur 'PAYER'",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              SizedBox(height: 10),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _telephoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Numéro de téléphone",
                        border: OutlineInputBorder(),
                        filled: true,
                        contentPadding: const EdgeInsets.all(10.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer le numéro de téléphone.";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _montantController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Montant à payer",
                        border: OutlineInputBorder(),
                        filled: true,
                        contentPadding: const EdgeInsets.all(10.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer un montant.";
                        }
                        if (double.tryParse(value) == null || double.parse(value) <= 0) {
                          return "Veuillez entrer un montant valide.";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final telephone = _telephoneController.text.trim();
                          final montant = _montantController.text.trim();
                          final ussdCode = '*144*2*1*$telephone*$montant#';

                          UssdHelper.launchUssd(context: context, ussdCode: ussdCode);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.payment, color: Colors.white), // Icône en blanc
                          SizedBox(width: 8),
                          Text(
                            "PAYER",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Texte en blanc
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16), // Espacement entre les deux boutons

// Bouton Copier le code USSD
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            String telephone = _telephoneController.text.trim();
                            String montant = _montantController.text.trim();

                            if (telephone.isEmpty || montant.isEmpty) {
                              showCustomSnackBar(context, "Veuillez remplir tous les champs.");
                              return;
                            }

                            // Création du code USSD
                            String ussdCode = '*144*2*1*${telephone}*${montant}#';

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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
