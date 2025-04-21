import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:faris/data/models/app_error_model.dart';
import 'package:faris/data/models/response_model.dart';
import 'package:faris/data/models/tontine_model.dart';
import 'package:faris/data/models/user_model.dart';
import 'package:faris/data/repositories/faris_tontine_repo.dart';
import 'package:faris/data/core/api_checker.dart';
import 'package:http/http.dart' as http;
import 'package:faris/common/app_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarisnanaDemandeController extends GetxController {
  String? token;



  // Fonction de récupération de la liste des commandes d'achat des produits
  Future<List<dynamic>> getListeDemnade() async {
    List<dynamic> result = [];

    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      token = sharedPreferences.getString(AppConstant.TOKEN);

      // Vérifie si le token est nul avant de continuer
      if (token == null) {
        print("Token non trouvé");
        return [];
      }

      final response = await http.get(
        Uri.parse('${AppConstant.LISTE_DEMANDE_FARIS_NANA_URI}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var formdata = jsonDecode(response.body);

        // Vérifie si formdata contient une clé "data" qui est une liste
        if (formdata['data'] is List) {
          result = formdata['data']; // Assigne directement la liste des articles
        } else {
          print("Données inattendues dans 'data'");
        }

        print(result);
      } else {
        print('Erreur de requête: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur: $e');
    }

    return result;
  }

}
