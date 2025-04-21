import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http; // ✅ Corrige l'erreur http
import 'dart:convert';
import 'articles_depot_vente_page.dart';
import 'inscription_depot_vente_page.dart'; // ✅ Corrige l'erreur json
import 'package:intl/intl.dart'; // ✅ Importer intl pour le formatage des nombres

class DepotVentePage extends StatefulWidget {
  const DepotVentePage({super.key});

  @override
  _DepotVentePageState createState() => _DepotVentePageState();
}

class _DepotVentePageState extends State<DepotVentePage> {
  List<dynamic> depotVentes = [];
  bool isLoading = true;
  final int userId = 1169; // Remplace 1 par un ID utilisateur dynamique

  @override
  void initState() {
    super.initState();
    fetchDepotVentes();
  }
// 🔹 Widget pour afficher un état vide
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.storefront, size: 80, color: Colors.orange),
          const SizedBox(height: 10),
          const Text(
            "Aucun Dépôt-Vente soumis pour le moment.\nCliquez sur 'Déposer un stock' pour en ajouter.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
              ],
      ),
    );
  }
  final NumberFormat formatNombre = NumberFormat("#,###", "fr_FR"); // ✅ Formateur pour nombres entiers
// 🔹 Fonction pour colorer le statut
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "validé":
        return Colors.green;
      case "refusé":
        return Colors.red;
      case "en attente":
      default:
        return Colors.orange;
    }
  }
