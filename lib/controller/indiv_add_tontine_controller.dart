import 'package:faris/controller/last_tontine_controller.dart';
import 'package:faris/controller/tontine_controller.dart';
import 'package:faris/controller/tontine_details_controller.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:faris/common/common.dart';
import 'package:faris/data/models/body/tontine_body.dart';
import 'package:faris/data/models/response_model.dart';
import 'package:faris/data/models/user_model.dart';
import 'package:faris/data/repositories/faris_tontine_repo.dart';

class IndivAddTontineController extends GetxController implements GetxService {
  final FarisTontineRepo farisTontineRepo;

  List<String> _periodicites = ["JOURNALIERE", "HEBDOMADAIRE", "MENSUELLE", "TRIMESTRIELLE"];
  List<int> _nbrePersonnes = [1];
  List<int> _dureePeriod = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30];
  List<String> _typeTontines = ["EPARGNE INDIVIDUELLE"];
  String _selectedPeriodicite = "JOURNALIERE";
  int _selectedNbrePersonne = 1;
  int _selectedDureePeriod = 3;
  int _periodiciteValue = 1;
  String _type = "EPARGNE INDIVIDUELLE";
  String _dureeString = "";
  DateTime _beginDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  List<User> _membres = [];
  double _montantRamassage = 0;
  double _progress = 0.0;
  double _montantMise = 0.0;
  double _taux = 3.9;
  bool _createfinished = false;
  bool isPublic = false;

  IndivAddTontineController({required this.farisTontineRepo});

  String get selectedPeriodicite => _selectedPeriodicite;
  int get selectedNbrePersonne => _selectedNbrePersonne;
  int get selectedDureePeriod => _selectedDureePeriod;
  int get periodiciteValue => _periodiciteValue;
  String get type => _type;
  String get dureeString => _dureeString;
  DateTime get beginDate => _beginDate;
  DateTime get endDate => _endDate;
  List<User> get membres => _membres;
  List<String> get periodicites => _periodicites;
  List<String> get typeTontines => _typeTontines;
  List<int> get nbrePersonnes => _nbrePersonnes;
  List<int> get dureePeriod => _dureePeriod;
  double get montantRamassage => _montantRamassage;
  double get montantMise => _montantMise;
  double get taux => _taux;
  double get progress => _progress;
  bool get createfinished => _createfinished;

  @override
  void onInit() {
    initJiffy();
    super.onInit();
  }

  initJiffy() async {
    await Jiffy.setLocale("fr");
  }

  Future<ResponseModel> createTontine(TontineBody tontineBody) async {
    Response response = await farisTontineRepo.createTontine(tontineBody);
    ResponseModel responseModel;
    if(response.statusCode == 200 || response.statusCode == 201){
      _createfinished = true;
      responseModel = ResponseModel(true, response.body['code']);
      Get.find<TontineController>().getTontines(true);
      Get.find<LastTontineController>().getLastTontine(true);
    }else{
      responseModel = ResponseModel(false, response.statusText);
      _createfinished = true;
    }
    update();
    return responseModel;
  }

  Future<ResponseModel> updateTontine(int id, TontineBody tontineBody) async {
    Response response = await farisTontineRepo.updateTontine(id, tontineBody);
    ResponseModel responseModel;
    if(response.statusCode == 200 || response.statusCode == 201){
      _createfinished = true;
      responseModel = ResponseModel(true, response.body['code']);
      Get.find<TontineDetailsController>().getTontineDetails(id, true);
      Get.find<TontineController>().getTontines(true);
      Get.find<LastTontineController>().getLastTontine(true);
      Get.find<TontineDetailsController>().getTontinePeriodicites(id, true);
    }else{
      responseModel = ResponseModel(false, response.statusText);
      _createfinished = true;
    }
    update();
    return responseModel;
  }

  void resetForm(){
    _periodiciteValue = 1;
    _beginDate = DateTime.now();
    _endDate = DateTime.now();
    _selectedPeriodicite = "JOURNALIERE";
    _selectedNbrePersonne = 1;
    _type = "EPARGNE INDIVIDUELLE";
    _dureeString = "";
    _membres = [];
    _montantRamassage = 0;
    _progress = 0.0;
    _montantMise = 0.0;
    update();
  }

  changePeriodicite(String newValue){
    _selectedPeriodicite = newValue;
    if(newValue == "JOURNALIERE"){
      _periodiciteValue = 1;
    }else if(newValue == "HEBDOMADAIRE"){
      _periodiciteValue = 7;
    }else if(newValue == "MENSUELLE"){
      _periodiciteValue = 30;
    }else if(newValue == "TRIMESTRIELLE"){
      _periodiciteValue = 90;
    }
    calculEndDate();
    update();
  }

  changeNbrePersonne(int newValue){
    _selectedNbrePersonne = newValue;
    calculMontantRamassage();
    calculEndDate();
    update();
  }

  changeDureePeriod(int newValue){
    _selectedDureePeriod = newValue;
    calculMontantRamassage();
    calculEndDate();
    update();
  }

  changeType(String newValue){
    _type = newValue;
    if(_type == "EPARGNE INDIVIDUELLE" || _type == "INDIVIDUELLE"){
      _selectedNbrePersonne = 1;
      _selectedDureePeriod = 3;
    }else{
      _selectedNbrePersonne = 1;
    }
    calculMontantRamassage();
    calculEndDate();
    update();
  }

  setSelectedBeginDate(DateTime picked) {
    _beginDate = picked;
    calculEndDate();
    update();
  }

  setSelectedEndDate(DateTime picked) {
    _endDate = picked;
    calculEndDate();
    update();
  }

  setMontantMise(String montant){
    if(montant.isNotEmpty){
      var value = double.tryParse(montant);
      if(value != null){
        _montantMise = double.parse(montant);
        update();
      }
    }
    calculMontantRamassage();
  }

  void addToMemberList(List<User> memberList){
    memberList.forEach((membre) {
      if(membres.isNotEmpty){
        User m = membres.firstWhere((element) => element.telephone == membre.telephone, orElse: () => new User());
        if(m.telephone == null){
          membres.add(membre);
        }
      }else{
        membres.add(membre);
      }
    });
    calculEndDate();
    calculMontantRamassage();
    update();
  }

  void removeToMemberList(User membre){
    _membres.remove(membre);
    calculEndDate();
    calculMontantRamassage();
    update();
  }

  calculMontantRamassage(){
    _montantRamassage = _montantMise * _selectedNbrePersonne * _selectedDureePeriod;
    update();
  }

  dateIsNow(DateTime date){
    var j1 = Jiffy.parse("${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}").format(pattern: "yyyy-MM-dd");
    var j2 = Jiffy.parse("${date.year}-${date.month}-${date.day}").format(pattern: "yyyy-MM-dd");
    return Jiffy.parse(j1).isSame(Jiffy.parse(j2));
  }

  calculEndDate({String? type, String? periodicite, int? membreCount, DateTime? begin}){
    if(_selectedPeriodicite.isNotEmpty) {
      int duree = _periodiciteValue * (_selectedDureePeriod - 1);
      _endDate = _beginDate.add(Duration(days: duree));

      int diff = Jiffy.parse(_endDate.toString())
          .diff(Jiffy.parse(_beginDate.toString()), unit: Unit.day)
          .toInt() + 1;

      _dureeString = "$diff ${Common.pluralize(diff, "Jour")}";
      _progress = 1.0;
    } else {
      _endDate = DateTime.now();
      _progress = 0.0;
      _dureeString = "";
    }
    update();
  }
}