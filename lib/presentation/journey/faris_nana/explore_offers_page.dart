import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'faris_nana_achat_page.dart';
import 'info_article_souscription.dart';
import 'add_faris_nana_achat.dart';

class ExploreOffersPage extends StatefulWidget {
  const ExploreOffersPage({Key? key}) : super(key: key);

  @override
  State<ExploreOffersPage> createState() => _ExploreOffersPageState();
}

class _ExploreOffersPageState extends State<ExploreOffersPage> {
  // Variables de contrôle du scroll pour gérer le FloatingActionButton
  bool showFloatingButton = false;
  double _previousScrollOffset = 0.0;
  final ScrollController _scrollController = ScrollController();

  // Variable de recherche
  String _searchQuery = "";

  // Future stockant les articles récupérés
  late Future<Map<String, List<dynamic>>> _articlesFuture;

  @override
  void initState() {
    super.initState();
    _articlesFuture = fetchArticles();
    _scrollController.addListener(() {
      double currentOffset = _scrollController.position.pixels;
      if (currentOffset > _previousScrollOffset + 20) {
        if (showFloatingButton) setState(() => showFloatingButton = false);
      } else if (currentOffset < _previousScrollOffset - 20) {
        if (!showFloatingButton) setState(() => showFloatingButton = true);
      }
      _previousScrollOffset = currentOffset;
    });
  }

  Future<Map<String, List<dynamic>>> fetchArticles() async {
    const String apiUrl = "https://apps.farisbusinessgroup.com/api/get_articles.php";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("📢 Données API reçues : $data");
        if (data['status'] == 'success') {
          List<dynamic> articlesWeb = data['data']
              .where((article) =>
          article['code_unique'] != null &&
              article['code_unique'].startsWith('FN') &&
              article['status'] == 1)
              .toList();

          List<dynamic> articlesVenteNana = data['data']
              .where((article) =>
          article['code_unique'] != null &&
              article['code_unique'].startsWith('PN') &&
              article['status'] == 1)
              .toList();

          return {
            "articlesWeb": articlesWeb,
            "articlesVenteNana": articlesVenteNana,
          };
        } else {
          Get.snackbar(
            "Erreur",
            data['message'],
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return {"articlesWeb": [], "articlesVenteNana": []};
        }
      } else {
        Get.snackbar(
          "Erreur",
          "Erreur de serveur (${response.statusCode})",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return {"articlesWeb": [], "articlesVenteNana": []};
      }
    } catch (e) {
      Get.snackbar(
        "Erreur",
        "Erreur de connexion : $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return {"articlesWeb": [], "articlesVenteNana": []};
    }
  }

  void subscribeToArticle(String codeArticle, bool isVerified) {
    if (!isVerified) {
      Get.dialog(
        AlertDialog(
          title: const Text("⚠️ Attention"),
          content: const Text(
            "Cet article n'est pas encore vérifié. Soyez prudent avant de procéder à l'achat.",
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                Get.to(() => InfoArticleSouscription(codeArticle: codeArticle));
              },
              child: const Text("Continuer"),
            ),
          ],
        ),
      );
    } else {
      Get.to(() => InfoArticleSouscription(codeArticle: codeArticle));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Explorer nos offres Nana",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Get.to(() => FarisNanaAchatPage());
            },
            icon: const Icon(Icons.list, color: Colors.white),
            label: const Text(
              "Mes achats",
              style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      floatingActionButton: showFloatingButton
          ? Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Get.to(() => AddFarisNanaAchat());
          },
          backgroundColor: Colors.yellow,
          elevation: 4,
          icon: const Icon(Icons.question_mark, color: Colors.red),
          label: const Text(
            "Vous ne trouvez pas ce que vous cherchez ?",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _articlesFuture = fetchArticles();
          });
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Champ de recherche en haut de la page
              TextField(
                decoration: InputDecoration(
                  hintText: "Rechercher un article...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              FutureBuilder<Map<String, List<dynamic>>>(
                future: _articlesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: const [Center(child: CircularProgressIndicator())],
                    );
                  } else if (snapshot.hasError) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Center(child: Text("Une erreur s'est produite ! Veuillez réessayer."))
                      ],
                    );
                  } else if (!snapshot.hasData ||
                      (snapshot.data!['articlesWeb']!.isEmpty && snapshot.data!['articlesVenteNana']!.isEmpty)) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Text("Aucun article trouvé."),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Get.to(() => FarisNanaAchatPage());
                                  },
                                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                                  label: const Text(
                                    "Cliquez ici pour découvrir nos offres",
                                    style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade800,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    );
                  } else {
                    final articlesWeb = snapshot.data!['articlesWeb']!;
                    final articlesVenteNana = snapshot.data!['articlesVenteNana']!;
                    final filteredArticlesWeb = _searchQuery.isEmpty
                        ? articlesWeb
                        : articlesWeb.where((article) {
                      final title = article['title']?.toLowerCase() ?? "";
                      return title.contains(_searchQuery.toLowerCase());
                    }).toList();
                    final filteredArticlesVenteNana = _searchQuery.isEmpty
                        ? articlesVenteNana
                        : articlesVenteNana.where((article) {
                      final title = article['title']?.toLowerCase() ?? "";
                      return title.contains(_searchQuery.toLowerCase());
                    }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (filteredArticlesWeb.isNotEmpty) ...[
                          const Text(
                            "Nos produits et articles disponibles",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                          ),
                          const SizedBox(height: 10),
                          _buildArticlesList(filteredArticlesWeb, isAlwaysVerified: true),
                        ],
                        if (filteredArticlesVenteNana.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Text(
                            "Articles et produits de nos partenaires",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                          const SizedBox(height: 10),
                          _buildArticlesList(filteredArticlesVenteNana, isAlwaysVerified: false),
                        ],
                        if (filteredArticlesWeb.isEmpty && filteredArticlesVenteNana.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text("Aucun article ne correspond à votre recherche."),
                            ),
                          ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticlesList(List articles, {required bool isAlwaysVerified}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        bool isVerified = isAlwaysVerified || (int.tryParse(article['verifie'].toString()) == 1);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: (article['image_url'] != null && article['image_url'].isNotEmpty)
                          ? Image.network(
                        "https://apps.farisbusinessgroup.com/public/uploads/articles/${article['image_url']}",
                        width: 100,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image, size: 100);
                        },
                      )
                          : const Icon(Icons.image, size: 100),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${article['title']}",
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 5),
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isVerified ? Colors.green.shade200 : Colors.red.shade200,
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Text(
                                  isVerified ? "✅ Vérifié" : "❌ Pas encore vérifié",
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Code: ${article['code_unique']}",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            article['description'] ?? "Aucune description disponible",
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Prix: ${article['price']} F",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => subscribeToArticle(article['code_unique'] ?? "", isVerified),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                        ),
                        child: const Text(
                          "Voir les détails et acheter",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
