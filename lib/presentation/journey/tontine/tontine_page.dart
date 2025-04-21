import 'package:faris/presentation/journey/tontine/shared/public_tontine_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../controller/tontine_controller.dart';
import '../profil/request_join_tontine_page.dart';
import '../profil/user_request_list_page.dart';
import 'add_tontine_page.dart';
import 'tontine_details_page.dart';

class TontinePage extends StatefulWidget {
  const TontinePage({Key? key}) : super(key: key);

  @override
  _TontinePageState createState() => _TontinePageState();
}

class _TontinePageState extends State<TontinePage> {
  final TontineController _tontineController = Get.find<TontineController>();

  // Index de la bottom navigation
  int _currentIndex = 0;

  // Requête de recherche
  String _searchQuery = "";

  // Contrôleur pour le PageView
  final PageController _pageController = PageController();

  // Items de la bottom navigation
  final List<BottomNavigationBarItem> _bottomBarItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.list, size: 40),
      label: "Listes de vos tontines",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.group_add, size: 40),
      label: "Participer à une tontine",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_add, size: 40),
      label: "Mes demandes de participation",
    ),
  ];

  @override
  void initState() {
    super.initState();
    // ✅ On charge la liste une seule fois ici
    if (!_tontineController.isLoaded) {
      _tontineController.getTontines(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "TONTINE EN GROUPE",
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Colors.deepOrange,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.blueGrey),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          // Page 1 : Liste des tontines collectives
          _buildTontineList(),

          // Page 2 : Participer à une épargne collective
          RequestJoinTontinePage(),

          // Page 3 : Mes demandes de participation
          UserRequestListPage(),
        ],
      ),
      // Bouton de création uniquement sur la première page
      floatingActionButton: _currentIndex == 0
          ? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              Get.to(() => AddTontinePage(),
                  transition: Transition.rightToLeftWithFade);
            },
            backgroundColor: Colors.red,
            child: Icon(Icons.add, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 5),
          Text(
            "Créer une tontine",
            style: GoogleFonts.lato(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        height: 90,
        color: Colors.white,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          items: _bottomBarItems,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.black54,
          selectedLabelStyle: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTontineList() {
    return GetBuilder<TontineController>(
      builder: (tontineController) {
        // Vérifier si les données sont chargées
        if (!tontineController.isLoaded) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        }

        // Filtrage des épargnes collectives par nom (libelle)
        final tontinesCollectives = tontineController.tontines!
            .where((tontine) =>
        tontine.type != null &&
            tontine.type!.toUpperCase().contains("TONTINE") &&
            tontine.libelle != null &&
            tontine.libelle!
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();

        return Column(
          children: [
            // Champ de recherche
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Rechercher par nom",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Expanded(
              child: tontinesCollectives.isEmpty
                  ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Aucune tontine trouvée. Cliquez sur le bouton <Créer une tontine> pour commencer.\n"
                          "Vous pouvez aussi aller voir les épargnes en groupe partagées publiquement pour participer",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Naviguer vers la page PublicTontinesPage
                        Get.to(() => PublicTontinesPage(),
                            transition: Transition.rightToLeftWithFade);
                      },
                      child: Text(
                        "<ÉPARGNES EN GROUPE PARTAGÉES>",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : RefreshIndicator(
                onRefresh: () async {
                  // Permet de rafraîchir la liste
                  await tontineController.getTontines(true);
                },
                child: ListView.builder(
                  itemCount: tontinesCollectives.length,
                  itemBuilder: (context, index) {
                    final tontine = tontinesCollectives[index];
                    final backgroundColor = index.isEven
                        ? Colors.orange.shade100
                        : Colors.orange.shade200;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // CODE EPARGNE
                              Row(
                                children: [
                                  const Icon(Icons.confirmation_number,
                                      size: 16, color: Colors.red),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      "CODE TONTINE: ${tontine.numero}",
                                      style: GoogleFonts.lato(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // TYPE
                              Row(
                                children: [
                                  const Icon(Icons.category,
                                      size: 16, color: Colors.black),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      "TYPE: ${tontine.type}",
                                      style: GoogleFonts.lato(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // NOM
                              Row(
                                children: [
                                  const Icon(Icons.person,
                                      size: 16, color: Colors.black),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      "NOM: ${tontine.libelle}",
                                      style: GoogleFonts.lato(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // MONTANT
                              Row(
                                children: [
                                  const Icon(Icons.attach_money,
                                      size: 16, color: Colors.black),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      "MONTANT COTISATION: ${tontine.montantTontine} FCFA",
                                      style: GoogleFonts.lato(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Bouton d’ouverture
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.to(
                                          () => TontineDetailsPage(
                                          tontine: tontine),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    Colors.orange.shade600,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.arrow_forward,
                                          color: Colors.blue, size: 20),
                                      const SizedBox(width: 12),
                                      Text(
                                        "Cliquez ici pour ouvrir",
                                        style: GoogleFonts.lato(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