// 🔹 Formater la date en format lisible
  String _formatDate(String dateTime) {
    try {
      DateTime parsedDate = DateTime.parse(dateTime);
      return "${parsedDate.day}/${parsedDate.month}/${parsedDate.year} à ${parsedDate.hour}:${parsedDate.minute}";
    } catch (e) {
      return "Date inconnue";
    }
  }
  void _confirmerSuppression(int depotId) {
    Get.defaultDialog(
      title: "Confirmer la suppression",
      content: const Text("Voulez-vous vraiment supprimer ce dépôt ?"),
      textConfirm: "Oui",
      textCancel: "Non",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back(); // Fermer la boîte de dialogue
        _supprimerDepot(depotId);
      },
    );
  }

  Future<void> _supprimerDepot(int depotId) async {
    final apiUrl = "https://apps.farisbusinessgroup.com/api/add_depot_vente.php";

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'depot_id': depotId.toString(),
          'action': 'delete',
        },
      );

      var jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        Get.snackbar("Succès", jsonResponse['message'], backgroundColor: Colors.green, colorText: Colors.white);
        fetchDepotVentes(); // 🔄 Rafraîchir la liste après suppression
      } else {
        Get.snackbar("Erreur", jsonResponse['message'], backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Erreur", "Échec de la suppression : $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _enregistrerDetailsArticle(int depotId, String numeroArticle, String description, int nombre, double prixUnitaire) async {
    final apiUrl = "https://apps.farisbusinessgroup.com/api/add_depot_vente.php";

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'depot_id': depotId.toString(),
          'user_id': '1', // Assure-toi d'envoyer l'ID utilisateur
          'status': 'Validé',
          'numero_article': numeroArticle,
          'description': description,
          'nombre': nombre.toString(),
          'prix_unitaire': prixUnitaire.toString(),
          'prix_total': (nombre * prixUnitaire).toString(),
        },
      );

      print("🔹 Réponse brute de l'API : ${response.body}");
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        Get.snackbar("Succès", jsonResponse['message'], backgroundColor: Colors.green, colorText: Colors.white);
        fetchDepotVentes(); // 🔄 Rafraîchir la liste après mise à jour
      } else {
        Get.snackbar("Erreur", jsonResponse['message'], backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Erreur", "Échec de la mise à jour : $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // 🔹 Fonction pour récupérer les dépôts vente de l'utilisateur
  Future<void> fetchDepotVentes() async {
    final String apiUrl = "https://apps.farisbusinessgroup.com/api/get_user_depot_vente.php?user_id=$userId";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            depotVentes = data['data'];
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
          "Mes Dépôts Vente",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : depotVentes.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        itemCount: depotVentes.length,
        itemBuilder: (context, index) {
          final depot = depotVentes[index];
          final String status = depot['status'].toLowerCase();

          return Card(
            margin: const EdgeInsets.all(8),
            elevation: 4,
            child: ListTile(
              leading: Stack(
                alignment: Alignment.topRight,
                children: [
                  depot['image1'] != null && depot['image1'].isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      depot['image1'],
                      width: 70,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print("❌ Erreur chargement image: $error");
                        return const Icon(Icons.broken_image, size: 60, color: Colors.grey);
                      },
                    ),
                  )
                      : const Icon(Icons.inventory_2, size: 60, color: Colors.orange),

                  // Ajout de l'icône Shopping Cart
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(Icons.shopping_cart, size: 18, color: Colors.blue),
                  ),
                ],
              ),
              title: Text(
                "Dépôt #${depot['id']} - ${depot['produit_nom'] ?? 'N/A'}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Quantité : ${depot['quantite'] ?? 'N/A'}", style: const TextStyle(fontSize: 14)),
                  Text("Prix : ${formatNombre.format(double.tryParse(depot['prix'].toString())?.toInt() ?? 0)} FCFA",
                      style: const TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.bold)),
                  Text(
                    "Statut : ${depot['status']}",
                    style: TextStyle(
                      color: _getStatusColor(depot['status']),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              trailing: (status == "en attente" || status == "refusé")
                  ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmerSuppression(depot['id']),
              )
                  : null,
              onTap: () => _handleDepotClick(depot),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => const InscriptionDepotVente());
        },
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Déposer un stock",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // 🔹 Gestion du clic sur un élément de la liste
  void _handleDepotClick(Map<String, dynamic> depot) {
    String status = depot['status'].toLowerCase();

    if (status == "validé") {
      // 🔹 Ouvre la page des articles liés au dépôt
      Get.to(() => ArticlesDepotVentePage(depotId: depot['id']));
    } else if (status == "en attente") {
      showMessageDialog("En cours de validation", "Votre dépôt est en attente de validation. Veuillez nous contacter");
    } else if (status == "refusé") {
      showMessageDialog("Demande refusée", "Votre dépôt a été refusé.");
    } else if (status == "validé") {
      showValidatedForm(depot);
    }
  }

  // 🔹 Afficher une boîte de dialogue pour les statuts "En attente" et "Refusé"
  void showMessageDialog(String title, String message) {
    Get.defaultDialog(
      title: title,
      content: Text(message),
      textConfirm: "OK",
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(),
    );
  }

  // 🔹 Afficher le formulaire pour les articles validés
  void showValidatedForm(Map<String, dynamic> depot) {
    final TextEditingController numeroArticleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController prixUnitaireController = TextEditingController();
    final TextEditingController prixTotalController = TextEditingController();

    Get.defaultDialog(
      title: "Ajoutez vos articles",
      content: Column(
        children: [
          _buildTextField(numeroArticleController, "N° article"),
          _buildTextField(descriptionController, "Description"),
          _buildTextField(nombreController, "Nombre", isNumeric: true, onChanged: (val) {
            _updatePrixTotal(nombreController, prixUnitaireController, prixTotalController);
          }),
          _buildTextField(prixUnitaireController, "Prix unitaire estimé (FCFA)", isNumeric: true, onChanged: (val) {
            _updatePrixTotal(nombreController, prixUnitaireController, prixTotalController);
          }),
          _buildTextField(prixTotalController, "Prix total", isReadOnly: true),
        ],
      ),
      textConfirm: "Enregistrer",
      confirmTextColor: Colors.white,
      onConfirm: () {
        _enregistrerDetailsArticle(
          depot['id'],
          numeroArticleController.text.trim(),
          descriptionController.text.trim(),
          int.parse(nombreController.text.trim()),
          double.parse(prixUnitaireController.text.trim()),
        );
        Get.back();
      },
    );
  }

  // 🔹 Mettre à jour le prix total automatiquement
  void _updatePrixTotal(TextEditingController nombre, TextEditingController prixUnitaire, TextEditingController prixTotal) {
    int n = int.tryParse(nombre.text) ?? 0;
    double pu = double.tryParse(prixUnitaire.text) ?? 0.0;
    prixTotal.text = (n * pu).toStringAsFixed(2);
  }


  // 🔹 Construire un champ de texte
  Widget _buildTextField(TextEditingController controller, String label, {bool isNumeric = false, bool isReadOnly = false, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        readOnly: isReadOnly,
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }
}