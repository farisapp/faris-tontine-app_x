import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:faris/data/models/app_error_model.dart';
import 'package:faris/data/models/response_model.dart';
import 'package:faris/data/models/tontine_model.dart';
import 'package:faris/data/models/user_model.dart';
import 'package:faris/data/repositories/faris_tontine_repo.dart';
import 'package:faris/data/core/api_checker.dart';


class TontineController extends GetxController {

  final FarisTontineRepo farisTontineRepo;

  TontineController({required this.farisTontineRepo});

  PageController pageController = PageController();
  int _currentIndex = 0;
  List<Tontine> _searchTontines = [];
  List<Tontine>? _pendingTontines;
  List<Tontine>? _tontines;
  List<Tontine>? _runningTontines;
  List<Tontine>? _doneTontines;
  bool _pendingLoaded = false;
  bool _isLoaded = false;
  bool _runningLoaded = false;
  bool _doneLoaded = false;

  bool _searchLoading = false;
  bool _searchHasError = false;
  AppErrorType _appErrorType = AppErrorType.network;


  int get currentIndex => _currentIndex;
  List<Tontine>? get tontines => _tontines;
  List<Tontine>? get pendingTontines => _pendingTontines;
  List<Tontine>? get runningTontines => _runningTontines;
  List<Tontine>? get doneTontines => _doneTontines;
  List<Tontine>? get searchTontines => _searchTontines;
  bool get pendingLoaded => _pendingLoaded;
  bool get isLoaded => _isLoaded;
  bool get runningLoaded => _runningLoaded;
  bool get doneLoaded => _doneLoaded;
  bool get searchLoading => _searchLoading;
  bool get searchHasError => _searchHasError;
  AppErrorType get appErrorType => _appErrorType;

  int get hasError => 0;


  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  changePage(int index){
    _currentIndex = index;
    update();
  }

  getTontines(bool reload) async {
    if(_tontines == null || reload){
      Response response = await farisTontineRepo.getTontines();
      if(response.statusCode == 200){
        _tontines = [];
        _tontines!.addAll(tontinesFromJson(response.body['tontines']));
        _isLoaded = true;
        update();
      }else{
        ApiChecker.CheckApi(response);
      }
    }
  }
  getPendingTontines(bool reload) async {
    if(_pendingTontines == null || reload){
      Response response = await farisTontineRepo.getPendingTontines();
      if(response.statusCode == 200){
        _pendingTontines = [];
        _pendingTontines!.addAll(tontinesFromJson(response.body['tontines']));
        _pendingLoaded = true;
        update();
      }else{
        ApiChecker.CheckApi(response);
      }
    }
  }

  getRunningTontines(bool reload) async{
    if(_runningTontines == null || reload){
      Response response = await farisTontineRepo.getRunningTontines();
      if(response.statusCode == 200){
        _runningTontines = [];
        _runningTontines!.addAll(tontinesFromJson(response.body['tontines']));
        _runningLoaded = true;
        update();
      }else{
        ApiChecker.CheckApi(response);
      }
    }
  }

  getDoneTontines(bool reload) async {
    if(_doneTontines == null || reload){
      Response response = await farisTontineRepo.getFinishedTontines();
      if(response.statusCode == 200){
        _doneTontines = [];
        _doneTontines!.addAll(tontinesFromJson(response.body['tontines']));
        _doneLoaded = true;
        update();
      }else{
        ApiChecker.CheckApi(response);
      }
    }
  }

  searchTontine(String numero) async {
    _searchLoading = true;
    update();
    Response response = await farisTontineRepo.searchTontine(numero);
    if (response.statusCode == 200) {
      _searchLoading = false;
      _searchHasError = false;
      _searchTontines = [];
      _searchTontines.addAll(tontinesFromJson(response.body['tontines']));
      update();
    } else {
      _searchHasError = true;
      _searchLoading = false;
      print(response.statusCode);
      if (response.statusCode == 500) {
        _appErrorType = AppErrorType.api;
      }
      update();
    }
  }

  resetSearch(){
    _searchTontines.clear();
    update();
  }

}