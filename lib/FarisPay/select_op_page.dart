import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'Internet Pages/moov_internet_page.dart';
import 'Internet Pages/orange_internet_page.dart';
import 'Internet Pages/telecel_internet_page.dart';
import 'Unités Pages/moov_unite_page.dart';
import 'Unités Pages/orange_unite_page.dart';
import 'Unités Pages/telecel_unite_page.dart';

class SelectOpPage extends StatefulWidget {
  const SelectOpPage({Key? key}) : super(key: key);

  @override
  _SelectOpPageState createState() => _SelectOpPageState();
}

class _SelectOpPageState extends State<SelectOpPage> {
  final String internetApiUrl = "https://apps.farisbusinessgroup.com/api/get_forfaits.php";
  final String unitsApiUrl = "https://apps.farisbusinessgroup.com/api/get_unites.php";

  List<Operator> operators = [
    Operator(
      name: "Orange",
      subtitle: "Forfaits Internet",
      imagePath: "assets/images/orange_money.png",
      purchaseType: PurchaseType.internet,
      destination: OrangeInternetPage(),
      isAvailable1: true,
      borderColor: Colors.orange.shade300,
      joursBonus: [],
    ),
    Operator(
      name: "Orange",
      subtitle: "Unités",
      imagePath: "assets/images/orange_money.png",
      purchaseType: PurchaseType.units,
      destination: OrangeUnitePage(),
      isAvailable1: true,
      borderColor: Colors.orange.shade300,
      joursBonus: [],
    ),
    Operator(
      name: "Moov",
      subtitle: "Forfaits Internet",
      imagePath: "assets/images/moov_money.png",
      purchaseType: PurchaseType.internet,
      destination: MoovInternetPage(),
      isAvailable1: true,
      borderColor: Colors.purple.shade300,
      joursBonus: [],
    ),
    Operator(
      name: "Moov",
      subtitle: "Unités",
      imagePath: "assets/images/moov_money.png",
      purchaseType: PurchaseType.units,
      destination: MoovUnitePage(),
      isAvailable1: true,
      borderColor: Colors.purple.shade300,
      joursBonus: [],
    ),
    Operator(
      name: "Telecel",
      subtitle: "Forfaits Internet",
      imagePath: "assets/images/telecel.png",
      purchaseType: PurchaseType.internet,
      destination: TelecelInternetPage(),
      isAvailable1: true,
      borderColor: Colors.blue.shade300,
      joursBonus: [],
    ),
    Operator(
      name: "Telecel",
      subtitle: "Unités",
      imagePath: "assets/images/telecel.png",
      purchaseType: PurchaseType.units,
      destination: TelecelUnitePage(),
      isAvailable1: true,
      borderColor: Colors.blue.shade300,
      joursBonus: [],
    ),
    Operator(
      name: "Sank Money",
      subtitle: "Forfaits internet mobile",
      imagePath: "assets/images/sank_money.png",
      purchaseType: PurchaseType.internet,
      destination: Scaffold(
        appBar: AppBar(title: Text("Service Indisponible")),
        body: Center(child: Text("Ce service n'est pas encore disponible.")),
      ),
      isAvailable1: false,
      borderColor: Colors.grey.shade400,
      joursBonus: [],
    ),
    Operator(
      name: "Sank Money",
      subtitle: "Unités de communication",
      imagePath: "assets/images/sank_money.png",
      purchaseType: PurchaseType.units,
      destination: Scaffold(
        appBar: AppBar(title: Text("Service Indisponible")),
        body: Center(child: Text("Ce service n'est pas encore disponible.")),
      ),
      isAvailable1: false,
      borderColor: Colors.grey.shade400,
      joursBonus: [],
    ),
  ];

  @override
  void initState() {
    super.initState();
    loadJourBonus();
  }

  Future<void> loadJourBonus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final internetData = prefs.getString('internetJourBonus');
    final unitsData = prefs.getString('unitsJourBonus');

