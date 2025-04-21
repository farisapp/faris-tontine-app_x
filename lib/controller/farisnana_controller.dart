import 'dart:convert';
import 'package:faris/data/models/body/init_moov_body.dart';
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

import '../presentation/widgets/custom_snackbar.dart';

class FarisnanaController extends GetxController {
  String? token;
  List<Map<String, String>> providers = [
    {
      "libelle": "Orange Money",
      "slug": "orange money",
      "logo": "assets/images/orange_money.png"
    },
    {
      "libelle": "Moov Money",
      "slug": "moov money",
      "logo": "assets/images/moov_money.png"
    },
  ];
  String _selectedProvider = "orange money";
  String get selectedProvider => _selectedProvider;

  // Fonction de récupération de la liste des souscriptions d'achat des produits
  Future<List<dynamic>> getListeAchat() async {
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
        Uri.parse('${AppConstant.LISTE_SOUSCRIPTION_FARIS_NANA_URI}'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var formdata = jsonDecode(response.body);

        // Vérifie si formdata contient une clé "data" qui est une liste
        if (formdata['data'] is List) {
          result =
              formdata['data']; // Assigne directement la liste des articles
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

  //Fonction d'ajout de demande d'article Faris Nana
  Future<int> ajoutDemandeArticle(
      nomArticle,
      boutique,
      nomVendeur,
      prixArticle,
      prixSouhaite,
      numVendeur,
      description,
      nbrSouhaite,
      telephoneClient) async {
    var success = 1;
    var error = 0;
    //initialisation de sharepreference pour la recuperation du token
    final sharedPreferences = await SharedPreferences.getInstance();
    token = sharedPreferences.getString(AppConstant.TOKEN);
    var urlPresence = AppConstant.ENREGISTREMENT_DEMANDE_FARIS_NANA_URI;
    final response = await http.post(
      Uri.parse(urlPresence),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        'nomArticle': nomArticle,
        'boutique': boutique,
        'nomVendeur': nomVendeur,
        'prixArticle': prixArticle,
        'prixSouhaite': prixArticle,
        'numVendeur': numVendeur,
        'description': description,
        'nbrSouhaite': nbrSouhaite,
        'description': description,
        'telephoneClient': telephoneClient
      }, // Convertir la presence en chaîne de caractères
      //body: jsonEncode({liste),
    );

    if (response.statusCode == 200) {
      print(success);
      var etat = response.statusCode;
      return success;
    } else {
      // Gérer les erreurs de requête ici
      print(response.statusCode);

      return error;
    }
    //  }
  }

  //Fonction de recuperation des infos sur un article pour la souscription
  Future<List<dynamic>> infoArticle(String codeArticle) async {
    List<dynamic> result = [];

    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      token = sharedPreferences.getString(AppConstant.TOKEN);

      // Vérifie si le token est nul avant de continuer
      if (token == null) {
        print("Token non trouvé");
        return [];
      }

      var urlInfo =
          AppConstant.INFO_SOUSCRIPTION_FARIS_NANA_URI + "$codeArticle";
      final response = await http.get(
        Uri.parse(urlInfo),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(urlInfo);
      print(urlInfo);
      print(urlInfo);
      print(urlInfo);
      if (response.statusCode == 200) {
        var formdata = jsonDecode(response.body);

        // Vérifie si formdata contient une clé "data" qui est une liste
        if (formdata['data'] is List) {
          result =
              formdata['data']; // Assigne directement la liste des articles
        } else {
          print("Données inattendues dans 'data'");
        }

        print(result);
      } else {
        print("#################################################");
        print('Erreur de requête: ${response.statusCode}');
        return result;
      }
    } catch (e) {
      print('Erreur: $e');
    }
    return result;
  }

  //Fonction de verification si article existe ou disponible
  Future<int> infoVerifyArticle(String codeArticle) async {
    List result = [];
    var success = 1;
    var error = 0;

    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      token = sharedPreferences.getString(AppConstant.TOKEN);

      // Vérifie si le token est nul avant de continuer
      if (token == null) {
        print("Token non trouvé");
        return error;
      }

      var urlInfo =
          AppConstant.INFO_SOUSCRIPTION_FARIS_NANA_URI + "$codeArticle";
      final response = await http.get(
        Uri.parse(urlInfo),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(urlInfo);
      print(urlInfo);
      print(urlInfo);
      print(urlInfo);
      if (response.statusCode == 200) {
        return success;
      } else {
        print(
            "###################################################################");
        print('Erreur de requête: ${response.statusCode}');
        return error;
      }
    } catch (e) {
      print('Erreur: $e');
    }
    return error;
  }

  //Fonction de recuperation infos article paiement et tranche de paiement
  Future<List<dynamic>> infoArticlePaiement(int idPaiement) async {
    List<dynamic> result = [];

    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      token = sharedPreferences.getString(AppConstant.TOKEN);

      // Vérifie si le token est nul avant de continuer
      if (token == null) {
        print("Token non trouvé");
        return [];
      }

      var urlInfo =
          AppConstant.LISTE_INFO_SOUSCRIPTION_ACHAT_URI + "$idPaiement";
      final response = await http.get(
        Uri.parse(urlInfo),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var formdata = jsonDecode(response.body);

        // Vérifier les types avant d'ajouter au résultat
        if (formdata['paiement'] is Map) {
          result.add(formdata['paiement']); // Ajoute directement la map
        } else {
          result.add({}); // Ajoute une map vide si non valide
        }

        if (formdata['infoArticle'] is List) {
          result.add(formdata['infoArticle']); // Ajoute la liste des articles
        } else {
          result.add([]); // Ajoute une liste vide si non valide
        }

        if (formdata['infoListePaiement'] is List) {
          result.add(
              formdata['infoListePaiement']); // Ajoute la liste des paiements
        } else {
          result.add([]); // Ajoute une liste vide si non valide
        }

        return result;
      }
    } catch (e) {
      print('Erreur: $e');
    }
    return result;
  }

  //Fonction Ajoutez souscription paiement FARIS NANA
  Future<int> ajoutAchatArticle(
      dateDebut, nbrTranche, codeArticle, article_id) async {
    var success = 1;
    var error = 0;
    // Initialisation de SharedPreferences pour la récupération du token
    final sharedPreferences = await SharedPreferences.getInstance();
    token = sharedPreferences.getString(AppConstant.TOKEN);
    var urlPresence = AppConstant.SOUSCRIPTION_FARIS_NANA_URI;

    // Envoi de la requête HTTP avec les paramètres convertis en chaîne de caractères
    final response = await http.post(
      Uri.parse(urlPresence),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        'codeArticle': codeArticle.toString(),
        'article_id': article_id.toString(),
        'date_debut': dateDebut,
        'nbrTranche': nbrTranche.toString(),
      },
    );

    if (response.statusCode == 200) {
      print(success);
      return success;
    } else {
      // Gérer les erreurs de requête ici
      print(response.statusCode);
      return response.statusCode;
    }
  }

