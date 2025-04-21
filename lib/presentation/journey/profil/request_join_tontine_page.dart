import 'package:flutter/material.dart';
import 'package:flutter_image_stack/flutter_image_stack.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:faris/common/common.dart';
import 'package:faris/controller/request_tontine_controller.dart';
import 'package:faris/controller/tontine_controller.dart';
import 'package:faris/presentation/theme/theme_color.dart';
import 'package:faris/presentation/widgets/app_error_widget.dart';
import 'package:faris/presentation/widgets/custom_snackbar.dart';
import 'package:faris/presentation/widgets/empty_box_widget.dart';
import 'package:faris/presentation/widgets/round_textbutton.dart';

class RequestJoinTontinePage extends StatefulWidget {
  final String tontineCode; // Non nullable mais avec une valeur par défaut

  RequestJoinTontinePage({Key? key, this.tontineCode = ""}) : super(key: key);

  @override
  _RequestJoinTontinePageState createState() => _RequestJoinTontinePageState();
}


class _RequestJoinTontinePageState extends State<RequestJoinTontinePage> {
  final TextEditingController _searchController = TextEditingController();
  final RequestTontineController _requestController = Get.find<RequestTontineController>();
  final TontineController _tontineController = Get.find<TontineController>();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.tontineCode; // Remplissage automatique
    Future.delayed(Duration(milliseconds: 500), () {
      _tontineController.searchTontine(widget.tontineCode); // Clic simulé
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Participer à une épargne en groupe",
          style: GoogleFonts.raleway(fontWeight: FontWeight.bold, color: Colors.deepOrange, fontSize: 20),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.kTontinet_secondary),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Entrez le code épargne ou tontine",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(color: Colors.brown),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 3),
                    ),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        _tontineController.resetSearch();
                      }
                    },
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  if (_searchController.text.isEmpty) {
                    showCustomSnackBar(context, "Veuillez entrer un code épargne avant de rechercher.", isError: true);
                  } else {
                    FocusScope.of(context).unfocus();
                    _tontineController.searchTontine(_searchController.text.trim());
                  }
                },
                child: GetBuilder<TontineController>(
                  builder: (tontineController) {
                    return tontineController.searchLoading
                        ? Padding(
                      padding: EdgeInsets.only(right: 20, left: 10),
                      child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                        : Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.brown),
                      child: Center(child: Icon(Icons.send, color: Colors.white)),
                    );
                  },
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: GetBuilder<TontineController>(
                builder: (tontineController) {
                  if (tontineController.searchLoading) {
                    return Center(
                      child: Text("Recherche en cours...", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    );
                  } else if (tontineController.searchTontines!.isEmpty) {
                    return Center(
                      child: EmptyBoxWidget(
                        titre: "Veuillez coller ou taper un code épargne valide et cliquer sur le bouton Envoyer",
                        icon: "assets/icons/coins_gris.svg",
                        iconType: "svg",
                      ),
                    );
                  } else if (tontineController.searchHasError) {
                    return Center(
                      child: AppErrorWidget(
                        errorType: tontineController.appErrorType,
                        onPressed: () async {
                          if (_searchController.text.isNotEmpty) {
                            await tontineController.searchTontine(_searchController.text.trim());
                          }
                        },
                      ),
                    );
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: tontineController.searchTontines!.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: EdgeInsets.all(8),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tontineController.searchTontines![index].libelle ?? "Sans titre",
                                  style: GoogleFonts.raleway(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text("Type: ${tontineController.searchTontines![index].type}"),
                                Text("Montant: ${Common.fcfa_currency_format().format(tontineController.searchTontines![index].montantTontineFrais)}"),
                                Text("Début: ${Common.convertDateToString(tontineController.searchTontines![index].dateDebut)}"),
                                Text("Fin: ${Common.convertDateToString(tontineController.searchTontines![index].dateFin)}"),
                                SizedBox(height: 10),

                                // Ajout du nom de l'organisateur
                                Text.rich(
                                  TextSpan(
                                    text: "Organisateur : ",
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                    children: [
                                      TextSpan(
                                        text: "${tontineController.searchTontines![index].createur?.displayName ?? "Inconnu"}",
                                        style: TextStyle(fontSize: 14, color: Colors.teal, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),

                                // Affichage des membres (sans images)
                                Row(
                                  children: [
                                    Icon(Icons.groups, color: Colors.teal),
                                    SizedBox(width: 5),
                                    Text(
                                      "${tontineController.searchTontines![index].membres?.length ?? 0} membres",
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 10),

                                // Bouton pour envoyer la demande
                                GetBuilder<RequestTontineController>(
                                  builder: (requestController) {
                                    return requestController.requestSending
                                        ? Center(child: CircularProgressIndicator(strokeWidth: 3))
                                        : RoundTextButton(
                                      titre: "Envoyer la demande",
                                      backgroundColor: Colors.deepOrange,
                                      textColor: Colors.white,
                                      height: 35,
                                      fontSize: 14,
                                      elevation: 2,
                                      onPressed: () {
                                        Get.defaultDialog(
                                          title: "Confirmation",
                                          middleText: "Voulez-vous vraiment demander à participer à cette épargne ?",
                                          textConfirm: "Oui",
                                          textCancel: "Non",
                                          confirmTextColor: Colors.white,
                                          onConfirm: () {
                                            requestController.sendRequest(
                                              tontineController.searchTontines![index].id!,
                                            ).then((result) {
                                              Get.back();
                                              showCustomSnackBar(context, result.message, isError: !result.isSuccess);
                                            });
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  ;}
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
