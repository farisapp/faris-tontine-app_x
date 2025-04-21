import 'dart:convert';

import 'package:faris/controller/last_tontine_controller.dart';
import 'package:faris/controller/tontine_controller.dart';
import 'package:faris/controller/user_controller.dart';
import 'package:faris/data/models/body/RetraitBody.dart';
import 'package:faris/data/models/requete_tontine_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:faris/data/models/app_error_model.dart';
import 'package:faris/data/models/cotisation_model.dart';
import 'package:faris/data/models/membre_model.dart';
import 'package:faris/data/models/periodicite_model.dart';
import 'package:faris/data/models/response_model.dart';
import 'package:faris/data/models/stat_tontine_model.dart';
import 'package:faris/data/models/tontine_model.dart';
import 'package:faris/data/models/user_tontine_etat.dart';
import 'package:faris/data/repositories/faris_tontine_repo.dart';
import 'package:faris/data/models/api_response.dart' as myApiResponse;
import 'package:shared_preferences/shared_preferences.dart';
import '../common/app_constant.dart';
import '../data/core/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:faris/data/models/api_response.dart' as myApi;

class TontineDetailsController extends GetxController{

  final FarisTontineRepo farisTontineRepo;
  final ApiClient apiClient = Get.find<ApiClient>();

  TontineDetailsController({required this.farisTontineRepo});

  bool _tontineLoaded = false;
  bool _membreLoaded = false;
  bool _cotisationLoaded = false;
  bool _periodiciteLoaded = false;
  bool _statusUpdated = false;
  bool _tontineEtatLoaded = false;
  bool _loading = false;
  bool _creditRequestSubmitting = false;

  String? _errorMessage;
  bool _hasError = false;
  AppErrorType _appErrorType = AppErrorType.network;

  Tontine? _tontine;
  List<Membre>? _membres;
  List<Cotisation>? _cotisations;
  List<Periodicite>? _periodicites;
  List<Periodicite>? _periodiciteToPaidList;
  List<UserTontineEtat>? _userTontineEtatList;
  List<StatTontine>? _statTontineList;
  List<RequeteTontine>? _requeteList;
  Periodicite? _selectedPeriod;
  List<String> _providers = ['Orange money', 'Moov money', 'Autres'];
  String _selectedProvider = "Orange money";
  int? _selectedPeriodToPaid;
  int? _selectedMembre;

  Tontine? get tontine => _tontine;
  List<Membre>? get membres => _membres;
  List<Cotisation>? get cotisations => _cotisations;
  List<Periodicite>? get periodicites => _periodicites;
  List<Periodicite>? get periodiciteToPaidList => _periodiciteToPaidList;
  List<UserTontineEtat>? get userTontineEtatList => _userTontineEtatList;
  List<StatTontine>? get statTontineList => _statTontineList;
  List<RequeteTontine>? get requeteList => _requeteList;
  List<String>? get providers => _providers;
  Periodicite? get selectedPeriod => _selectedPeriod;
  String? get selectedProvider => _selectedProvider;
  int? get selectedMembre => _selectedMembre;
  int? get selectedPeriodToPaid => _selectedPeriodToPaid;

  bool get tontineLoaded => _tontineLoaded;
  bool get membreLoaded => _membreLoaded;
  bool get cotisationLoaded => _cotisationLoaded;
  bool get periodiciteLoaded => _periodiciteLoaded;
  bool get tontineEtatLoaded => _tontineEtatLoaded;
  bool get hasError => _hasError;
  bool get statusUpdated => _statusUpdated;
  bool get loading => _loading;
  bool get creditRequestSubmitting => _creditRequestSubmitting;
  String? get errorMessage => _errorMessage;
  AppErrorType get appErrorType => _appErrorType;

  Future<myApiResponse.ApiResponse> softDeleteTontine(int id) async {
    final response = await apiClient.putData(
      '${AppConstant.TONTINE_SOFT_DELETE_URI}/$id',
      {"is_deleted": 1},
    );

    return myApiResponse.ApiResponse.fromResponse(response);
  }

