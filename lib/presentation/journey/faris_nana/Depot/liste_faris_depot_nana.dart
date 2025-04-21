import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../widgets/custom_snackbar.dart';
import '../../../widgets/progress_dialog.dart';
import 'faris_Depot_controller.dart';
import 'faris_nana_Depot_page.dart';

class ListeFarisNana extends StatefulWidget {
  final int id;
  final String codeArticle;
  final String boutique;
  final String prixArticle;
  final String numVendeur;
  final String dateCreation;
  final String nomArticle;
  final int status;

  const ListeFarisNana({
    super.key,
    required this.codeArticle,
    required this.boutique,
    required this.prixArticle,
    required this.numVendeur,
    required this.dateCreation,
    required this.nomArticle,
    required this.status,
    required this.id,
  });

  @override
  State<ListeFarisNana> createState() => _ListeFarisNanaState();
}

class _ListeFarisNanaState extends State<ListeFarisNana> {
  /// ✅ Fonction pour récupérer les articles liés au stockage_id (widget.id)
  Future<void> _fetchArticlesDepotVente() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(message: "Chargement..."),
    );

    try {
      // 🔹 Récupération de l'ID du dépôt (stockage_id)
      int stockageId = widget.id;

      // 🔹 Appel de l'API avec le stockage_id correspondant
      final response = await http.get(Uri.parse(
          "https://apps.farisbusinessgroup.com/api/get_articles_depot_ventex.php?stockarticle_id=$stockageId"));

      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Fermer le chargement
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["status"] == "success") {
          List<dynamic> articles = data["data"];

          if (articles.isNotEmpty) {
            _showArticlesDialog(articles);
          } else {
            showCustomSnackBar(context, "Demande validée mais les articles ne sont pas encore chargés.", isError: true);
          }
        } else {
          showCustomSnackBar(context, "Erreur de récupération des articles.", isError: true);
        }
      } else {
        showCustomSnackBar(context, "Erreur serveur. Réessayez plus tard.", isError: true);
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      showCustomSnackBar(context, "Erreur de connexion.", isError: true);
    }
  }


  /// ✅ Affichage des articles dans un `AlertDialog`
  void _showArticlesDialog(List<dynamic> articles) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.inventory_2, color: Colors.orangeAccent),
              const SizedBox(width: 8),
              const Text("Suivi de votre stock", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: articles.map((article) {
                // ✅ Sécuriser la conversion des valeurs récupérées
                double prixUnitaire = double.tryParse(article["prix_unitaire"]?.toString() ?? "0") ?? 0.0;
                int quantiteVendue = int.tryParse(article["quantite_vendue"]?.toString() ?? "0") ?? 0;
                int quantiteRestante = int.tryParse(article["quantite_restante"]?.toString() ?? "0") ?? 0;

                double totalVendu = prixUnitaire * quantiteVendue;
                double totalRestant = prixUnitaire * quantiteRestante;

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔹 Nom de l'article avec une icône
                        Row(
                          children: [
                            const Icon(Icons.shopping_cart, color: Colors.orangeAccent),
                            const SizedBox(width: 8),
                            Text(
                              article["nom_article"] ?? "Inconnu",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // 🔹 Informations sous forme de liste
                        _buildArticleDetail(Icons.format_list_numbered, "Quantité initiale", "${article["nombre"] ?? "0"}"),
                        _buildArticleDetail(Icons.price_change, "Prix Unitaire", "${prixUnitaire.toInt()} F"),
                        _buildArticleDetail(Icons.check_circle, "Quantité vendue", "$quantiteVendue"),
                        _buildArticleDetail(Icons.storage, "Quantité restante", "$quantiteRestante"),
                        _buildArticleDetail(Icons.monetization_on, "Total Vendu", "${totalVendu.toInt()} F"), // ✅ Ajout du Total vendu
                        _buildArticleDetail(Icons.money_off, "Total Restant", "${totalRestant.toInt()} F"), // ✅ Ajout du Total restant
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Fermer", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmation"),
          content: const Text(
            "Êtes-vous sûr de vouloir supprimer ce dépôt ?\nCette action est irréversible.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
                _deleteDepot(id); // Exécuter la suppression
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text("Oui, supprimer"),
            ),
          ],
        );
      },
    );
  }
