import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:faris/presentation/theme/theme_color.dart';
import 'package:faris/presentation/widgets/custom_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/ussd_helper.dart';

class RetraitPage extends StatefulWidget {
  RetraitPage({Key? key}) : super(key: key);

  @override
  State<RetraitPage> createState() => _RetraitPageState();
}

class _RetraitPageState extends State<RetraitPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeAgentController = TextEditingController();
  final TextEditingController _montantController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          "Retrait via Orange Money",
          style: TextStyle(
            color: AppColor.kTontinet_secondary,
            fontSize: 20,
            fontFamily: GoogleFonts.raleway(fontWeight: FontWeight.w800).fontFamily,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                    _buildTextField(
                      label: "Code Agent",
                      controller: _codeAgentController,
                      inputType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer le code agent.";
                        }
                        if (value.length < 4) {
                          return "Le code agent doit comporter au moins 4 chiffres.";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    _buildTextField(
                      label: "Montant à retirer",
                      controller: _montantController,
                      inputType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer un montant.";
                        }
                        final montant = double.tryParse(value);
                        if (montant == null || montant <= 0) {
                          return "Veuillez entrer un montant valide.";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          String ussdCode = '*144*3*${_codeAgentController.text.trim()}*${_montantController.text.trim()}#';
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
                          Text("PAYER", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                            String ussdCode = '*144*3*${_codeAgentController.text.trim()}*${_montantController.text.trim()}#';
                            Clipboard.setData(ClipboardData(text: ussdCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Code USSD copié dans le presse-papier")),
                            );
                          } else {
                            showCustomSnackBar(context, "Veuillez remplir tous les champs correctement.", isError: true);
                          }
                        },
                        icon: const Icon(Icons.copy, color: Colors.orange),
                        label: const Text(
                          "Copier le code USSD",
                          style: TextStyle(color: Colors.orange),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16.0),
                          side: BorderSide.none,
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required TextInputType inputType,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        contentPadding: const EdgeInsets.all(10.0),
      ),
      validator: validator,
    );
  }

}
