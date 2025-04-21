
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:faris/data/core/api_checker.dart';
import 'package:faris/data/models/app_error_model.dart';
import 'package:faris/data/models/requete_tontine_model.dart';
import 'package:faris/data/models/response_model.dart';
import 'package:faris/data/models/tontine_model.dart';
import 'package:faris/data/repositories/faris_tontine_repo.dart';
import 'package:faris/data/repositories/user_repo.dart';

class RequestTontineController extends GetxController {

  final FarisTontineRepo farisTontineRepo;
  final UserRepo userRepo;

  RequestTontineController({required this.farisTontineRepo, required this.userRepo});

  List<Tontine> _tontines = [];
  List<RequeteTontine>? _requeteList;


  bool _requestSending = false;
  bool _requestLoaded = false;
  bool _hasError = false;
  bool _requeteLoadError = false;
  AppErrorType _appErrorType = AppErrorType.network;

  List<Tontine> get tontines => _tontines;
  List<RequeteTontine>? get requeteList => _requeteList;

  bool get requestSending => _requestSending;
  bool get requestLoaded => _requestLoaded;
  bool get hasError => _hasError;
  bool get requeteLoadError => _requeteLoadError;

  AppErrorType get appErrorType => _appErrorType;


  Future<ResponseModel> sendRequest(int tontine) async {
    _requestSending = true;
    update();
    Response response = await farisTontineRepo.sendRequest(
        tontine, "join_to_tontine");
    ResponseModel responseModel;
    if (response.statusCode == 200 || response.statusCode == 201) {
      _requestSending = false;
      responseModel = ResponseModel(true, response.body['message']);
    } else {
      _requestSending = false;
      responseModel = ResponseModel(false, response.statusText);
    }
    update();
    return responseModel;
  }

  Future<void> getRequests(bool reload) async {
      if (_requeteList == null || reload) {
        _requeteLoadError = false;
        update();
        Response response = await userRepo.getUserRequests();
        if (response.statusCode == 200) {
          _requestLoaded = true;
          _requeteList = [];
          _requeteList!.addAll(requetesFromJson(response.body['requetes']));
          update();
        } else {
          _requeteLoadError = true;
          if(response.statusCode == 500){
            _appErrorType = AppErrorType.api;
          }
          ApiChecker.CheckApi(response);
          update();
        }
      }
    }
}