// Fonction de suppression de la Depot
  Future<void> _deleteDepot(int id) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>  ProgressDialog(message: "Suppression en cours..."),
    );

    try {
      FarisDepotController recup = FarisDepotController();
      int result = await recup.deleteDepot(id);

      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Fermer la boîte de dialogue
      }

      if (result == 1) {
        showCustomSnackBar(context, "✅ Dépôt supprimé avec succès.", isError: false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FarisNanaDepotPage()),
        );
      } else {
        showCustomSnackBar(context, "⚠️ Échec de la suppression.", isError: true);
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      showCustomSnackBar(context, "❌ Erreur : ${e.toString()}", isError: true);
    }
  }
  Future<void> _saveRetrait(String operateur, String numero, String nomCompte) async {
    const String apiUrl = "https://apps.farisbusinessgroup.com/api/add_retrait.php";

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        body: {
          "montant": "750", // ✅ Ajouter le montant explicitement
          "operateur": operateur,
          "numero": numero,
          "nom_compte": nomCompte,
          "statut": "non paye", // Valeur par défaut pour le statut
          "tontine_id": "3161", // Valeur par défaut pour la tontine_id
        },
      );

      var responseData = json.decode(response.body);
      if (responseData["success"] == true) {
        showCustomSnackBar(context, "✅ Annulation enregistrée avec succès.", isError: false);
      } else {
        showCustomSnackBar(context, "❌ Erreur : ${responseData["message"]}", isError: true);
      }
    } catch (e) {
      showCustomSnackBar(context, "❌ Erreur de connexion au serveur.", isError: true);
    }
  }

  void _confirmCancelDepot() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmer l'annulation"),
          content: const Text(
            "Êtes-vous sûr de vouloir annuler ce dépôt ?\nCette action est irréversible.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Retour"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
                _deleteDepot(widget.id); // 🔥 Suppression directe
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text("Oui, annuler"),
            ),
          ],
        );
      },
    );
  }


  /// ✅ Fonction pour créer un détail stylisé avec une icône et une valeur
  Widget _buildArticleDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.orangeAccent, size: 18),
          const SizedBox(width: 8),
          Text("$label : ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          Text(value, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.status == 1) {
          _fetchArticlesDepotVente(); // 🔥 Charge les articles liés au stockage_id
        } else {
          showCustomSnackBar(
            context,
            "Votre dépôt-vente est en cours de vérification, nous vous contacterons. Vous pouvez aussi nous contacter",
            isError: true,
          );
        }
        if (widget.status == 2) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showCustomSnackBar(context, "❌ Votre dépôt-vente est refusé, vous pouvez le supprimer.", isError: true);
          });
        }
      },
      child: SingleChildScrollView(
        child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(gradient: widget.status == 0
          ? LinearGradient(colors: [Colors.orange.shade400, Colors.grey.shade400]) // En cours de vérification (Orange)
          : widget.status == 1
          ? LinearGradient(colors: [Colors.greenAccent, Colors.grey.shade400]) // Validé (Vert)
          : LinearGradient(colors: [Colors.grey.shade600, Colors.grey.shade400]), // Refusé (Gris)
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          const BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(2, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 En-tête avec produit et statut
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    _buildStatusWidget(widget.status),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10), // Espacement avant les détails

          // 🔹 Affichage des détails du dépôt
          _buildDetailRow(Icons.shopping_bag, "Produit", widget.nomArticle),
          _buildDetailRow(Icons.inventory, "ID", "${widget.id}"),
          _buildDetailRow(Icons.date_range, "Date de création", widget.dateCreation),
         // ✅ Affichage des boutons "Annuler" et "Supprimer"
          const SizedBox(height: 10), // Espacement avant les boutons

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (widget.status == 0) // 🔹 Afficher "Annuler" si en cours de vérification
                ElevatedButton.icon(
                  onPressed: _confirmCancelDepot,
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  label: const Text("Annuler"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              const SizedBox(width: 10),
              if (widget.status != 0 && widget.status != 1) // 🔹 Afficher "Supprimer" si refusé
                ElevatedButton.icon(
                  onPressed: () => _showDeleteConfirmation(widget.id),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text("Supprimer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
    ),
    );
  }

  /// ✅ Fonction pour afficher le statut avec couleur
  Widget _buildStatusWidget(int status) {
    Color bgColor;
    String statusText;

    switch (status) {
      case 0:
        bgColor = Colors.orange;
        statusText = "En cours de vérification";
        break;
      case 1:
        bgColor = Colors.green;
        statusText = "Validé: Cliquez ici pour voir votre stock";
      case 2:
        bgColor = Colors.red;
        statusText = "Refusé";
        break;
      default:
        bgColor = Colors.grey;
        statusText = "inconnu";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  /// ✅ Fonction pour afficher une ligne de détail
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // ✅ Assure un bon alignement vertical
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label : $value", // ✅ Met tout sur la même ligne
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
