import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // ✅ Importer intl pour le formatage des nombres

class ArticlesDepotVentePage extends StatefulWidget {
  final int depotId;

  const ArticlesDepotVentePage({Key? key, required this.depotId}) : super(key: key);

  @override
  _ArticlesDepotVentePageState createState() => _ArticlesDepotVentePageState();
}

class _ArticlesDepotVentePageState extends State<ArticlesDepotVentePage> {
  List<dynamic> articles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    final String apiUrl = "https://apps.farisbusinessgroup.com/api/get_articles_depot_vente.php?depot_id=${widget.depotId}";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            articles = data['data'];
            isLoading = false;
          });
        } else {
          _showErrorSnackbar(data['message']);
        }
      } else {
        _showErrorSnackbar("Erreur de serveur (${response.statusCode})");
      }
    } catch (e) {
      _showErrorSnackbar("Erreur de connexion : $e");
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      "Erreur",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Suivi de votre stock",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : articles.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(10),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return _buildArticleCard(article);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchArticles,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

// 🔹 Construire une carte stylisée pour chaque article
  Widget _buildArticleCard(Map<String, dynamic> article) {
    // 🔹 Convertir les valeurs en `num` pour éviter l'erreur
    int stockInitial = int.tryParse(article['nombre'].toString()) ?? 0;
    int quantiteVendue = int.tryParse(article['quantite_vendue'].toString()) ?? 0;
    int quantiteRestante = int.tryParse(article['quantite_restante'].toString()) ?? 0;
    double prixUnitaire = double.tryParse(article['prix_unitaire'].toString()) ?? 0.0;

    // 🔹 Calcul du total vendu et du total restant en FCFA (sans virgule)
    int totalVendu = (quantiteVendue * prixUnitaire).toInt();
    int totalRestant = (quantiteRestante * prixUnitaire).toInt();

    // ✅ Formater les montants pour affichage avec espace (ex: 15 000 FCFA)
    final formatNombre = NumberFormat("#,###", "fr_FR");

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Nom de l'article en grand titre
            Text(
        "Article : ${article['nom_article']}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 10),

            // 🔹 Affichage du Stock Initial
            Row(
              children: [
                const Icon(Icons.inventory, color: Colors.orange, size: 20),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    "Stock Initial : ${formatNombre.format(stockInitial)}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const Divider(height: 20, thickness: 5, color: Colors.grey),

            // 🔹 Affichage des infos en colonne pour éviter Overflow
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 15,
                  runSpacing: 5, // ✅ Évite overflow en adaptant la disposition
                  children: [
                    _buildInfoIcon(Icons.shopping_cart, "Vendu", formatNombre.format(quantiteVendue), Colors.red),
                    _buildInfoIcon(Icons.attach_money, "Prix Unitaire", "${formatNombre.format(prixUnitaire.toInt())} FCFA", Colors.blueGrey),
                  ],
                ),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 15,
                  runSpacing: 5, // ✅ Permet aux éléments de passer à la ligne si besoin
                  children: [
                    _buildInfoIcon(Icons.trending_up, "Total Vendu", "${formatNombre.format(totalVendu)} FCFA", Colors.green),
                    _buildInfoIcon(Icons.account_balance_wallet, "Total Restant", "${formatNombre.format(totalRestant)} FCFA", Colors.orange),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Construire une icône avec texte pour les informations de l'article
  Widget _buildInfoIcon(IconData icon, String label, String value, Color iconColor) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 5),
          Text(
            "$label : $value",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // 🔹 Construire un état vide
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2, size: 80, color: Colors.orange),
          SizedBox(height: 10),
          Text(
            "Aucun article enregistré pour ce dépôt.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