    if (internetData != null && unitsData != null) {
      updateOperatorsWithLocalData(jsonDecode(internetData), PurchaseType.internet);
      updateOperatorsWithLocalData(jsonDecode(unitsData), PurchaseType.units);
    } else {
      await fetchAllData();
    }
  }

  Future<void> fetchAllData() async {
    await Future.wait([
      fetchInternetJourBonus(),
      fetchUnitJourBonus(),
    ]);
  }

  Future<void> fetchInternetJourBonus() async {
    await _fetchAndSaveJourBonus(apiUrl: internetApiUrl, type: PurchaseType.internet, key: 'internetJourBonus');
  }

  Future<void> fetchUnitJourBonus() async {
    await _fetchAndSaveJourBonus(apiUrl: unitsApiUrl, type: PurchaseType.units, key: 'unitsJourBonus');
  }

  Future<void> _fetchAndSaveJourBonus({
    required String apiUrl,
    required PurchaseType type,
    required String key,
  }) async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = responseData['data'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(key, jsonEncode(data));

        updateOperatorsWithLocalData(data, type);
      }
    } catch (e) {
      print("Erreur lors de la récupération des données : $e");
    }
  }

  void updateOperatorsWithLocalData(List<dynamic> data, PurchaseType type) {
    setState(() {
      operators = operators.map((operator) {
        if (operator.purchaseType == type) {
          final matchingOperator = data.firstWhere(
                (item) => item['Operateur'] == operator.name,
            orElse: () => null,
          );

          List<String> joursBonus = [];
          bool isAvailable1 = operator.isAvailable1;
          bool isOpAvailable = true;

          if (matchingOperator != null) {
            if (matchingOperator['JourBonus'] != null) {
              try {
                joursBonus = (jsonDecode(matchingOperator['JourBonus']) as List)
                    .map((item) => item.toString())
                    .toList();
              } catch (e) {
                print("Erreur de conversion JourBonus : $e");
              }
            }

            if (matchingOperator['isOpAvailable'] != null) {
              isOpAvailable = matchingOperator['isOpAvailable'] == 1;
            }
          }

          return Operator(
            name: operator.name,
            subtitle: operator.subtitle,
            imagePath: operator.imagePath,
            purchaseType: operator.purchaseType,
            destination: operator.destination,
            isAvailable1: isAvailable1 && isOpAvailable,
            borderColor: operator.borderColor,
            joursBonus: joursBonus,
          );
        }
        return operator;
      }).toList();
    });
  }

  String _getTodayInFrench() {
    const days = ["lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"];
    return days[DateTime.now().weekday - 1];
  }

  // Construction d'une carte opérateur responsive
  Widget _buildOperatorCard(Operator operator) {
    double screenWidth = MediaQuery.of(context).size.width;
    // Calculer la largeur disponible pour 2 colonnes (48 = padding global + spacing)
    double cardWidth = (screenWidth - 48) / 2;
    double baseFontSize = screenWidth < 360 ? 12 : 14;

    bool isBonusDay = operator.isAvailable1 && operator.joursBonus.contains(_getTodayInFrench());

    return InkWell(
      onTap: operator.isAvailable1
          ? () => Get.to(() => operator.destination, transition: Transition.cupertino)
          : () => _showNotAvailableDialog(context),
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: operator.borderColor, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Image.asset(
                operator.imagePath,
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              operator.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: baseFontSize,
                fontWeight: FontWeight.bold,
                color: operator.isAvailable1 ? Colors.black : Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              operator.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: baseFontSize - 2,
                color: operator.isAvailable1 ? Colors.black54 : Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if (operator.isAvailable1)
              Text(
                operator.joursBonus.contains(_getTodayInFrench())
                    ? "🎉 Jour de Bonus 100%!"
                    : "Bons plans à découvrir.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: baseFontSize - 2,
                  fontWeight: operator.joursBonus.contains(_getTodayInFrench())
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: operator.joursBonus.contains(_getTodayInFrench())
                      ? Colors.green
                      : Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperatorsWrap(List<Operator> operators) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: operators.map((op) => _buildOperatorCard(op)).toList(),
    );
  }

  void _showNotAvailableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Service Indisponible"),
        content: const Text("Ce service n'est pas encore disponible."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Operator> internetOperators =
    operators.where((operator) => operator.purchaseType == PurchaseType.internet).toList();
    final List<Operator> unitsOperators =
    operators.where((operator) => operator.purchaseType == PurchaseType.units).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Choisir une option", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange.shade600,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await fetchAllData();
              Get.snackbar(
                "Actualisation",
                "Les données ont été mises à jour.",
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
          ),
        ],
      ),
      body: operators.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: fetchAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Achat de mégas (Forfaits internet)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 16),
              _buildOperatorsWrap(internetOperators),
              const SizedBox(height: 24),
              const Text(
                "Achat d'unités (Crédit de communication)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 16),
              _buildOperatorsWrap(unitsOperators),
            ],
          ),
        ),
      ),
    );
  }
}

enum PurchaseType { units, internet }

class Operator {
  final String name;
  final String subtitle;
  final String imagePath;
  final PurchaseType purchaseType;
  final Widget destination;
  final bool isAvailable1;
  final Color borderColor;
  final List<String> joursBonus;

  const Operator({
    required this.name,
    required this.subtitle,
    required this.imagePath,
    required this.purchaseType,
    required this.destination,
    required this.isAvailable1,
    required this.borderColor,
    required this.joursBonus,
  });
}
