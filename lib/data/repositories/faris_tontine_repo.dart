import 'package:faris/data/models/body/RetraitBody.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:faris/common/app_constant.dart';
import 'package:faris/data/core/api_client.dart';
import 'package:faris/data/models/body/cotiser_body.dart';
import 'package:faris/data/models/body/membre_body.dart';
import 'package:faris/data/models/body/tontine_body.dart';

class FarisTontineRepo {

  final ApiClient apiClient;

  FarisTontineRepo({required this.apiClient});

  Future<Response> createTontine(TontineBody tontineBody) async {
    return await apiClient.postData('${AppConstant.TONTINE_CREATE_URI}', tontineBody.toJson());
  }

  Future<Response> updateTontine(int id, TontineBody tontineBody) async {
    return await apiClient.putData('${AppConstant.TONTINE_CREATE_URI}/$id', tontineBody.toJson());
  }

    Future<Response> cotiserTontine(CotiserBody cotiserBody) async {
    return await apiClient.postData(
        '${AppConstant.TONTINE_COTISER_DIRECTEMENT_VIA_OM_URI}',
        cotiserBody.toJson());
  }

  Future<Response> cotiserTontineMoov(CotiserBody cotiserBody) async {

      print("url call payment MOOV");
    return await apiClient.postData(
        '${AppConstant.CHECK_PAYMENT_MOOV}',
        cotiserBody.toJson());
  }
  

  Future<Response> addMembre(MembreBodyList membreBodyList, int id) async {
    return await apiClient.postData('${AppConstant.TONTINE_MEMBRE_URI}$id/membres', membreBodyList.toJson());
  }

  Future<Response> deleteMembre(int? userId, int? tontineId) async {
    return await apiClient.deleteData('${AppConstant.TONTINE_MEMBRE_URI}$tontineId/membres/$userId');
  }

  Future<Response> updateTontineStatus(int id, String status) async {
    return await apiClient.postData('${AppConstant.TONTINE_UPDATE_STATUS_URI}$id/status', {'statut': status});
  }

  Future<Response> getLastTontines() async {
    return await apiClient.getData('${AppConstant.TONTINE_LAST_URI}?limit=10&offset=1');
  }

  Future<Response> getTontines() async {
    return await apiClient.getData('${AppConstant.TONTINE_LIST_URI}?limit=50&offset=1');
  }

  Future<Response> getPendingTontines() async {
    return await apiClient.getData('${AppConstant.TONTINE_PENDING_URI}?limit=10&offset=1');
  }

  Future<Response> getRunningTontines() async {
    return await apiClient.getData('${AppConstant.TONTINE_RUNNING_URI}?limit=10&offset=1');
  }

  Future<Response> getFinishedTontines() async {
    return await apiClient.getData('${AppConstant.TONTINE_FINISH_URI}?limit=10&offset=1');
  }

  Future<Response> getTontineDetails(int id) async {
    return await apiClient.getData('${AppConstant.TONTINE_LIST_URI}/$id');
  }

  Future<Response> searchTontine(String numero) async {
    return await apiClient.getData('${AppConstant.TONTINE_SEARCH_URI}?numero=$numero');
  }

  Future<Response> sendRequest(int id, String type) async {
    return await apiClient.postData('${AppConstant.TONTINE_LIST_URI}/$id/send-request', {'type': type});
  }

  Future<Response> getTontineRequetes(int id) async {
    return await apiClient.getData('${AppConstant.TONTINE_LIST_URI}/$id/requetes');
  }

  Future<Response> acceptOrRejectRequest(int requestId, String status) async {
    return await apiClient.postData('${AppConstant.TONTINE_LIST_URI}/confirm-request', {'request_id': requestId, 'statut': status});
  }

  Future<Response> getTontineMembres(int id) async {
    return await apiClient.getData('${AppConstant.TONTINE_MEMBRE_URI}$id/membres');
  }

  Future<Response> getUserTontineEtats(int id, int user_id) async {
    return await apiClient.getData('${AppConstant.TONTINE_MEMBRE_URI}$id/membres/$user_id');
  }

  Future<Response> getTontineCotisations(int id, {int period = 0}) async {
    return await apiClient.getData('${AppConstant.TONTINE_COTISATION_LIST_URI}$id/cotisations?period=$period');
  }

  Future<Response> getTontinePeriodicites(int id) async {
    return await apiClient.getData('${AppConstant.TONTINE_PERIODICITE_LIST_URI}$id/periodicites');
  }

  Future<Response> getTontineStats(int id) async {
    return await apiClient.getData('${AppConstant.TONTINE_STATS_LIST_URI}$id/stats');
  }

  Future<Response> getTontinePeriodicitesWithCotisation(int id) async {
    return await apiClient.getData('${AppConstant.TONTINE_PERIODICITE_LIST_URI}$id/periodicites?withCotisation=1');
  }

  Future<Response> getTontinePeriodicitesToPaid(int id) async {
    return await apiClient.getData('${AppConstant.TONTINE_PERIODICITE_TO_PAID_LIST_URI}$id/topaid');
  }

  Future<Response> deleteTontine(int id) async {
    return await apiClient.deleteData('${AppConstant.TONTINE_LIST_URI}/$id');
  }

  Future<Response> sendCreditRequest(RetraitBody retraitBody) async {
    return await apiClient.postData('${AppConstant.TONTINE_RETIRER_URI}', retraitBody.toJson());
  }

}