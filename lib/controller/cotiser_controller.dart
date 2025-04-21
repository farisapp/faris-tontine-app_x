
import 'dart:convert';

import 'package:faris/common/app_constant.dart';
import 'package:faris/controller/tontine_details_controller.dart';
import 'package:faris/data/models/body/init_moov_body.dart';
import 'package:get/get.dart';
import 'package:faris/data/models/body/cotiser_body.dart';
import 'package:faris/data/models/cotisation_model.dart';
import 'package:faris/data/models/periodicite_model.dart';
import 'package:faris/data/models/response_model.dart';
import 'package:http/http.dart' as http;
import 'package:faris/data/repositories/faris_tontine_repo.dart';

class CotiserController extends GetxController{

  final FarisTontineRepo farisTontineRepo;

  CotiserController({required this.farisTontineRepo});

  bool _cotisationLoaded = false;
  bool _periodiciteLoading = false;
  bool _processFinished = false;
  String? _errorMessage;
  bool _hasError = false;

  List<Map<String, String>> providers = [
    {"libelle": "Orange Money", "slug": "orange money", "logo": "assets/images/orange_money.png"},
    {"libelle": "Moov Money", "slug": "moov money", "logo": "assets/images/moov_money.png"},
  ];

  List<Cotisation>? _cotisations;
  List<Periodicite>? _periodicites;
  Periodicite? _selectedPeriode;
  String _selectedProvider = "orange money";

  List<Cotisation>? get cotisations => _cotisations;
  List<Periodicite>? get periodicites => _periodicites;
  Periodicite? get selectedPeriode => _selectedPeriode;
  String get selectedProvider => _selectedProvider;

  bool get cotisationLoaded => _cotisationLoaded;
  bool get periodiciteLoading => _periodiciteLoading;
  bool get processFinished => _processFinished;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;

  Future<ResponseModel> cotiser(CotiserBody cotiserBody,{String ? provider}) async {


    late Response response; 
    if(provider=="moov money"){
      print("moov money cotisation")  ;
      response = await farisTontineRepo.cotiserTontineMoov(cotiserBody);
    }else{
       response = await farisTontineRepo.cotiserTontine(cotiserBody);
    }
    
    ResponseModel responseModel;
    if(response.statusCode == 200 || response.statusCode == 201){
      _processFinished = true;
      responseModel = ResponseModel(true, response.body['message']);
      Get.find<TontineDetailsController>().getTontineCotisations(cotiserBody.tontine, true);
      Get.find<TontineDetailsController>().getTontineDetails(cotiserBody.tontine, true);
      Get.find<TontineDetailsController>().getTontinePeriodicitesToPaid(cotiserBody.tontine, true);

      //getPeriodicitesWithCotisations()
    }else{
      responseModel = ResponseModel(false, response.statusText);
      _processFinished = true;
    }
    update();
    return responseModel;
  }

  Future<void> getTontineCotisations(int? id, bool reload) async {
    if(_cotisations == null || reload){
      Response response = await farisTontineRepo.getTontineCotisations(id!);
      if(response.statusCode == 200){
        _cotisations = [];
        _cotisations = cotisationsFromJson(response.body['cotisations']);
        _cotisationLoaded = true;
        update();
      }else{
        _cotisationLoaded = true;
        update();
      }
    }
  }

  Future<void> getPeriodicitesWithCotisations(int? id, bool reload) async {
    if(_periodicites == null || reload){
      _periodiciteLoading = true;
      Response response = await farisTontineRepo.getTontinePeriodicitesWithCotisation(id!);
      if(response.statusCode == 200){
        _periodicites = [];
        _periodicites = periodicitesFromJson(response.body['periodicites']);
        _periodiciteLoading = false;
        update();
      }else{
        _periodiciteLoading = false;
        update();
      }
    }
  }


  Future<ResponseModel> makeRequestInitMoovOtp({required String phone,required String amount}) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstant.INIT_MOOV_OTP),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'amount': amount
        }),
      );


      final decodedResponse = jsonDecode(response.body);
      final apiResponse = ApiResponse.fromJson(decodedResponse);

      if (apiResponse.httpCode == 200 && apiResponse.response.status == "0") {

        print(response.body);
        return ResponseModel(true, apiResponse.response.transId+";"+apiResponse.response.requestId);
      } else {
        return ResponseModel(false, apiResponse.response.message);
      }
      
    } catch (e) {
      return ResponseModel(false, "Une erreur s'est produite: $e");
    }
  }


  void setPeriodicite(Periodicite? periodicite){
    if(periodicite != null){
      _selectedPeriode = periodicite;
    }
    update();
  }

  void setProvider(String provider){
    _selectedProvider = provider;
    update();
  }

}