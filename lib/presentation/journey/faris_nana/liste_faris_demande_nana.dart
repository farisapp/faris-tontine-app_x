import 'package:faris/presentation/journey/faris_nana/faris_nana_Demande_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../controller/farisnana_controller.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/progress_dialog.dart';
import 'info_article_souscription.dart';

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
  /// Calcule le montant initial à payer selon le prix du bien
  double getPaymentAmount() {
    double price = double.tryParse(widget.prixArticle) ?? 0.0;
    if (price <= 25000) {
      return 1025;
    } else if (price < 100000) {
      return 0.07 * price;
    } else {
      return 4900;
    }
  }

  /// Calcule la pénalité en fonction du prix du bien
  double getPenalty() {
    double price = double.tryParse(widget.prixArticle) ?? 0.0;
    if (price <= 15000) {
      return 275;
    } else if (price < 100000) {
      return 0.015 * price;
    } else {
      return 1325;
    }
  }

  /// Calcule le montant à rembourser : montant initial - pénalité
  double getRefundAmount() {
    return getPaymentAmount() - getPenalty();
  }

  /// Méthode pour afficher un SnackBar
  void showCustomSnackBar(BuildContext context, String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: isError ? Colors.orangeAccent : Colors.green,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Enregistrement de l’annulation (et remboursement)
  Future<void> _saveRetrait(String operateur, String numero, String nomCompte) async {
    const String apiUrl = "https://apps.farisbusinessgroup.com/api/add_retrait.php";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          "montant": getRefundAmount().toStringAsFixed(0), // montant calculé dynamiquement
          "operateur": operateur,
          "numero": numero,
          "nom_compte": nomCompte,
          "statut": "non paye",    // Valeur par défaut
          "tontine_id": "3161",    // Valeur par défaut
        },
      );

      final responseData = json.decode(response.body);
      if (responseData["success"] == true) {
        showCustomSnackBar(context, "Annulation enregistrée avec succès.", isError: false);
      } else {
        showCustomSnackBar(context, "Erreur : ${responseData["message"]}", isError: true);
      }
    } catch (e) {
      showCustomSnackBar(context, "Erreur de connexion au serveur.", isError: true);
    }
  }

  /// Widget qui affiche le statut (0 = en cours, 1 = dispo, etc.)
  Widget _buildStatusWidget(int status) {
    Color bgColor;
    String statusText;

    switch (status) {
      case 0:
        bgColor = Colors.orange;
        statusText = "En cours de traitement";
        break;
      case 1:
        bgColor = Colors.green;
        statusText = "Disponible pour paiement";
        break;
      default:
        bgColor = Colors.grey;
        statusText = "Inconnu";
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
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  /// Confirmation avant la suppression
  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmation"),
          content: const Text(
            "Êtes-vous sûr de vouloir supprimer cette demande ?\n"
                "Cette action est irréversible.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Annuler la demande"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteDemande(id);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Oui, supprimer"),
            ),
          ],
        );
      },
    );
  }

  /// Avertissement avant d’aller au formulaire d’annulation
  void _showWarningBeforeCancel() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_outlined,
                color: Colors.orangeAccent,
                size: 30,
              ),
              const SizedBox(width: 8),
              const Text(
                "Avertissement",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.deepOrange,
                ),
              ),
            ],
          ),
          content: Text(
            "L'annulation unilatérale de votre engagement est soumise à une pénalité. Vous recevrez un remboursement de ${getRefundAmount().toStringAsFixed(0)} F en cas d'annulation.\n\n"
                "Êtes-vous sûr de vouloir continuer ?",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
              child: const Text("Retour"),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _showCancelForm();
              },
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              label: const Text(
                "Demander remboursement",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Récupération des infos d’un article (si status = 1)
  Future<void> _fetchArticleData() async {
    try {
      FarisnanaController recup = FarisnanaController();
      final result = await recup.infoArticle(widget.codeArticle);

      if (result.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => InfoArticleSouscription(codeArticle: widget.codeArticle)),
        );
      } else {
        showCustomSnackBar(context, "Article non trouvé", isError: true);
      }
    } catch (e) {
      showCustomSnackBar(context, "Erreur de connexion.", isError: true);
    }
  }

  /// Suppression de la demande
  Future<void> _deleteDemande(int id) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressDialog(message: "Suppression en cours...");
      },
    );

    try {
      FarisnanaController recup = FarisnanaController();
      int result = await recup.deleteDemandeUser(id);

      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Fermer la ProgressDialog
      }

      if (result == 1) {
        showCustomSnackBar(context, "Demande supprimée avec succès.", isError: false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FarisNanaDemandePage()),
        );
      } else {
        showCustomSnackBar(context, "Échec de la suppression.", isError: true);
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      showCustomSnackBar(context, "Erreur : ${e.toString()}", isError: true);
    }
  }

  /// Formulaire d’annulation + logos
  void _showCancelForm() {
    TextEditingController numeroController = TextEditingController();
    TextEditingController nomController = TextEditingController();
    // Initialisation du montant avec le montant à rembourser calculé dynamiquement
    final TextEditingController montantController =
    TextEditingController(text: getRefundAmount().toStringAsFixed(0));
    String selectedOperator = "Orange Money";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                "Annulation de votre demande",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Montant à rembourser
                    TextField(
                      controller: montantController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "Montant à rembourser",
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.money),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Opérateur (logos)
                    DropdownButtonFormField<String>(
                      value: selectedOperator,
                      decoration: InputDecoration(
                        labelText: "Opérateur Mobile Money",
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: "Orange Money",
                          child: Row(
                            children: [
                              Image.asset("assets/images/orange_money.png", height: 20, width: 20),
                              const SizedBox(width: 8),
                              const Text("Orange Money"),
                            ],
                          ),
                        ),
                        DropdownMenuItem<String>(
                          value: "Moov Money",
                          child: Row(
                            children: [
                              Image.asset("assets/images/moov_money.png", height: 20, width: 20),
                              const SizedBox(width: 8),
                              const Text("Moov Money"),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedOperator = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    // Numéro pour dépôt
                    TextField(
                      controller: numeroController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Numéro pour dépôt",
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Nom figurant sur le compte
                    TextField(
                      controller: nomController,
                      decoration: InputDecoration(
                        labelText: "Nom figurant sur le compte",
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Retour"),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (numeroController.text.isEmpty || nomController.text.isEmpty) {
                      showCustomSnackBar(context, "Veuillez remplir tous les champs.", isError: true);
                      return;
                    }
                    try {
                      await _saveRetrait(selectedOperator, numeroController.text, nomController.text);
                      await _deleteDemande(widget.id);
                      showCustomSnackBar(
                          context,
                          "Votre demande a été annulée, et vous allez recevoir un remboursement dans les prochaines minutes.",
                          isError: false);
                    } catch (e) {
                      showCustomSnackBar(context, "Erreur : $e", isError: true);
                    }
                  },
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    "Valider",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Si status = 1 => fetch
        if (widget.status == 1) {
          _fetchArticleData();
        } else {
          showCustomSnackBar(
              context,
              "Votre demande est en cours de traitement, le processus peut durer une semaine",
              isError: true);
        }
      },
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 5),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            gradient: widget.status == 0
                ? LinearGradient(colors: [Colors.orange.shade400, Colors.grey.shade400])
                : LinearGradient(colors: [Colors.greenAccent, Colors.grey.shade400]),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            children: [
              Row(
                children: [
                  // Icône de demande
                  Container(
                    height: 120,
                    width: 80,
                    margin: const EdgeInsets.only(right: 10),
                    child: const CircleAvatar(
                      backgroundImage: AssetImage("assets/icons/iconDemande.png"),
                      backgroundColor: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bien à acquérir: ${widget.nomArticle}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          Text(
                            'Vendeur: ${widget.boutique}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          Text(
                            'Prix du bien: ${widget.prixArticle} F',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            'Date de la demande: ${widget.dateCreation}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 5),
                          _buildStatusWidget(widget.status),
                          const SizedBox(height: 8),
                          const Icon(Icons.shopping_cart, color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Boutons "Annuler" et "Supprimer"
              Positioned(
                bottom: 5,
                right: 10,
                child: Row(
                  children: [
                    // Annuler (si statut = 0)
                    if (widget.status == 0)
                      GestureDetector(
                        onTap: _showWarningBeforeCancel,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.all(5),
                          child: const Text(
                            "Annuler et demander remboursement",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 10),
                    // Code article
                    Text(
                      "CODE: ${widget.codeArticle}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Supprimer (si statut != 0 et != 1)
                    if (widget.status != 0 && widget.status != 1)
                      GestureDetector(
                        onTap: () => _showDeleteConfirmation(widget.id),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.all(5),
                          child: const Text(
                            "Supprimer",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