  Future<myApi.ApiResponse> updatePublicStatus(int tontineId, bool isPublic) async {
    final url = Uri.parse("https://apps.farisbusinessgroup.com/api/update_tontine_public.php");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "tontine_id": tontineId,
        "isPublic": isPublic ? 1 : 0,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return myApi.ApiResponse(
        isSuccess: data["status"] == true,
        message: data["message"] ?? "Réponse inconnue",
      );
    } else {
      return myApi.ApiResponse(isSuccess: false, message: "Erreur réseau");
    }
  }

  Future<void> getTontineDetails(int? id, bool reload) async {
    if (_tontine == null || reload) {
      _tontine = null;
      _hasError = false;
      update();
      Response response = await farisTontineRepo.getTontineDetails(id!);
      if (response.statusCode == 200) {
        _tontine = Tontine.fromJson(response.body['tontine']);
            // Tri des membres, s'ils existent
        if (_tontine != null) {
          _tontine?.membres?.sort((a, b) => a.ordre!.compareTo(b.ordre!));
        }

        // Récupération des valeurs nécessaires
        double montantRamassage = _tontine!.montantTontine.toDouble();
        int nbrePersonne = _tontine!.nbrePersonne;
        int nbrePeriode = _tontine!.nbrePeriode;
        int totalCotise = _tontine!.totalMontantCotise;
        int montantRetire = _tontine!.montantRetire;
        String type = _tontine!.type ?? "";

        // Calcul du total attendu selon le type d'épargne
        double totalAttendu = 0;
        if (type == "TONTINE EN GROUPE") {
          totalAttendu = montantRamassage * nbrePersonne * nbrePersonne;
        } else if (type == "EPARGNE INDIVIDUELLE") {
          totalAttendu = montantRamassage * nbrePeriode;
        } else if (type == "EPARGNE COLLECTIVE") {
          totalAttendu = montantRamassage * nbrePersonne * nbrePeriode;
        } else {
          // Si aucun type ne correspond, on peut utiliser une valeur par défaut
          totalAttendu = montantRamassage * nbrePersonne;
        }

        // Calcul des paiements en attente
        _tontine!.totalMontantRestant = totalAttendu.toInt() - totalCotise;
        _tontineLoaded = true;
        _hasError = false;
      } else {
        _hasError = true;
        if (response.statusCode == 500) {
          _appErrorType = AppErrorType.api;
        }
        _errorMessage = response.statusText;
      }
      update();
    }
  }

  Future<ResponseModel> deleteTontine(int tontineId) async {
    Response response = await farisTontineRepo.deleteTontine(tontineId);
    ResponseModel responseModel;
    if(response.statusCode == 200){
      responseModel = ResponseModel(true, response.body['message']);
      Get.find<TontineController>().getTontines(true);
      Get.find<LastTontineController>().getLastTontine(true);
    }else{
      responseModel = ResponseModel(false, response.statusText);
    }
    update();
    return responseModel;
  }

  Future<void> getUserTontineEtats(int? id, int? userId, bool reload) async {
    if(_userTontineEtatList == null || reload){
      _tontineEtatLoaded = false;
      update();
      Response response = await farisTontineRepo.getUserTontineEtats(id!, userId!);
      if(response.statusCode == 200){
        _tontineEtatLoaded = true;
        _userTontineEtatList = [];
        _userTontineEtatList = userTontineEtatFromJson(response.body['tontine_etats']);
        //_tontineLoaded = true;
        //_hasError = false;
      }else{
        /*_hasError = true;
        if(response.statusCode == 500){
          _appErrorType = AppErrorType.api;
        }
        _errorMessage = response.statusText;*/
      }
      update();
    }
  }

  Future<ResponseModel> updateStatus(int id, String status) async {
    Response response = await farisTontineRepo.updateTontineStatus(id, status);
    ResponseModel responseModel;
    if(response.statusCode == 200 || response.statusCode == 201){
      _statusUpdated = true;
      responseModel = ResponseModel(true, response.body['message']);
      _tontine = null;
      _tontine = Tontine.fromJson(response.body['tontine']);
      /*if(_membres != null){
        _membres?.sort((a, b) => a.ordre!.compareTo(b.ordre!));
        _membres?.insert(0, new Membre(id: 0, displayName: "Ajouter"));
      }*/
      getTontinePeriodicites(id, true);
      Get.find<TontineController>().getTontines(true);
      Get.find<LastTontineController>().getLastTontine(true);
      update();
    }else{
      responseModel = ResponseModel(false, response.statusText);
      _statusUpdated = true;
      update();
    }
    return responseModel;
  }

  Future<void> getTontineMembres(int? id, bool reload) async {
    if(_membres == null || reload){
      Response response = await farisTontineRepo.getTontineMembres(id!);
      if(response.statusCode == 200){
        _membres = [];
        _membres = membresFromJson(response.body['membres']);
        _membres?.sort((a, b) => a.ordre!.compareTo(b.ordre!));
        _membres?.insert(0, new Membre(id: 0, displayName: "Ajouter"));
        _membreLoaded = true;
        update();
      }else{
        _membres?.insert(0, new Membre(id: 0, displayName: "Ajouter"));
        _membreLoaded = true;
        update();
      }
    }
  }

  Future<void> getTontineCotisations(int? id, bool reload) async {
    if(_cotisations == null || reload){
      _cotisationLoaded = false;
      update();
      Response response = await farisTontineRepo.getTontineCotisations(id!, period: _selectedPeriod != null ? _selectedPeriod!.id! : 0);
      if(response.statusCode == 200){
        _cotisations = [];
        _cotisations = cotisationsFromJson(response.body['cotisations']);
        _cotisationLoaded = true;
      }else{

      }
      update();
    }
  }

  Future<void> getTontinePeriodicites(int? id, bool reload) async {
    if(_periodicites == null || reload){
      Response response = await farisTontineRepo.getTontinePeriodicites(id!);
      if(response.statusCode == 200){
        _periodicites = [];
        _periodicites = periodicitesFromJson(response.body['periodicites']);
        _periodicites!.insert(0, new Periodicite(id: 0, libelle: "Toutes"));
        _selectedPeriod = _periodicites![0];
        _periodiciteLoaded = true;
        getTontineCotisations(id, true);
        update();
      }else{
        _periodiciteLoaded = true;
        update();
      }
    }
  }

  Future<void> getTontinePeriodicitesToPaid(int? id, bool reload) async {
    if(reload){
      Response response = await farisTontineRepo.getTontinePeriodicitesToPaid(id!);
      if(response.statusCode == 200){
        _periodiciteToPaidList = [];
        _periodiciteToPaidList = periodicitesFromJson(response.body['periodicites']);
        print("Hello1 => $_periodiciteToPaidList");
        if(_periodiciteToPaidList != null){
          if(_periodiciteToPaidList!.isNotEmpty){
            _periodiciteToPaidList = _periodiciteToPaidList!.where((element) => element.statut == 0).toList();
            print("Hello2 => $_periodiciteToPaidList");
          }
        }
      }
      update();
    }
  }

  Future<void> getTontineStats(int? id, bool reload) async {
    if(_statTontineList == null || reload){
      _loading = true;
      Response response = await farisTontineRepo.getTontineStats(id!);
      if(response.statusCode == 200){
        _statTontineList = [];
        _statTontineList = statsFromJson(response.body['stats']);
        _loading = false;
      }else{

      }
      update();
    }
  }

  Future<void> getTontineRequetes(int? id, bool reload) async {
    if(_requeteList == null || reload){
      Response response = await farisTontineRepo.getTontineRequetes(id!);
      if(response.statusCode == 200){
        _requeteList = [];
        _requeteList = requetesFromJson(response.body['requetes']);
      }else{

      }
      update();
    }
  }

  Future<ResponseModel> acceptOrRejectRequest(int requestId, String status) async {
    Response response = await farisTontineRepo.acceptOrRejectRequest(requestId, status);
    ResponseModel responseModel;
    if(response.statusCode == 200){
      responseModel = ResponseModel(true, response.body['message']);
      getTontineMembres(_tontine?.id, true);
      getTontineRequetes(_tontine?.id, true);
      Get.find<TontineController>().getTontines(true);
      Get.find<LastTontineController>().getLastTontine(true);
      update();
    }else{
      responseModel = ResponseModel(false, response.statusText);
      update();
    }
    return responseModel;
  }

  Future<ResponseModel> deleteTontineMembre(int? userId, int? tontineId) async {
    Response response = await farisTontineRepo.deleteMembre(userId, tontineId);
    ResponseModel responseModel;
    if(response.statusCode == 200){
      responseModel = ResponseModel(true, response.body['message']);
      getTontineMembres(tontineId, true);
      Get.find<TontineController>().getTontines(true);
      Get.find<LastTontineController>().getLastTontine(true);
      Get.find<UserController>().getUserInfo();
    }else{
      responseModel = ResponseModel(false, response.statusText);
    }
    update();
    return responseModel;
  }


  List<Membre> membresNonCotises = [];

  bool checkMembersPaidFirstPeriod() {
    membresNonCotises.clear();

    if (_membres == null || _cotisations == null || _periodicites == null) return true;

    Periodicite? firstPeriod = _periodicites!.length > 1 ? _periodicites![1] : null;

    if (firstPeriod == null) return true;

    for (var membre in _membres!) {
      if (membre.id == 0) continue;

      bool hasPaid = _cotisations!.any((cotisation) =>
      cotisation.membre?.id == membre.id &&
          cotisation.periode?.id == firstPeriod.id &&
          cotisation.statut?.toUpperCase() == "PAID");

      if (!hasPaid) {
        membresNonCotises.add(membre);
      }
    }

    return membresNonCotises.isEmpty;
  }


  Future<ResponseModel> sendCreditRequest(RetraitBody retraitBody) async {
    _creditRequestSubmitting = true;
    update();

    ResponseModel responseModel;

    try {
      Response response = await farisTontineRepo.sendCreditRequest(retraitBody).timeout(
        Duration(seconds: 30),
        onTimeout: () => throw Exception("La demande a expiré après 30 secondes."),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        responseModel = ResponseModel(true, response.body['message']);

        // Mise à jour persistante du montant retiré
        if (_tontine != null) {
          int nouveauMontant = _tontine!.montantRetire + (retraitBody.montant ?? 0);
          await getTontineDetails(_tontine!.id, true); // 👈 Force recalcul actualisé
        }

        /* if (retraitBody.tontine != null) {
          final statusResponse = await updateStatus(retraitBody.tontine!, 'FINISHED');
          if (!statusResponse.isSuccess) {
            Get.snackbar(
              "Erreur",
              "Retrait effectué, mais la clôture de la tontine a échoué.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          } else {
            Get.snackbar(
              "Succès",
              "Retrait effectué et tontine clôturée avec succès.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          }
        } */

        Get.back();
      } else {
        responseModel = ResponseModel(false, response.statusText);
        Get.snackbar(
          "Erreur",
          response.statusText ?? "Erreur lors du retrait.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      responseModel = ResponseModel(false, "Erreur : $e");
      Get.snackbar(
        "Erreur",
        "Une erreur est survenue : $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _creditRequestSubmitting = false;
      update();
      Get.back();
    }

    return responseModel;
  }

  updateTontineDetails(Tontine tontine){
    _tontine = tontine;
    _tontine?.membres?.sort((a, b) => a.ordre!.compareTo(b.ordre!));
    _tontine?.membres?.insert(0, new Membre(id: 0, displayName: "Ajouter"));
    update();
  }

  void changePeriod(Periodicite? period){
    if(period != null){
      _selectedPeriod = period;
      getTontineCotisations(_tontine!.id, true);
      update();
    }
  }

  void setSelectedMembre(int membre){
    _selectedMembre = membre;
    update();
  }

  void setSelectedPeriodToPaid(int periode){
    _selectedPeriodToPaid = periode;
    update();
  }

  void setSelectedProvider(String provider){
    _selectedProvider = provider;
    update();
  }

  bool isMembre(int user_id){
    if(_tontine != null){
      if(_tontine!.membres != null){
        Membre membre = _tontine!.membres!.firstWhere((membre) => membre.id == user_id, orElse: () => new Membre());
        if(membre.id != null){
          return true;
        }
      }
    }
    return false;
  }

  bool isUpToDate(int user_id){
    if(_tontine != null){
      if(_tontine!.statut == "RUNNING" || _tontine!.statut == "FINISHED"){
        if(_cotisations != null){
          if(_tontine!.nbrePeriode != null){
            List<Cotisation> co = _cotisations!.where((cotisation) => cotisation.membre!.id == user_id).toList();
            //print("A JOUR => ${co.length}");
            if((co.length > 0 && co.length >= (_tontine!.nbrePeriode!-1)) || co.length == _tontine!.nbrePeriode ){
              return true;
            }
          }else{
            Cotisation cotisation = _cotisations!.firstWhere((cotisation) => cotisation.membre!.id == user_id, orElse: () => new Cotisation());
            if(cotisation.id != null){
              return true;
            }
          }
        }
      }
    }
    return false;
  }




  Future<myApi.ApiResponse> updateBlockStatus(int tontineId, bool isBlocked) async {
    final url = Uri.parse("https://apps.farisbusinessgroup.com/api/update_tontine_block.php");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "tontine_id": tontineId,
        "isBlocked": isBlocked ? 1 : 0,
      }),
    );

    debugPrint("HTTP Status: ${response.statusCode}");
    debugPrint("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return myApi.ApiResponse(
        isSuccess: data["status"] == true,
        message: data["message"] ?? "Réponse inconnue",
      );
    } else {
      return myApi.ApiResponse(isSuccess: false, message: "Erreur réseau");
    }
  }

}


