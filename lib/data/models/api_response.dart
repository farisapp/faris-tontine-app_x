import 'dart:convert';

import 'package:get/get_connect/http/src/response/response.dart'; // à importer si pas déjà fait

class ApiResponse {
  final bool isSuccess;
  final String message;

  ApiResponse({required this.isSuccess, required this.message});

  static ApiResponse fromResponse(Response response) {
    if (response.statusCode == 200) {
      return ApiResponse(isSuccess: true, message: "Success");
    } else {
      return ApiResponse(isSuccess: false, message: response.body.toString());
    }
  }

  // ✅ Méthode personnalisée pour le cas "updateBlockStatus"
  static ApiResponse fromCustomResponse(Response response) {
    try {
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.bodyString ?? response.body.toString());

        if (decoded is Map<String, dynamic>) {
          return ApiResponse(
            isSuccess: decoded["status"] == true,
            message: decoded["message"] ?? "Aucune réponse",
          );
        } else {
          return ApiResponse(isSuccess: false, message: "Format de réponse inattendu.");
        }
      } else {
        return ApiResponse(isSuccess: false, message: "Erreur HTTP: ${response.statusCode}");
      }
    } catch (e) {
      return ApiResponse(isSuccess: false, message: "Erreur lors du parsing: ${e.toString()}");
    }
  }
}
