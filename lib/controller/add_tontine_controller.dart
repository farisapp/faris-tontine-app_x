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

class AddTontineController extends GetxController implements GetxService {
  final FarisTontineRepo farisTontineRepo;

  List<String> _periodicites = ["JOURNALIERE", "HEBDOMADAIRE", "MENSUELLE", "TRIMESTRIELLE"];
  List<int> _nbrePersonnes = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];
  List<int> _dureePeriod = [1];
  List<String> _typeTontines = ["TONTINE EN GROUPE"];
  List<bool> isPublic = [true, false];

  String _selectedPeriodicite = "JOURNALIERE";
  int _selectedNbrePersonne = 2;
  int _selectedDureePeriod = 1;
  int _periodiciteValue = 1;
  String _type = "TONTINE EN GROUPE";
  String _dureeString = "";
  DateTime _beginDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  List<User> _membres = [];
  double _montantRamassage = 0;
  double _progress = 0.0;
  double _montantMise = 0.0;
  double _taux = 3.9;
  bool _createfinished = false;

  AddTontineController({required this.farisTontineRepo});

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
    if (response.statusCode == 200 || response.statusCode == 201) {
      _createfinished = true;
      responseModel = ResponseModel(true, response.body['code']);
      Get.find<TontineController>().getTontines(true);
      Get.find<LastTontineController>().getLastTontine(true);
    } else {
      responseModel = ResponseModel(false, response.statusText);
      _createfinished = true;
    }
    update();
    return responseModel;
  }

  Future<ResponseModel> updateTontine(int id, TontineBody tontineBody) async {
    Response response = await farisTontineRepo.updateTontine(id, tontineBody);
    ResponseModel responseModel;
    if (response.statusCode == 200 || response.statusCode == 201) {
      _createfinished = true;
      responseModel = ResponseModel(true, response.body['code']);
      Get.find<TontineDetailsController>().getTontineDetails(id, true);
      Get.find<TontineController>().getTontines(true);
      Get.find<LastTontineController>().getLastTontine(true);
      Get.find<TontineDetailsController>().getTontinePeriodicites(id, true);
    } else {
      responseModel = ResponseModel(false, response.statusText);
      _createfinished = true;
    }
    update();
    return responseModel;
  }

  void resetForm() {
    _periodiciteValue = 1;
    _beginDate = DateTime.now();
    _endDate = DateTime.now();
    _selectedPeriodicite = "JOURNALIERE";
    _selectedNbrePersonne = 2;
    _type = "TONTINE EN GROUPE";
    _dureeString = "";
    _membres = [];
    _montantRamassage = 0;
    _progress = 0.0;
    _montantMise = 0.0;
    update();
  }

  void changePeriodicite(String newValue) {
    _selectedPeriodicite = newValue;
    if (newValue == "JOURNALIERE") {
      _periodiciteValue = 1;
    } else if (newValue == "HEBDOMADAIRE") {
      _periodiciteValue = 7;
    } else if (newValue == "MENSUELLE") {
      _periodiciteValue = 30;
    } else if (newValue == "TRIMESTRIELLE") {
      _periodiciteValue = 90;
    }
    calculEndDate();
    update();
  }

  void changeNbrePersonne(int newValue) {
    _selectedNbrePersonne = newValue;
    calculMontantRamassage();
    calculEndDate();
    update();
  }

  void changeDureePeriod(int newValue) {
    _selectedDureePeriod = newValue;
    calculMontantRamassage();
    calculEndDate();
    update();
  }

  void changeType(String newValue) {
    _type = newValue;
    if (_type == "EPARGNE INDIVIDUELLE") {
      _selectedNbrePersonne = 1;
      _selectedDureePeriod = 3;
    } else {
      _selectedNbrePersonne = 2;
    }
    calculMontantRamassage();
    calculEndDate();
    update();
  }

  void setSelectedBeginDate(DateTime picked) {
    _beginDate = picked;
    calculEndDate();
    update();
  }

  void setSelectedEndDate(DateTime picked) {
    _endDate = picked;
    calculEndDate();
    update();
  }

  void setMontantMise(String montant) {
    if (montant.isNotEmpty) {
      var value = double.tryParse(montant);
      if (value != null) {
        _montantMise = double.parse(montant);
        update();
      }
    }
    calculMontantRamassage();
  }

  void addToMemberList(List<User> memberList) {
    for (var membre in memberList) {
      if (_membres.length >= _selectedNbrePersonne) break;
      if (!_membres.any((m) => m.telephone == membre.telephone)) {
        _membres.add(membre);
      }
    }
    calculMontantRamassage();
    calculEndDate();
    update();
  }

  void removeToMemberList(User membre) {
    _membres.remove(membre);
    calculMontantRamassage();
    calculEndDate();
    update();
  }

  void calculMontantRamassage() {
    _montantRamassage = _montantMise * _selectedNbrePersonne * _selectedDureePeriod;
    update();
  }

  bool dateIsNow(DateTime date) {
    var today = Jiffy.parse("${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}");
    var compare = Jiffy.parse("${date.year}-${date.month}-${date.day}");
    return today.isSame(compare);
  }

  void calculEndDate({String? type, String? periodicite, int? membreCount, DateTime? begin}) {
    if (_selectedPeriodicite.isNotEmpty) {
      int duree = _periodiciteValue * _selectedNbrePersonne;
      _endDate = _beginDate.add(Duration(days: duree - 1));

      final int nbJours = Jiffy.parse(_endDate.toString())
          .diff(Jiffy.parse(_beginDate.toString()), unit: Unit.day).toInt() + 1;

      _dureeString = "$nbJours ${Common.pluralize(nbJours, "Jour")}";
      _progress = 1.0;
    } else {
      _endDate = DateTime.now();
      _progress = 0.0;
      _dureeString = "";
    }
    update();
  }
}
