import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../profil/request_join_tontine_page.dart';

class PublicTontinesPage extends StatefulWidget {
  @override
  _PublicTontinesPageState createState() => _PublicTontinesPageState();
}

class _PublicTontinesPageState extends State<PublicTontinesPage> {
  List<dynamic> tontines = [];
  List<dynamic> filteredTontines = [];
  bool isLoading = true;
  String errorMessage = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPublicTontines();
  }

  Future<void> fetchPublicTontines() async {
    final String apiUrl =
        "https://apps.farisbusinessgroup.com/api/get_public_tontines.php";

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] is List) {
          setState(() {
            // Trier par "created_at" (plus récent au plus ancien)
            tontines = data['data'];
            tontines.sort((a, b) {
              DateTime dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1970);
              DateTime dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1970);
              return dateB.compareTo(dateA); // Tri décroissant
            });
            filteredTontines = tontines; // Mise à jour pour les filtres
            isLoading = false;
          });
        } else {
          throw Exception("Données inattendues.");
        }
      } else {
        throw Exception("Erreur : ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        errorMessage = "Erreur : $e";
        isLoading = false;
      });
    }
  }


  void filterTontines(String query) {
    final filtered = tontines.where((tontine) {
      final code = tontine['numero']?.toString() ?? '';
      return code.contains(query);
    }).toList();

    setState(() {
      filteredTontines = filtered;
    });
  }

  void showConditionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Conditions de participation",
            style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Text(
              "L'objectif de l'épargne collective ou tontine en groupe est de se motiver mutuellement à épargner et pouvoir financer ses projets.\n"
                  "1. Assurez-vous de connaître l'organisateur de l'épargne ou de la tontine avant de participer.\n"
                  "2. L'organisateur doit vous accepter pour que vous puissiez participer, vous pouvez le contacter pour accélerer le proccessus\n"
                  "3. C'est l'organisateur qui fait le retrait en s'assurant de mettre le numéro de la personne qui doit recevoir le dépôt.\n"
                  "\nEn cliquant sur 'Demander à participer', vous acceptez ces conditions.",
              style: TextStyle(fontSize: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Fermer",
                style: TextStyle(color: Colors.orangeAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ÉPARGNES PARTAGÉES",
          style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) => filterTontines(value),
              decoration: InputDecoration(
                hintText: "Rechercher par code épargne...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchPublicTontines,
              child: isLoading
                  ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  Center(child: CircularProgressIndicator()),
                ],
              )
                  : errorMessage.isNotEmpty
                  ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [Center(child: Text(errorMessage))],
              )
                  : filteredTontines.isEmpty
                  ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [Center(child: Text("Aucune tontine trouvée"))],
              )
                  : ListView.builder(
                itemCount: filteredTontines.length,
                itemBuilder: (context, index) {
                  final tontine = filteredTontines[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tontine['libelle'] ?? 'Sans titre',
                            style: GoogleFonts.raleway(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text("Code épargne : ${tontine['numero']}"),
                          Text("oragnisateur: ${tontine['nom']} ${tontine['prenom']}"),
                          Text("Montant : ${tontine['montant_tontine']} FCFA"),
                          Text("Périodicité : ${tontine['periodicite']}"),
                          Text("Date début : ${tontine['date_debut']}"),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      showConditionsDialog(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[300],
                                    ),
                                    child: const Text(
                                      "Lire les conditions",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final tontineCode = tontine['numero']?.toString() ?? '';
                                      Get.to(() => RequestJoinTontinePage(tontineCode: tontineCode));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orangeAccent,
                                    ),
                                    child: const Text(
                                      "Demander à participer",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
