import 'dart:io';
import 'dart:convert';
import 'package:faris/data/models/response_model.dart';
import 'package:get/get.dart';
import 'package:faris/data/core/api_checker.dart';
import 'package:faris/data/models/config_model.dart';
import 'package:faris/data/repositories/splash_repo.dart';

class SplashController extends GetxController implements GetxService {
  final SplashRepo splashRepo;

  SplashController({required this.splashRepo});

  Config? _config;
  bool _isLoading = false;
  bool _isConnected = true;
  bool _firstTimeConnectionCheck = true;

  Config? get config => _config;
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;

  @override
  void onInit() {
    super.onInit();
    checkConnectionAndLoadData();
  }

  /// Vérifie la connexion Internet et charge les données
  Future<void> checkConnectionAndLoadData() async {
    _isLoading = true;
    update();

    _isConnected = await _checkInternetConnection();

    if (_isConnected) {
      // Si connecté, charge les données de configuration
      bool success = await getConfigData();
      if (success) {
        // Redirige vers la page d'accueil après un délai
        await Future.delayed(Duration(seconds: 2));
        Get.offNamed('/home');
      } else {
        // Gestion des erreurs API
        Get.snackbar('Erreur', 'Impossible de charger les données.');
      }
    } else {
      // Redirige vers la page hors-ligne si pas de connexion
      Get.offNamed('/offline');
    }

    _isLoading = false;
    update();
  }

  /// Méthode pour récupérer les données de configuration
  Future<bool> getConfigData() async {
    Response response = await splashRepo.getConfigData();
    if (response.statusCode == 200) {
      _config = Config.fromJson(response.body);
      return true;
    } else {
      ApiChecker.CheckApi(response);
      return false;
    }
  }

  /// Vérifie la connexion Internet
  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false; // Pas de connexion Internet
    }
  }

  /// Autres méthodes existantes
  Future<ResponseModel> getShortLink(String longUrl) async {
    final result = await splashRepo.getShortLink(longUrl);

    if (result.statusCode == 200) {
      final resultUrl = jsonDecode(result.body);
      return ResponseModel(true, resultUrl['result_url']);
    } else {
      return ResponseModel(false, result.reasonPhrase);
    }
  }

  Future<bool> initSharedData() {
    return splashRepo.initSharedData();
  }

  bool showIntro() {
    return splashRepo.showIntro();
  }

  void disableIntro() {
    splashRepo.disableIntro();
  }

  void setFirstTimeConnectionCheck(bool isChecked) {
    _firstTimeConnectionCheck = isChecked;
  }
}