  //Fonction de mise a jour du paiement pour valider une tranche
  Future<int> updatePaiement(int id, String montant, String provider,
      String codeOtp, String telephone, String transId, String reqId) async {
    const success = 1;
    const error = 0;
    //Convertir que si les chiffres apres la virgule sont des zero

// Vérifier si la partie après la virgule est égale à zéro
    var montantEntier = double.parse(montant).toInt();
    try {
      // Initialisation de SharedPreferences pour récupérer le token
      final sharedPreferences = await SharedPreferences.getInstance();
      final token = sharedPreferences.getString(AppConstant.TOKEN);

      if (token == null) {
        print("Token non disponible.");

        return error;
      }
      // onst String UPDATE_PAIEMENT_FARIS_NANA_URI = "$BASE_URL/api/v1/userpaiement/update/";
      //final urlPresence = AppConstant.UPDATE_PAIEMENT_FARIS_NANA_URI;
      var urlPresence = "${AppConstant.HOST}/api/v1/userpaiement/";

      if (provider == "orange money") {
        urlPresence = urlPresence + "update_via_om";
      } else {
        urlPresence = urlPresence + "update_via_moov_money";
      }
      // Requête HTTP POST
      final response = await http.post(Uri.parse(urlPresence), headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      }, body: {
        'idPaiement': id.toString(),
        'trans_id': transId,
        'request_id': reqId,
        'montant': montantEntier.toString(),
        'provider': provider.toString(),
        'code_otp': codeOtp.toString(),
        'telephonePaiement': telephone.toString(),
      });

      // Logs pour debug
      print('URL: $urlPresence');
      print('Headers: ${response.headers}');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // Vérification du code de statut
      if (response.statusCode == 200) {
        print("Paiement mis à jour avec succès.");
        return success;
      } else if (response.statusCode == 301) {
        print("Erreur de redirection détectée (301). Vérifiez l'URL.");
        return error;
      } else {
        print("Erreur inattendue : ${response.statusCode}");
        return response.statusCode;
      }
    } catch (e) {
      // Capture des exceptions
      print("Erreur lors de la requête : $e");
      return error;
    }
  }

//Fonction de suppression demande propoez FARIS NANA
  Future<int> deleteDemandeUser(id) async {
    var success = 1;
    var error = 0;
    //initialisation de sharepreference pour la recuperation du token
    final sharedPreferences = await SharedPreferences.getInstance();
    token = sharedPreferences.getString(AppConstant.TOKEN);
    var urlInfo = AppConstant.SUPPRIMER_DEMANDE_URI + "$id";
    final response = await http.put(
      Uri.parse(urlInfo),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print(success);
      var etat = response.statusCode;
      return success;
    } else {
      // Gérer les erreurs de requête ici
      print(response.statusCode);

      return error;
    }
    //  }
  }

//Fonction de suppression de souscription propoez FARIS NANA
  Future<int> deleteSouscriptionUser(id) async {
    var success = 1;
    var error = 0;
    //initialisation de sharepreference pour la recuperation du token
    final sharedPreferences = await SharedPreferences.getInstance();
    token = sharedPreferences.getString(AppConstant.TOKEN);
    var urlInfo = AppConstant.SUPPRIMER_SOUSCRIPTION_URI + "$id";
    final response = await http.put(
      Uri.parse(urlInfo),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print(success);
      var etat = response.statusCode;
      return success;
    } else {
      // Gérer les erreurs de requête ici
      print(response.statusCode);

      return error;
    }
    //  }
  }

  void setProvider(String provider) {
    _selectedProvider = provider;
    update();
  }

  Future<ResponseModel> makeRequestInitMoovOtp(
      {required String phone, required String amount}) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstant.INIT_MOOV_OTP),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'phone': phone, 'amount': amount}),
      );

      final decodedResponse = jsonDecode(response.body);
      final apiResponse = ApiResponse.fromJson(decodedResponse);

      if (apiResponse.httpCode == 200 && apiResponse.response.status == "0") {
        print(response.body);
        return ResponseModel(
            true,
            apiResponse.response.transId +
                ";" +
                apiResponse.response.requestId);
      } else {
        return ResponseModel(false, apiResponse.response.message);
      }
    } catch (e) {
      return ResponseModel(false, "Une erreur s'est produite: $e");
    }
  }
}
