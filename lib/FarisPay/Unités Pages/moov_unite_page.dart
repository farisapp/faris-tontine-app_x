import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'Moov_unite_payment_details_page.dart';

class MoovUnitePage extends StatefulWidget {
  @override
  _MoovUnitePageState createState() => _MoovUnitePageState();
}

class _MoovUnitePageState extends State<MoovUnitePage> {
  List<Map<String, dynamic>> plans = [];
  bool isLoading = false;
  String today = "";

  @override
  void initState() {
    super.initState();
    today = _getTodayInFrench();
    _checkAndUpdateData();
  }

  /// Vérifie si un forfait est disponible aujourd'hui
  bool _isAvailableToday(String? joursDispoJson) {
    if (joursDispoJson == null || joursDispoJson.isEmpty) {
      debugPrint("⚠️ JoursDispo est vide ou null");
      return false;
    }

    try {
      List<String> joursDispo = List<String>.from(json.decode(joursDispoJson));

      debugPrint("📅 Vérification de la disponibilité : Aujourd'hui ($today) vs Disponibilité ($joursDispo)");

      return joursDispo.contains(today);
    } catch (e) {
      debugPrint("❌ Erreur de parsing JSON pour JoursDispo: $e | Valeur reçue: $joursDispoJson");
      return false;
    }
  }

