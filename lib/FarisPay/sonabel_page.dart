import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:faris/presentation/theme/theme_color.dart';
import 'package:faris/presentation/widgets/custom_snackbar.dart';

import '../utils/ussd_helper.dart';

class SonabelPage extends StatefulWidget {
  SonabelPage({Key? key}) : super(key: key);

  @override
  State<SonabelPage> createState() => _UssdPageState();
}

class _UssdPageState extends State<SonabelPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _compteurController = TextEditingController();
  TextEditingController _montantController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          "Recharge CASHPOWER SONABEL",
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
                      controller: _compteurController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Numéro du compteur SONABEL",
                        border: OutlineInputBorder(),
                        filled: true,
                        contentPadding: const EdgeInsets.all(10.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer un numéro de compteur SONABEL valide.";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _montantController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Montant de recharge",
                        border: OutlineInputBorder(),
                        filled: true,
                        contentPadding: const EdgeInsets.all(10.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer un montant.";
                        }
                        if (double.tryParse(value) == null || double.parse(value) <= 0) {
                          return "Veuillez entrer un montant et un numéro de compteur SONABEL valide.";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final compteur = _compteurController.text.trim();
                          final montant = _montantController.text.trim();
                          final ussdCode = '*144*4*2*2*2*1*2*$compteur*$montant#';
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
                          Icon(Icons.payment, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "PAYER",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                            String compteur = _compteurController.text.trim();
                            String montant = _montantController.text.trim();

                            if (compteur.isEmpty || montant.isEmpty) {
                              showCustomSnackBar(context, "Veuillez remplir tous les champs.");
                              return;
                            }

                            // Création du code USSD
                            String ussdCode = '*144*4*2*2*2*1*2*${compteur}*${montant}#';

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
