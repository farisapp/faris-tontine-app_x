import 'dart:convert';
import 'package:http/http.dart' as http;

class Tontine {
  final int id;
  final String numero;
  final String libelle;
  final bool isPublic;

  Tontine({
    required this.id,
    required this.numero,
    required this.libelle,
    required this.isPublic,
   });

  factory Tontine.fromJson(Map<String, dynamic> json) {
    return Tontine(
      id: json['id'],
      numero: json['numero'],
      libelle: json['libelle'],
      isPublic: json['isPublic'],
        );
  }
}

class TontineService {
  static const String baseUrl = 'https://apps.farisbusinessgroup.com/api/v1';

  /// Récupérer la liste des épargnes partagées
  static Future<List<Tontine>> getSharedTontines() async {
    final url = Uri.parse('$baseUrl/shared'); // Endpoint corrigé

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['error'] == false) {
          return List<Tontine>.from(
            data['tontines'].map((item) => Tontine.fromJson(item)),
          );
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception(
            'Erreur lors de la récupération des épargnes partagées : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de récupération : $e');
    }
  }
}
