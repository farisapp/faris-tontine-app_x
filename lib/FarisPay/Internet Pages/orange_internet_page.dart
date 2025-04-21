import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'Orange_internet_payment_details_page.dart';

class OrangeInternetPage extends StatefulWidget {
  @override
  _OrangeInternetPageState createState() => _OrangeInternetPageState();
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

class _OrangeInternetPageState extends State<OrangeInternetPage> {
  List<Map<String, dynamic>> plans = [];
  bool isLoading = false;
  String today = "";

  @override
  void initState() {
    super.initState();
    today = _getTodayInFrench();
    _checkAndUpdateData(); // ✅ Nouvelle méthode utilisée
  }



// Vérifie si une actualisation est nécessaire
  Future<void> _checkAndUpdateData() async {
    final prefs = await SharedPreferences.getInstance();
    String? lastUpdatedDate = prefs.getString('lastUpdatedDateOrangeInternet'); // ✅ Clé spécifique
    String todayDate = _getTodayDate();

    await _OrangeinternetloadLocalData(); // ✅ Toujours charger les données locales en premier

    if (lastUpdatedDate == null || lastUpdatedDate != todayDate) {
      await fetchInternetPlansFromAPI();
      prefs.setString('lastUpdatedDateOrangeInternet', todayDate); // ✅ Mise à jour de la date
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
  Future<void> _OrangeinternetloadLocalData() async {
    List<Map<String, dynamic>> OrangeinternetlocalPlans =
    await OrangeloadPlansFromLocal();
    setState(() {
      plans = OrangeinternetlocalPlans.isNotEmpty
          ? OrangeinternetlocalPlans
          : _OrangeloadDefaultPlans();
    });
  }

  // Sauvegarder les plans localement
  Future<void> OrangesavePlansLocally(List<Map<String, dynamic>> plans) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('OrangelocalPlans', json.encode(plans));
  }

  // Charger les plans depuis le stockage local
  Future<List<Map<String, dynamic>>> OrangeloadPlansFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final plansJson = prefs.getString('OrangelocalPlans');
    if (plansJson != null) {
      return List<Map<String, dynamic>>.from(json.decode(plansJson));
    }
    return [];
  }

  // Charger les plans par défaut
  List<Map<String, dynamic>> _OrangeloadDefaultPlans() {
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
              .where((plan) =>
          plan['Operateur'] == 'Orange' && plan['isAvailable'] == 1)
              .map((plan) {
            bool hasBonus = _hasBonusToday(plan['JourBonus'] ?? "[]");
            String title = plan['Forfait_type'] == "Forfaits Internet Promo" && hasBonus
                ? _applyBonus(plan['Titre'] ?? "", plan['JourBonus'] ?? "[]")
                : (plan['Titre'] ?? "Titre inconnu");

            return {
              'id': plan['Reference'] ?? "0",
              'title': title,
              'description': hasBonus
                  ? (plan['Description_Bonus'] ?? "Description Bonus indisponible")
                  : (plan['Description'] ?? "Description indisponible"),
              'amount': int.tryParse(plan['Montant']?.toString() ?? "0") ?? 0,
              'validity': _formatValidity(plan['JoursDispo'] ?? "[]"),
              'reference': plan['Reference'] ?? "Référence inconnue",
              'type': plan['Forfait_type'] ?? "Type inconnu",
            };
          }).toList();

          setState(() {
            plans = fetchedPlans;
          });

          await OrangesavePlansLocally(fetchedPlans);

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

      // Conversion en majuscules pour ce type
      if (type == "Forfaits Internet Promo") {
        type = "FORFAITS INTERNET PROMO";
      }

      groupedPlans.putIfAbsent(type, () => []).add(plan);
    }

    // Pour le groupe "FORFAITS INTERNET PROMO", on réorganise pour mettre l'offre spéciale en 2ème position
    if (groupedPlans.containsKey("FORFAITS INTERNET PROMO")) {
      List<Map<String, dynamic>> promoPlans = groupedPlans["FORFAITS INTERNET PROMO"]!;
      int specialIndex = promoPlans.indexWhere((plan) => plan['reference'] == "1023");
      if (specialIndex != -1 && promoPlans.length > 1) {
        final specialPlan = promoPlans.removeAt(specialIndex);
        promoPlans.insert(1, specialPlan); // Insertion à la position 1
      }
    }