  /// Extraction du montant depuis la description si non fourni
  int? extractAmountFromDescription(String description) {
    RegExp regex = RegExp(r'(\d+)\s*F', caseSensitive: false);
    Match? match = regex.firstMatch(description);

    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  /// Formate le titre en mettant en rouge et gras les valeurs numériques suivies de `%` ou `Min`
  List<TextSpan> _buildStyledTitle(String title) {
    final match = RegExp(r'(\d+)\s*(%|Min)').firstMatch(title);

    if (match != null) {
      final number = match.group(1)!;
      final unit = match.group(2)!;
      final before = title.substring(0, match.start);
      final after = title.substring(match.end);

      return [
        TextSpan(
          text: before,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        TextSpan(
          text: "$number $unit",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        TextSpan(
          text: after,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ];
    }

    return [
      TextSpan(
        text: title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
    ];
  }
  /// Regroupe et trie les forfaits par type (`Forfait_type`)
  Map<String, List<Map<String, dynamic>>> groupAndSortPlansByType() {
    Map<String, List<Map<String, dynamic>>> groupedPlans = {};

    // Regrouper les forfaits par type
    for (var plan in plans) {
      String type = plan['type'] ?? 'Autre';
      groupedPlans.putIfAbsent(type, () => []).add(plan);
    }

    // Définir l'ordre souhaité, avec "FORFAITS BONUS" en premier
    const List<String> orderedTypes = [
      "FORFAITS BONUS",
      "FORFAITS CLASSIQUES",
      "PASS MIX SONS YAM",
      "PASS MIX SONS YAM TOUS RESEAUX",
      "SONS YAM PASS INTERNATIONAUX",
      "PASS MIX SONS YAM PLUS",
      "FORFAIT NANAN SMART",
      "FORFAITS MAGIQUES",
      "FORFAITS INTERNATIONAUX",
      "PASS A SOUSCRIRE",
    ];

    // Trier les forfaits en suivant cet ordre
    Map<String, List<Map<String, dynamic>>> sortedGroupedPlans = {
      for (var type in orderedTypes)
        if (groupedPlans.containsKey(type)) type: groupedPlans[type]!,
    };

    // Ajouter les éventuels types non listés pour ne pas les ignorer
    for (var type in groupedPlans.keys) {
      if (!sortedGroupedPlans.containsKey(type)) {
        sortedGroupedPlans[type] = groupedPlans[type]!;
      }
    }

    return sortedGroupedPlans;
  }
  /// Charge les données locales et met à jour la liste des plans
  Future<void> _loadLocalData() async {
    List<Map<String, dynamic>> localPlans = await _loadPlansFromLocal();
    setState(() {
      plans = localPlans.isNotEmpty ? localPlans : [];
    });
  }

  /// Sauvegarde les plans localement
  Future<void> _savePlansLocally(List<Map<String, dynamic>> plans) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('MoovUnitePlans', json.encode(plans));
  }

  /// Récupère les forfaits stockés localement
  Future<List<Map<String, dynamic>>> _loadPlansFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final plansJson = prefs.getString('MoovUnitePlans');
    if (plansJson != null) {
      return List<Map<String, dynamic>>.from(json.decode(plansJson));
    }
    return [];
  }

  /// Récupère les forfaits depuis l'API
  Future<void> fetchPlansFromAPI() async {
    if (isLoading) return;

    const String url = "https://apps.farisbusinessgroup.com/api/get_unites.php";
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
          List<dynamic> data = jsonResponse['data'];

          List<Map<String, dynamic>> fetchedPlans = data
              .where((plan) => plan['Operateur'] == 'Moov' && plan['isAvailable'] == 1)
              .map((plan) {
            int? amount = int.tryParse(plan['Montant']?.toString() ?? "");

            if (amount == null || amount == 0) {
              amount = extractAmountFromDescription(plan['Description']);
            }

            return {
              'id': plan['Reference'],
              'title': plan['Titre'],
              'description': plan['Description'],
              'amount': amount,
              'JoursDispo': plan['JoursDispo'],
              'reference': plan['Reference'],
              'type': plan['Forfait_type'] ?? "Autre",
            };
          }).toList();

          setState(() {
            plans = fetchedPlans;
          });

          await _savePlansLocally(fetchedPlans);
        } else {
          throw Exception("Structure inattendue dans la réponse de l'API.");
        }
      } else {
        throw Exception("Erreur : ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mode hors connexion')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Vérifie si une mise à jour est nécessaire et charge les données locales si possible
  Future<void> _checkAndUpdateData() async {
    final prefs = await SharedPreferences.getInstance();
    String? lastUpdatedDate = prefs.getString('lastUpdatedDateMoovUnite');
    String todayDate = _getTodayDate();

    await _loadLocalData();

    if (lastUpdatedDate == null || lastUpdatedDate != todayDate) {
      await fetchPlansFromAPI();
      prefs.setString('lastUpdatedDateMoovUnite', todayDate);
    }
  }

  String _getTodayInFrench() {
    const days = ["lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"];
    return days[DateTime.now().weekday - 1];
  }

  String _getTodayDate() {
    DateTime now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  @override
  @override
  Widget build(BuildContext context) {
    // Regrouper et trier les forfaits par type avant l'affichage
    final groupedPlans = groupAndSortPlansByType();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Forfaits unités Moov du $today",
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: isLoading ? null : fetchPlansFromAPI,
              child: const Text('Actualiser la liste'),
            ),
          ),
          Expanded(
            child: ListView(
              children: groupedPlans.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre de la catégorie (Forfait_type)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        entry.key, // Nom du type de forfait (Forfait_type)
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                    ...entry.value.map((plan) => Card(
                      margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
                      child: ListTile(
                        leading: Image.asset(
                          "assets/images/moov_logo.png",
                          width: 30,
                          height: 30,
                        ),
                        title: RichText(
                          text: TextSpan(children: _buildStyledTitle(plan['title'])),
                        ),
                        subtitle: Text(plan['description'].replaceAll(" a ", " à ")), // Remplace " a " par " à "
                        trailing: plan['amount'] != null
                            ? Text(
                          "${plan['amount']} FCFA",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        )
                            : null,
                        onTap: () {
                          if (!_isAvailableToday(plan['JoursDispo'])) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("❌ Ce forfait n'est pas disponible aujourd'hui"),
                                backgroundColor: Colors.orangeAccent,
                              ),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MoovUnitePaymentDetailsPage(
                                offerTitle: plan['title'],
                                description: plan['description'].replaceAll(" a ", " à "),
                                validity: plan['JoursDispo'],
                                reference: plan['reference'],
                                predefinedAmount: (plan['amount'] ?? 0).toString(),
                                phoneNumber: "",
                              ),
                            ),
                          );
                        },
                      ),
                    ))
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

}
