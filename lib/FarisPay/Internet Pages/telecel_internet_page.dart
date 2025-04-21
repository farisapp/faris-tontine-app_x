import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'Telecel_internet_payment_details_page.dart';

class TelecelInternetPage extends StatefulWidget {
  @override
  _TelecelInternetPageState createState() => _TelecelInternetPageState();
}

// Mise à jour de la regex pour inclure les décimales (ex: 3.3Go)
List<TextSpan> _buildStyledDescription(String description) {
  final match = RegExp(r"(\d+(?:\.\d+)?)(Go|Mo)").firstMatch(description);

  if (match != null) {
    final dataVolume = match.group(0)!; // Exemple : "3.3Go"
    final before = description.substring(0, match.start);
    final after = description.substring(match.end);

    return [
      TextSpan(
        text: before,
        style: const TextStyle(color: Colors.black),
      ),
      TextSpan(
        text: dataVolume,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
      TextSpan(
        text: after,
        style: const TextStyle(color: Colors.black),
      ),
    ];
  }

  return [
    TextSpan(
      text: description,
      style: const TextStyle(color: Colors.black),
    ),
  ];
}

class _TelecelInternetPageState extends State<TelecelInternetPage> {
  List<Map<String, dynamic>> plans = [];
  bool isLoading = false;
  String today = "";

  @override
  @override
  void initState() {
    super.initState();
    today = _getTodayInFrench();
    _checkAndUpdateData(); // ✅ Gère la mise à jour 1 fois par jour
  }

  Future<void> _checkAndUpdateData() async {
    final prefs = await SharedPreferences.getInstance();
    String? lastUpdatedDate = prefs.getString('lastUpdatedDateTelecelInternet'); // ✅ Clé unique pour Telecel
    String todayDate = _getTodayDate();

    await _TelecelinternetloadLocalData();

    if (lastUpdatedDate == null || lastUpdatedDate != todayDate) {
      await fetchInternetPlansFromAPI();
      prefs.setString('lastUpdatedDateTelecelInternet', todayDate); // ✅ Mise à jour
    }
  }

  String _getTodayDate() {
    DateTime now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  bool _hasBonusToday(String? joursBonusJson) {
    if (joursBonusJson == null || joursBonusJson.isEmpty) {
      return false;
    }
    List<String> joursBonus = [];
    try {
      joursBonus = json.decode(joursBonusJson).cast<String>();
    } catch (e) {
      return false;
    }
    return joursBonus.contains(today);
  }

  bool _isBonusDay() {
    return plans.any((plan) => _hasBonusToday(plan['JourBonus']));
  }

  Future<void> _TelecelinternetloadLocalData() async {
    List<Map<String, dynamic>> TelecelinternetlocalPlans =
    await TelecelloadPlansFromLocal();
    setState(() {
      plans = TelecelinternetlocalPlans.isNotEmpty
          ? TelecelinternetlocalPlans
          : _TelecelloadDefaultPlans();
    });
  }

  Future<void> TelecelsavePlansLocally(List<Map<String, dynamic>> plans) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('TelecellocalPlans', json.encode(plans));
  }

  Future<List<Map<String, dynamic>>> TelecelloadPlansFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final plansJson = prefs.getString('TelecellocalPlans');
    if (plansJson != null) {
      return List<Map<String, dynamic>>.from(json.decode(plansJson));
    }
    return [];
  }

  List<Map<String, dynamic>> _TelecelloadDefaultPlans() {
    return [];
  }

  Future<void> fetchInternetPlansFromAPI() async {
    const String url = "https://apps.farisbusinessgroup.com/api/get_forfaits.php";

    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
          List<dynamic> data = jsonResponse['data'];

          List<Map<String, dynamic>> fetchedPlans = data
              .where((plan) =>
          plan['Operateur'] == 'Telecel' && plan['isAvailable'] == 1)
              .map((plan) {
            bool hasBonus = _hasBonusToday(plan['JourBonus'] ?? "[]");
            String forfaitType = plan['Forfait_type'] ?? "Type inconnu";
            // Pour certains types, ne pas appliquer le formatage bonus
            bool applyBonus = hasBonus &&
                forfaitType != "FORFAITS NUIT" &&
                forfaitType != "FORFAIT INTERNET SPECIAL";
            String title = applyBonus
                ? _applyBonus(plan['Titre'] ?? "", plan['JourBonus'] ?? "[]")
                : (plan['Titre'] ?? "Titre inconnu");

            return {
              'id': plan['Reference'] ?? "0",
              'title': title,
              'description': applyBonus
                  ? (plan['Description_Bonus'] ??
                  "Description Bonus indisponible")
                  : (plan['Description'] ?? "Description indisponible"),
              'amount': int.tryParse(plan['Montant']?.toString() ?? "0") ?? 0,
              'validity': _formatValidity(plan['JoursDispo'] ?? "[]"),
              'reference': plan['Reference'] ?? "Référence inconnue",
              'type': forfaitType,
            };
          }).toList();

          setState(() {
            plans = fetchedPlans;
          });

          await TelecelsavePlansLocally(fetchedPlans);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Liste mise à jour avec succès !')),
          );
        } else {
          throw Exception("Structure inattendue dans la réponse de l'API.");
        }
      } else {
        throw Exception("Erreur : ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mode sans connexion')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Map<String, List<Map<String, dynamic>>> groupAndSortPlansByType() {
    Map<String, List<Map<String, dynamic>>> groupedPlans = {};

    for (var plan in plans) {
      String type = plan['type'] ?? 'Autre';

      if (type == "Forfaits Internet Promo") {
        type = "FORFAITS INTERNET PROMO";
      }

      groupedPlans.putIfAbsent(type, () => []).add(plan);
    }

    List<String> sortedKeys = groupedPlans.keys.toList();
    sortedKeys.sort((a, b) {
      if (a == "FORFAITS INTERNET PROMO") return -1;
      if (b == "FORFAITS INTERNET PROMO") return 1;
      return a.compareTo(b);
    });

    return {for (var key in sortedKeys) key: groupedPlans[key]!};
  }

  String _getTodayInFrench() {
    const days = [
      "lundi",
      "mardi",
      "mercredi",
      "jeudi",
      "vendredi",
      "samedi",
      "dimanche"
    ];
    return days[DateTime.now().weekday - 1];
  }

  String _formatValidity(String? joursDispo) {
    if (joursDispo == null || joursDispo.isEmpty) {
      return "Validité inconnue";
    }
    try {
      List<String> jours = json.decode(joursDispo).cast<String>();
      return "Validité : ${jours.join(', ')}";
    } catch (e) {
      return "Validité inconnue";
    }
  }

  String _applyBonus(String title, String joursBonusJson) {
    List<String> joursBonus = [];
    try {
      joursBonus = json.decode(joursBonusJson).cast<String>();
    } catch (e) {
      debugPrint('Erreur de parsing de JourBonus : $e');
      return title;
    }

    if (joursBonus.contains(today)) {
      final match = RegExp(r"(\d+(?:\.\d+)?)(Go|Mo)").firstMatch(title);
      if (match != null) {
        final volume = double.parse(match.group(1)!);
        final unit = match.group(2);

        String formattedVolume =
        volume % 1 == 0 ? volume.toInt().toString() : volume.toString();

        return "$formattedVolume$unit+$formattedVolume$unit (Bonus 100%)";
      }
    }
    return title;
  }

  @override
  Widget build(BuildContext context) {
    final groupedPlans = groupAndSortPlansByType();
    final bool isBonusDay = _isBonusDay();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.card_giftcard,
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Bonus internet de ce $today",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          if (isBonusDay)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Jour de Bonus!!!",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: fetchInternetPlansFromAPI,
              child: const Text(
                  'Cliquez ici pour actualiser la liste (en ligne)'),
            ),
          ),
          Expanded(
            child: ListView(
              children: groupedPlans.entries.map((entry) {
                String type = entry.key;
                List<Map<String, dynamic>> plansForType = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        type,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    ...plansForType.map((plan) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: ListTile(
                          leading: Image.asset(
                            'assets/images/telecel.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                          title: RichText(
                            text: TextSpan(
                              children: _buildStyledTitle(plan['title']),
                            ),
                          ),
                          subtitle: RichText(
                            text: TextSpan(
                              children: _buildStyledDescription(
                                  plan['description']),
                            ),
                          ),
                          trailing: Text(
                            "${plan['amount']} FCFA",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TelecelPaymentDetailsPage(
                                      offerTitle: plan['title'],
                                      description: plan['description'],
                                      price: plan['amount'].toString(),
                                      validity: plan['validity'],
                                      phoneNumber: "",
                                      reference: plan['reference'],
                                    ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Mise à jour de la regex pour inclure les décimales dans le titre
  List<TextSpan> _buildStyledTitle(String title) {
    final match = RegExp(r"(\d+(?:\.\d+)?)(Go|Mo)\+(\d+(?:\.\d+)?)(Go|Mo)")
        .firstMatch(title);

    if (match != null) {
      final mainVolume = match.group(1);
      final mainUnit = match.group(2);
      final bonusVolume = match.group(3);
      final bonusUnit = match.group(4);
      final isBonusIncluded = title.contains("Bonus 100%");

      return [
        TextSpan(
          text: mainVolume,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        TextSpan(
          text: mainUnit,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const TextSpan(
          text: '+',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextSpan(
          text: bonusVolume,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        TextSpan(
          text: bonusUnit,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        if (isBonusIncluded)
          const TextSpan(
            text: " (Bonus 100%)",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
      ];
    }

    return [
      TextSpan(
        text: title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    ];
  }
}
