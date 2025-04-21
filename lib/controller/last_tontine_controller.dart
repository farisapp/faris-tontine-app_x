
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:faris/data/models/app_error_model.dart';
import 'package:faris/data/models/tontine_model.dart';
import 'package:faris/data/repositories/faris_tontine_repo.dart';
import 'package:faris/data/core/api_checker.dart';

class LastTontineController extends GetxController implements GetxService{

  final FarisTontineRepo farisTontineRepo;

  LastTontineController({required this.farisTontineRepo});

  bool _tontineLoaded = false;
  bool _hasError = false;
  AppErrorType _appErrorType = AppErrorType.network;

  List<Tontine>? _lastTontines;

  bool get tontineLoaded => _tontineLoaded;
  bool get hasError => _hasError;
  AppErrorType get appErrorType => _appErrorType;
  List<Tontine>? get lastTontines => _lastTontines;

  Future<void> getLastTontine(bool reload) async {
    if(reload){
      _hasError = false;
      update();
      Response response = await farisTontineRepo.getLastTontines();
      if(response.statusCode == 200){
        _lastTontines = [];
        _lastTontines!.addAll(tontinesFromJson(response.body['tontines']));
        _tontineLoaded = true;
        _hasError = false;

      }else{
        _tontineLoaded = false;
        _hasError = true;
        if(response.statusCode == 500){
          _appErrorType = AppErrorType.api;
        }
        ApiChecker.CheckApi(response);
      }
      update();
    }
  }
}