    // Trie les clés en plaçant "FORFAITS INTERNET PROMO" en premier
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
        backgroundColor: Colors.orange, // Couleur de fond de l'AppBar
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
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    ...plansForType.map((plan) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: ListTile(
                          leading: Image.asset(
                            'assets/images/orange_money.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                          title: RichText(
                            text: TextSpan(
                              children: plan['reference'] == "1023"
                                  ? _buildSpecialStyledTitle(plan['title'])
                                  : _buildStyledTitle(plan['title']),
                            ),
                          ),
                          subtitle: RichText(
                            text: TextSpan(
                              children: _buildStyledDescription(
                                  plan['description']),
                            ),
                          ),
                          trailing: Text(
                            "${plan['amount']} F",
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
                                    OrangePaymentDetailsPage(
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
  List<TextSpan> _buildSpecialStyledTitle(String title) {
    // Vérifier si le titre contient " à "
    if (title.contains(" à ")) {
      List<String> parts = title.split(" à ");
      String leftPart = parts[0]; // Ex: "OFFRE SPECIALE: 5 GIGA"
      String rightPart = parts[1]; // Ex: "2.465 F TTC"
      List<TextSpan> spans = [];
      const String specialOfferPrefix = "OFFRE SPECIALE:";

      // Si la première partie contient le préfixe "OFFRE SPECIALE:"
      if (leftPart.contains(specialOfferPrefix)) {
        // Découper la première partie en deux segments
        int index = leftPart.indexOf(specialOfferPrefix);
        String prefix = specialOfferPrefix;
        // Récupérer ce qui suit après le préfixe (ex: "5 GIGA")
        String remainingLeft = leftPart.substring(index + specialOfferPrefix.length).trim();

        // Afficher "OFFRE SPECIALE:" en bleu
        spans.add(TextSpan(
          text: prefix + " ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ));
        // Afficher la suite (ex: "5 GIGA") en deepOrange
        if (remainingLeft.isNotEmpty) {
          spans.add(TextSpan(
            text: remainingLeft,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ));
        }
      } else {
        // Si le préfixe n'est pas trouvé, afficher toute la première partie en deepOrange
        spans.add(TextSpan(
          text: leftPart,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ));
      }
      // Ajouter le séparateur " à " en deepOrange
      spans.add(const TextSpan(
        text: " à ",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.deepOrange,
        ),
      ));
      // Afficher la deuxième partie (ex: "2.465 F TTC") en deepOrange
      spans.add(TextSpan(
        text: rightPart,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.deepOrange,
        ),
      ));
      return spans;
    } else {
      // Format par défaut : tout le titre en deepOrange
      return [
        TextSpan(
          text: title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
      ];
    }
  }

// Méthode pour styliser le titre avec les parties rouges et grasses
  List<TextSpan> _buildStyledTitle(String title) {
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
            fontWeight: FontWeight.bold, // Tous en gras
            color: Colors.red,
          ),
        ),
        TextSpan(
          text: mainUnit,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold, // Ajout du gras
            color: Colors.black,
          ),
        ),
        const TextSpan(
          text: '+',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold, // Tous en gras
            color: Colors.black,
          ),
        ),
        TextSpan(
          text: bonusVolume,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold, // Ajout du gras
            color: Colors.red,
          ),
        ),
        TextSpan(
          text: bonusUnit,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold, // Ajout du gras
            color: Colors.black,
          ),
        ),
        if (isBonusIncluded)
          const TextSpan(
            text: " (Bonus 100%)",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold, // Tous en gras
              color: Colors.orange,
            ),
          ),
      ];
    }

    // Cas où aucune correspondance n'est trouvée : le titre complet sera en gras
    return [
      TextSpan(
        text: title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold, // Mise en gras ici
          color: Colors.black,
        ),
      ),
    ];
  }
}