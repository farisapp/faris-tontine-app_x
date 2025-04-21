import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

import '../utils/ussd_helper.dart';

class CanalPage extends StatefulWidget {
  CanalPage({Key? key}) : super(key: key);

  @override
  State<CanalPage> createState() => _MoovCanalPageState();
}

class _MoovCanalPageState extends State<CanalPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _compteurController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          "Renouvellement CANAL+",
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: _buildAppBarGradient(),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Entrez votre numéro de réabonnement pour continuer.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 15),
              _buildTextField(),
              const SizedBox(height: 20),
              _buildGradientButton(
                label: "Réabonnement",
                icon: Icons.payment,
                onPressed: () => _executeUssd('*144*4*2*4*1*2*'),
              ),
              const SizedBox(height: 10),
              _buildGradientButton(
                label: "Changement d'offre",
                icon: Icons.swap_horiz,
                onPressed: () => _executeUssd('*144*4*2*4*2*2*'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrange, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return TextFormField(
      controller: _compteurController,
      keyboardType: TextInputType.number,
      maxLength: 14,
      decoration: const InputDecoration(
        labelText: "Numéro de réabonnement CANAL+",
        border: OutlineInputBorder(),
        filled: true,
        contentPadding: EdgeInsets.all(10.0),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Veuillez entrer un numéro de réabonnement.";
        } else if (value.length != 14) {
          return "Le numéro doit contenir exactement 14 chiffres.";
        }
        return null;
      },
    );
  }

  Widget _buildGradientButton({required String label, required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.orange, Colors.deepOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            onPressed();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _executeUssd(String baseCode) {
    String compteur = _compteurController.text.trim();

    if (compteur.isEmpty || compteur.length != 14) {
      _showSnackbar("Veuillez entrer un numéro de réabonnement valide.", Colors.red);
      return;
    }

    String ussdCode = '$baseCode$compteur#';
    UssdHelper.showUssdDialog(context, ussdCode);
  }

  void _showSnackbar(String message, Color backgroundColor) {
    Get.snackbar(
      "Information",
      message,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(10),
    );
  }
}
