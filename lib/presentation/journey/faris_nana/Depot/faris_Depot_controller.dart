import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:faris/common/app_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';


class FarisDepotController extends GetxController {
  String? token;

  final String apiUrl = "https://votre-domaine.com/api/payer_om.php"; // Modifier avec l'URL réelle

  /// 🔹 Fonction pour payer via Orange Money
  Future<int> payerAvecOrangeMoney(
      String telephone,
      String montant,
      String codeOtp, {
        String tontineId = "FT47111012",
        String periodeId = "15 janvier 2025",
        String provider = "orange money",
      }) async {
    try {
      var response = await http.post(
        Uri.parse("https://apps.farisbusinessgroup.com/api/payer_orange_money.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "telephone": telephone,
          "montant": montant,
          "code_otp": codeOtp,
          "tontine_id": tontineId,  // ✅ Valeur par défaut envoyée
          "periode_id": periodeId,  // ✅ Valeur par défaut envoyée
          "provider": provider      // ✅ Valeur par défaut envoyée
        }),
      );

      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse["status"] == "success") {
        return 1; // ✅ Paiement réussi
      } else {
        debugPrint("❌ Erreur API Orange Money : ${jsonResponse["message"]}");
        return 0; // ❌ Paiement échoué
      }
    } catch (e) {
      debugPrint("❌ Erreur de connexion à l'API : $e");
      return 0;
    }
  }

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
        Uri.parse('${AppConstant.LISTE_SOUSCRIPTION_FARIS_DEPOT_URI}'),
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
  Future<List<dynamic>> getListeDepots() async {
    List<dynamic> result = [];

    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      token = sharedPreferences.getString(AppConstant.TOKEN);

      if (token == null) {
        print("Token non trouvé");
        return [];
      }

      final response = await http.get(
        Uri.parse(AppConstant.LISTE_DEPOT_FARIS_NANA_URI),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var formdata = jsonDecode(response.body);

        if (formdata['data'] is List) {
          result = formdata['data']; // Stocker la liste des Depots
        } else {
          print("Données inattendues dans 'data'");
        }
      } else {
        print('Erreur de requête: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur: $e');
    }

    return result;
  }


  //Fonction d'ajout de Depot d'article Faris Depot
  Future<int> ajoutDepotArticle(
      nomArticle,
      boutique,
      mail,
      prixArticle,
      prixSouhaite,
      numVendeur,
      description,
      nbrSouhaite,
      telephoneClient
      ) async {
    var success = 1;
    var error = 0;
    //initialisation de sharepreference pour la recuperation du token
    final sharedPreferences = await SharedPreferences.getInstance();
    token = sharedPreferences.getString(AppConstant.TOKEN);
    var urlPresence = AppConstant.ENREGISTREMENT_DEPOT_FARIS_DEPOT_URI;
    final response = await http.post(
      Uri.parse(urlPresence),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        'nomArticle': nomArticle,
        'boutique': boutique.isEmpty ? "NULL" : boutique, // ✅ Ajout de condition
        'mail': mail.isEmpty ? "NULL" : mail,
        'prixArticle': prixArticle,
        'prixSouhaite': prixArticle,
        'numVendeur': numVendeur.isEmpty ? "NULL" : numVendeur,
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
          AppConstant.INFO_SOUSCRIPTION_FARIS_DEPOT_URI + "$codeArticle";
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
          AppConstant.INFO_SOUSCRIPTION_FARIS_DEPOT_URI + "$codeArticle";
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

  //Fonction Ajoutez souscription paiement FARIS Depot
  Future<int> ajoutAchatArticle(
      dateDebut, nbrTranche, codeArticle, article_id) async {
    var success = 1;
    var error = 0;
    // Initialisation de SharedPreferences pour la récupération du token
    final sharedPreferences = await SharedPreferences.getInstance();
    token = sharedPreferences.getString(AppConstant.TOKEN);
    var urlPresence = AppConstant.SOUSCRIPTION_FARIS_DEPOT_URI;

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
  Future<int> updatePaiement(id, montant, provider, codeOtp, telephone) async {
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
      // onst String UPDATE_PAIEMENT_FARIS_Depot_URI = "$BASE_URL/api/v1/userpaiement/update/";
      //final urlPresence = AppConstant.UPDATE_PAIEMENT_FARIS_Depot_URI;
      const urlPresence =
          "${AppConstant.HOST}/api/v1/userpaiement/update_via_om";

      // Requête HTTP POST
      final response = await http.post(
        Uri.parse(urlPresence),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'idPaiement': id.toString(),
          'montant': montantEntier.toString(),
          'provider': provider.toString(),
          'code_otp': codeOtp.toString(),
          'telephonePaiement': telephone.toString(),
        },
      );

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

//Fonction de suppression Depot propoez FARIS Depot
  Future<int> deleteDepot(id) async {
    var success = 1;
    var error = 0;
    //initialisation de sharepreference pour la recuperation du token
    final sharedPreferences = await SharedPreferences.getInstance();
    token = sharedPreferences.getString(AppConstant.TOKEN);
    var urlInfo = AppConstant.SUPPRIMER_DEPOT_URI + "$id";
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

  //Fonction de suppression de souscription propoez FARIS Depot
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
}
