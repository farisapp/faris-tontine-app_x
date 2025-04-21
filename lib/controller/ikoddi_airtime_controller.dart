import 'dart:convert';

import 'package:faris/data/models/ikoddi_airtime_models/airtime_history_model.dart';
import 'package:faris/data/models/ikoddi_airtime_models/ikoddi_airtime_model.dart';
import 'package:faris/data/repositories/ikoddi_airtime_repository.dart';
import 'package:get/get.dart';
import 'package:faris/data/core/api_checker.dart';

import '../data/models/response_model.dart';

class IkoddiAirtimeController extends GetxController implements GetxService {
  final IkkodiAirtimeRepository ikoddiAirtimeRepository;

  IkoddiAirtimeController({required this.ikoddiAirtimeRepository});
  bool _processFinished = false;

  List<IkoddiForfaitModel>? _internetPlanList;
  List<IkoddiForfaitModel>? get internetPlanList => _internetPlanList;

  List<BuyAirtimeHistoryModel>? _buyAirtimeHistoryList;
  List<BuyAirtimeHistoryModel>? get buyAirtimeHistoryList =>
      _buyAirtimeHistoryList;

  bool get processFinished => _processFinished;

  List<IkoddiForfaitModel>? _mobileCreditPlanList;
  List<IkoddiForfaitModel>? get mobileCreditPlanList => _mobileCreditPlanList;

  Future<List<BuyAirtimeHistoryModel>?> getBuyAirtimeHistoryList() async {
    Response response =
        await ikoddiAirtimeRepository.getBuyAirtimeHistoryList();
    if (response.statusCode == 200) {
      _buyAirtimeHistoryList = [];
      List<dynamic> buyAirtimeHistoryList = response.body;
      buyAirtimeHistoryList.forEach((internetPlan) => _buyAirtimeHistoryList!
          .add(BuyAirtimeHistoryModel.fromJson(internetPlan)));
    } else {
      ApiChecker.CheckApi(response);
    }
    update();

    return _buyAirtimeHistoryList;
  }

  Future<List<IkoddiForfaitModel>> getInternetPlansList() async {
    List<IkoddiForfaitModel> _internetPlanList = [];

    Response response = await ikoddiAirtimeRepository.getInternetPlansList();
    if (response.statusCode == 200) {
      List<dynamic> _internetPlans = jsonDecode(response.body);
      _internetPlans.forEach((internetPlan) =>
          _internetPlanList.add(IkoddiForfaitModel.fromJson(internetPlan)));
    } else {
      ApiChecker.CheckApi(response);
    }
    update();

    return _internetPlanList;
  }

  Future<List<IkoddiForfaitModel>> getMobileCreditPlansList() async {
    List<IkoddiForfaitModel> _mobileCreditPlanList = [];

    Response response =
        await ikoddiAirtimeRepository.getMobileCreditPlansList();

    if (response.statusCode == 200) {
      List<dynamic> _mobileCreditPlans = jsonDecode(response.body);

      _mobileCreditPlans.forEach((mobileCreditPlan) {
        _mobileCreditPlanList
            .add(IkoddiForfaitModel.fromJson(mobileCreditPlan));
      });
    } else {
      ApiChecker.CheckApi(response);
    }
    update();
    return _mobileCreditPlanList;
  }

  Future<ResponseModel> buyAirtime(Map<String, dynamic> buyAirtimeData) async {
    Response response =
        await ikoddiAirtimeRepository.buyAirtime(buyAirtimeData);
    ResponseModel responseModel;
    if (response.statusCode == 200 || response.statusCode == 201) {
      _processFinished = true;
      responseModel = ResponseModel(true, response.body['message']);
    } else {
      responseModel = ResponseModel(false, response.body['error']);
      _processFinished = true;
    }
    update();
    return responseModel;
  }
}
