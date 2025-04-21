import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'Moov_internet_payment_details_page.dart';

class MoovInternetPage extends StatefulWidget {
  @override
  _MoovInternetPageState createState() => _MoovInternetPageState();
}
List<TextSpan> _buildStyledDescription(String description) {
  // Regex pour détecter les données en Go ou Mo
  final match = RegExp(r"(\d+)(Go|Mo)").firstMatch(description);

  if (match != null) {
    final dataVolume = match.group(0)!; // Le texte correspondant (ex : 4Go)
    final before = description.substring(0, match.start); // Texte avant le match
    final after = description.substring(match.end); // Texte après le match

    return [
      TextSpan(
        text: before, // Partie avant le volume
        style: const TextStyle(color: Colors.black),
      ),
      TextSpan(
        text: dataVolume, // Le volume (4Go)
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
      TextSpan(
        text: after, // Partie après le volume
        style: const TextStyle(color: Colors.black),
      ),
    ];
  }

  // Si aucune correspondance n'est trouvée, retourner la description normale
  return [
    TextSpan(
      text: description,
      style: const TextStyle(color: Colors.black),
    ),
  ];
}

class _MoovInternetPageState extends State<MoovInternetPage> {
  List<Map<String, dynamic>> plans = [];
  bool isLoading = false;
  String today = "";

  @override
  void initState() {
    super.initState();
    today = _getTodayInFrench();
    _checkAndUpdateData(); // ✅ Nouvelle méthode qui gère actualisation une fois par jour
  }

// Vérifie si une actualisation est nécessaire
  Future<void> _checkAndUpdateData() async {
    final prefs = await SharedPreferences.getInstance();
    String? lastUpdatedDate = prefs.getString('lastUpdatedDateMoovInternet'); // ✅ Clé dédiée
    String todayDate = _getTodayDate();

    await _MoovinternetloadLocalData();

    if (lastUpdatedDate == null || lastUpdatedDate != todayDate) {
      await fetchInternetPlansFromAPI();
      prefs.setString('lastUpdatedDateMoovInternet', todayDate); // ✅ Mise à jour
    }
  }


// Obtenir la date actuelle sous forme de chaîne (YYYY-MM-DD)
  String _getTodayDate() {
    DateTime now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }
  bool _hasBonusToday(String? joursBonusJson) {
    if (joursBonusJson == null || joursBonusJson.isEmpty) {
      return false; // Pas de bonus si les données sont nulles ou vides.
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

  // Charger les données locales
  Future<void> _MoovinternetloadLocalData() async {
    List<Map<String, dynamic>> MoovinternetlocalPlans =
    await MoovloadPlansFromLocal();
    setState(() {
      plans = MoovinternetlocalPlans.isNotEmpty
          ? MoovinternetlocalPlans
          : _MoovloadDefaultPlans();
    });
  }

  // Sauvegarder les plans localement
  Future<void> MoovsavePlansLocally(List<Map<String, dynamic>> plans) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('MoovlocalPlans', json.encode(plans));
  }

  // Charger les plans depuis le stockage local
  Future<List<Map<String, dynamic>>> MoovloadPlansFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final plansJson = prefs.getString('MoovlocalPlans');
    if (plansJson != null) {
      return List<Map<String, dynamic>>.from(json.decode(plansJson));
    }
    return [];
  }

  // Charger les plans par défaut
  List<Map<String, dynamic>> _MoovloadDefaultPlans() {
    return [];
  }

  // Récupérer les forfaits depuis l'API
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
              .where((plan) => plan['Operateur'] == 'Moov' && plan['isAvailable'] == 1)
              .map((plan) {
            // Détecter si c'est la référence spéciale 2055
            bool isSpecial = plan['Reference'] == '2055';

            // Pour les autres références, on applique la logique bonus
            bool hasBonus = !isSpecial && _hasBonusToday(plan['JourBonus'] ?? "[]");

            // Pour la référence spéciale, on garde le titre original (exemple "3Go à 990F")
            // pour lequel nous appliquerons une stylisation spéciale dans _buildStyledTitle.
            String title = isSpecial
                ? (plan['Titre'] ?? "Titre inconnu")
                : (plan['Forfait_type'] == "Forfaits Internet Promo" && hasBonus
                ? _applyBonus(plan['Titre'] ?? "", plan['JourBonus'] ?? "[]")
                : (plan['Titre'] ?? "Titre inconnu"));

            // Pour la description, pour la référence 2055, on garde la description de base.
            String description = isSpecial
                ? (plan['Description'] ?? "Description indisponible")
                : (hasBonus
                ? (plan['Description_Bonus'] ?? "Description Bonus indisponible")
                : (plan['Description'] ?? "Description indisponible"));

            return {
              'id': plan['Reference'] ?? "0",
              'title': title,
              'description': description,
              'amount': int.tryParse(plan['Montant']?.toString() ?? "0") ?? 0,
              'validity': _formatValidity(plan['JoursDispo'] ?? "[]"),
              'reference': plan['Reference'] ?? "Référence inconnue",
              'type': plan['Forfait_type'] ?? "Type inconnu",
              // Vous pouvez ajouter un flag pour le traitement spécial
              'isSpecial': isSpecial,
              // Conservez éventuellement les champs "JourBonus" pour un usage ultérieur
              'JourBonus': plan['JourBonus'] ?? "[]",
            };
          }).toList();

// Réorganiser la liste pour placer la référence "2055" en 3ème position (index 2)
          int specialIndex = fetchedPlans.indexWhere((plan) => plan['reference'] == '2055');
          if (specialIndex != -1) {
            var specialPlan = fetchedPlans.removeAt(specialIndex);
            int insertIndex = 2; // 3ème position (les index commencent à 0)
            if (fetchedPlans.length < insertIndex) {
              insertIndex = fetchedPlans.length;
            }
            fetchedPlans.insert(insertIndex, specialPlan);
          }

          setState(() {
            plans = fetchedPlans;
          });

          await MoovsavePlansLocally(fetchedPlans);

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



  // Grouper les plans par Forfait_type et trier
  Map<String, List<Map<String, dynamic>>> groupAndSortPlansByType() {
    Map<String, List<Map<String, dynamic>>> groupedPlans = {};

    for (var plan in plans) {
      String type = plan['type'] ?? 'Autre';

      // Vérification du type et conversion en majuscules si nécessaire
      if (type == "Forfaits Internet Promo") {
        type = "FORFAITS INTERNET PROMO"; // Conversion en majuscules
      }

      groupedPlans.putIfAbsent(type, () => []).add(plan);
    }

    // Trie les types en plaçant "FORFAITS INTERNET PROMO" en premier
    List<String> sortedKeys = groupedPlans.keys.toList();
    sortedKeys.sort((a, b) {
      if (a == "FORFAITS INTERNET PROMO") return -1;
      if (b == "FORFAITS INTERNET PROMO") return 1;
      return a.compareTo(b);
    });

    return { for (var key in sortedKeys) key : groupedPlans[key]! };
  }


  // Obtenir le jour actuel en français
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

  // Formater la validité
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


  // Appliquer le bonus
  String _applyBonus(String title, String joursBonusJson) {
    List<String> joursBonus = [];
    try {
      joursBonus = json.decode(joursBonusJson).cast<String>();
    } catch (e) {
      debugPrint('Erreur de parsing de JourBonus : $e');
      return title;
    }

    if (joursBonus.contains(today)) {
      final match = RegExp(r"(\d+(\.\d+)?)\s*(Go|Mo)").firstMatch(title);
      if (match != null) {
        final volume = double.parse(match.group(1)!);
        final unit = match.group(3);

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

    // Vérifiez si c'est un jour de bonus
    final bool isBonusDay = _isBonusDay();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.card_giftcard, // Icône représentant un bonus ou une fête
              color: Colors.red,
            ),
            const SizedBox(width: 8), // Espacement entre l'icône et le texte
            Expanded(
              child: Text(
                "Bonus internet de ce $today",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20, // Taille ajustable
                ),
                maxLines: 2, // Limite à deux lignes
                overflow: TextOverflow.ellipsis, // Texte coupé avec "..." si dépassement
              ),
            ),
          ],
        ),
        backgroundColor: Colors.purple, // Couleur de fond de l'AppBar
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          if (isBonusDay) // Affiche "Jour de Bonus!!!" si un bonus est actif
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
                          color: Colors.purple,
                        ),
                      ),
                    ),
                    ...plansForType.map((plan) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: ListTile(
                          leading: Image.asset(
                            'assets/images/moov_money.png',
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
                            // Si c'est la référence spéciale 2055, vérifier le jour
                            if (plan['reference'] == '2055') {
                              String today = _getTodayInFrench(); // La fonction existante renvoie le jour en minuscules, par exemple "mercredi" ou "dimanche"
                              if (!(today == 'mercredi' || today == 'dimanche')) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Ce forfait est disponible seulement les mercredi et dimanche"),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                                return; // Ne pas poursuivre
                              }
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MoovPaymentDetailsPage(
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

// Méthode pour styliser le titre avec les parties rouges et grasses
  List<TextSpan> _buildStyledTitle(String title) {
    // Pour la référence spéciale, on vérifie le titre exact "3Go à 990F"
    if (title == "3Go à 990F") {
      return [
        TextSpan(
          text: "3",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        TextSpan(
          text: "Go à ",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextSpan(
          text: "990",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        TextSpan(
          text: "F",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ];
    }

    // Pour les autres titres, on conserve la logique initiale (reconnaissance des volumes en Go ou Mo)
    final match = RegExp(r"(\d+)(Go|Mo)\+(\d+)(Go|Mo)").firstMatch(title);
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
              color: Colors.purple,
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