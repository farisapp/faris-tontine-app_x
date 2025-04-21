import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:faris/presentation/theme/theme_color.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

import '../utils/ussd_helper.dart';

class OneaPage extends StatefulWidget {
  OneaPage({Key? key}) : super(key: key);

  @override
  State<OneaPage> createState() => _UssdPageState();
}

class _UssdPageState extends State<OneaPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _compteurController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          "Paiement de factures ONEA",
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
                "Entrez le Numéro Abonné de 14 chiffres et appuyez sur 'PAYER'. Sélectionnez ensuite une facture à payer",
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
                      maxLength: 14, // Limite à 14 chiffres
                      decoration: InputDecoration(
                        labelText: "Numéro Abonné ONEA",
                        border: OutlineInputBorder(),
                        filled: true,
                        contentPadding: const EdgeInsets.all(10.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length != 14) {
                          return "Veuillez entrer un numéro valide de 14 chiffres";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _executeUssd();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.payment),
                          SizedBox(width: 8),
                          Text("PAYER avec Moov Money", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                    SizedBox(height: 16), // Espacement entre les deux boutons

// Bouton Copier le code USSD
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          String compteur = _compteurController.text.trim();
                          if (compteur.length != 14) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Veuillez entrer un numéro valide de 14 chiffres.")),
                            );
                            return;
                          }

                          String ussdCode = '*555*4*3*3*1*2*$compteur#';

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
  void _executeUssd() {
    String compteur = _compteurController.text.trim();
    if (compteur.length != 14) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer un numéro valide de 14 chiffres.")),
      );
      return;
    }

    String ussdCode = '*555*4*3*3*1*2*$compteur#';
    UssdHelper.showUssdDialog(context, ussdCode);
  }
}
