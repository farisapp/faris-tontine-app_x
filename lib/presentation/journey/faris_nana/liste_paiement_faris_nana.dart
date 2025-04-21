import 'dart:ffi';
import 'dart:io';

import 'package:faris/controller/cotiser_controller.dart';
import 'package:faris/presentation/widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controller/farisnana_controller.dart';
import '../../../utils/ussd_helper.dart';
import '../../theme/theme_color.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/progress_dialog.dart';
import '../../widgets/titre_faris_nana.dart';

class ListePaiementFarisNana extends StatefulWidget {
  final List<Map<String, dynamic>> paiements;
  final String nomArticle;
  final int id;

  const ListePaiementFarisNana({
    super.key,
    required this.paiements,
    required this.nomArticle,
    required this.id,
  });

  @override
  State<ListePaiementFarisNana> createState() => _ListePaiementFarisNanaState();
}

class _ListePaiementFarisNanaState extends State<ListePaiementFarisNana> {
  List<Map<String, dynamic>>? listepaiementData;

  final _formKey = GlobalKey<FormState>();
  final FocusScopeNode _focusScopeNode = FocusScopeNode();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool sendCodeOtp = false;

  @override
  void initState() {
    super.initState();
    // Actualisation automatique dès l'ouverture
    _initialisationData();
  }

  @override
  void dispose() {
    _telephoneController.dispose();
    _codeController.dispose();
    _focusScopeNode.dispose();
    super.dispose();
  }

  Future<void> _initialisationData() async {
    try {
      FarisnanaController recup = FarisnanaController();
      List<dynamic> result = await recup.infoArticlePaiement(widget.id);

      if (result.isNotEmpty && result.length > 2 && result[2] is List) {
        setState(() {
          listepaiementData = (result[2] as List<dynamic>)
              .map((item) => item as Map<String, dynamic>)
              .toList();
        });
      } else {
        setState(() {
          listepaiementData = [];
        });
        showCustomSnackBar(context, "Aucun paiement trouvé", isError: true);
      }
    } catch (e) {
      setState(() {
        listepaiementData = [];
      });
      showCustomSnackBar(context, "Erreur : $e", isError: true);
    }
  }

  Future<void> showPaymentBottomSheet(
      BuildContext context, String montant, int id) async {
    // On attend la fermeture du bottom sheet pour éventuellement rafraîchir la page.
    await Get.bottomSheet(
      GetBuilder<FarisnanaController>(
        builder: (farisnanaController) => Container(
          height: 450,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(25))),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    "Montant à payer: $montant FCFA",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: List.generate(
                          farisnanaController.providers.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Text(
                              "${farisnanaController.providers[index]['libelle']}",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            avatar: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Image.asset(
                                      "${farisnanaController.providers[index]['logo']}")),
                            ),
                            backgroundColor: Colors.blueGrey,
                            selectedColor: Colors.teal,
                            selected: farisnanaController.selectedProvider ==
                                farisnanaController.providers[index]['slug']
                                ? true
                                : false,
                            onSelected: (value) {
                              farisnanaController.setProvider(
                                  farisnanaController.providers[index]['slug']!);
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                  _buildPaymentForm(id, montant, farisnanaController),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    // Au retour (fermeture du bottom sheet), on rafraîchit la liste des paiements.
    _initialisationData();
  }

  Widget _buildPaymentForm(
      int id, String montant, FarisnanaController farisnanaController) {
    return Form(
      key: _formKey,
      child: FocusScope(
        node: _focusScopeNode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Numéro de téléphone de paiement",
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _telephoneController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                filled: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(10.0),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (val) => val == null || val.isEmpty
                  ? "Veuillez renseigner votre numéro de téléphone"
                  : null,
            ),
            const SizedBox(height: 10),
            farisnanaController.selectedProvider == "orange money"
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Code de validation",
                        style: TextStyle(
                            color: AppColor.kTontinet_secondary,
                            fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () => _callNumber(montant),
                      child: Text("Générer le code OTP",
                          style: TextStyle(
                              color: AppColor.kTontinet_googleColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    )
                  ],
                ),
                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(),
                      contentPadding: const EdgeInsets.all(10.0),
                      floatingLabelBehavior: FloatingLabelBehavior.never),
                  autofocus: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {},
                  validator: (String? val) {
                    if (val!.isEmpty) {
                      return "Veuillez renseigner le numéro de validation";
                    }
                  },
                ),
              ],
            )
                : const SizedBox.shrink(),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        FocusScope.of(context).requestFocus(FocusNode());
                        if (farisnanaController.selectedProvider.isEmpty) {
                          showCustomSnackBar(
                              context, "Veuillez sélectionner un opérateur");
                        } else {
                          Get.dialog(CustomerLoader(),
                              barrierDismissible: true);

                          if (farisnanaController.selectedProvider ==
                              "moov money") {
                            farisnanaController
                                .makeRequestInitMoovOtp(
                                phone: _telephoneController.text,
                                amount: montant)
                                .then((result) {
                              if (result.isSuccess) {
                                var reqId =
                                result.message.toString().split(';')[1];
                                var transId =
                                result.message.toString().split(';')[0];
                                Get.back();

                                _buildSheetOtpConfirm(context, transId, reqId, id,
                                    montant, farisnanaController);

                                showCustomSnackBar(context, "Code OTP envoyé",
                                    isError: false);
                              } else {
                                Get.back();
                                Get.back();
                                showCustomSnackBar(context, result.message);
                              }
                            });
                          } else {
                            _validatePayment(
                              id,
                              montant,
                              "",
                              "",
                              farisnanaController,
                            );
                          }
                        }
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.check_circle_outline_outlined),
                        SizedBox(width: 5),
                        Text("VALIDER"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.cancel_outlined),
                        SizedBox(width: 5),
                        Text("ANNULER"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

          if (farisnanaController.selectedProvider == "orange money")
        buildUssdButton('*144*4*6*$montant#', context),
          ],
        ),
      ),
    );
  }

  _buildSheetOtpConfirm(BuildContext context, String transId, String reqId,
      int id, String montant, FarisnanaController farisnanaController) {
    sendCodeOtp = false;
    return Get.bottomSheet(
      GetBuilder<CotiserController>(
        builder: (cotiserController) => Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            height: 450,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(25))),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Container(
                      height: 90,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25))),
                      child: Column(
                        children: [
                          Text(
                            "Confirmation OTP",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: FocusScope(
                        node: _focusScopeNode,
                        child: Column(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Code de validation",
                                        style: TextStyle(
                                            color: AppColor.kTontinet_secondary,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                TextFormField(
                                  controller: _codeController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      filled: true,
                                      border: OutlineInputBorder(),
                                      contentPadding:
                                      const EdgeInsets.all(10.0),
                                      floatingLabelBehavior:
                                      FloatingLabelBehavior.never),
                                  autofocus: false,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (value) {},
                                  validator: (String? val) {
                                    if (val!.isEmpty) {
                                      return "Veuillez renseigner le code OTP";
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());

                                    Get.dialog(CustomerLoader(),
                                        barrierDismissible: true);

                                    _validatePayment(
                                      id,
                                      montant,
                                      transId,
                                      reqId,
                                      farisnanaController,
                                    );
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline_outlined,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 5),
                                    Text("VALIDER",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold))
                                  ],
                                )),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: TextButton(
                                onPressed: () {
                                  Get.back();
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cancel_outlined,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 5),
                                    Text("ANNULER",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold))
                                  ],
                                )),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
  Widget buildUssdButton(String code, BuildContext context) {
    return GestureDetector(
      onTap: () => UssdHelper.showUssdDialog(context, code),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange),
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              code,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.orange,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _callNumber(String montant) async {
    var montantPaye = double.tryParse(montant)?.toInt() ?? 0;
    var ussdCode = '*144*4*6*$montantPaye#';
    await UssdHelper.showUssdDialog(context, ussdCode);
  }


  Future<void> _validatePayment(
      int id,
      String montant,
      String transId,
      String reqId,
      FarisnanaController farisnanaController,
      ) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Fermer explicitement le bottom sheet OTP si ouvert
      if (Get.isBottomSheetOpen ?? false) {
        Get.back(); // Ferme le bottom sheet OTP
      }

      // Affiche la boîte de dialogue de progression
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ProgressDialog(message: "Validation en cours..."),
      );

      int result = await FarisnanaController().updatePaiement(
        id,
        montant,
        farisnanaController.selectedProvider,
        _codeController.text,
        _telephoneController.text,
        transId,
        reqId,
      );

      // Ferme la ProgressDialog
      Navigator.pop(context);

      if (result == 1) {
        // Facultatif : si un autre bottom sheet est encore ouvert, le fermer
        if (Get.isBottomSheetOpen ?? false) {
          Get.back();
        }
        showCustomSnackBar(context, "Paiement validé avec succès !", isError: false);
        _initialisationData();
      } else {
        showCustomSnackBar(context, "Échec du paiement. Réessayez.", isError: true);
      }
    } catch (e) {
      Navigator.pop(context);
      showCustomSnackBar(context, "Erreur : $e", isError: true);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Cliquez sur une tranche pour payer",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontFamily: GoogleFonts.lato(fontWeight: FontWeight.w800).fontFamily,
          ),
        ),
        backgroundColor: Colors.orange, // Couleur de l'AppBar en orange
        elevation: 0,
      ),
      body: listepaiementData == null
          ? const Center(child: CircularProgressIndicator())
          : listepaiementData!.isEmpty
          ? const Center(
        child: Text(
          'Aucun paiement disponible',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: _initialisationData,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: listepaiementData!.length,
          itemBuilder: (context, index) {
            final paiement = listepaiementData![index];
            return _buildPaiementTile(paiement, index);
          },
        ),
      ),
    );
  }
  Widget _buildPaiementTile(Map<String, dynamic> paiement, int index) {
    final tranche = "${index + 1}${getOrdinalSuffix(index + 1)} tranche";

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 8),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: ListTile(
        // Déclenche l'action de paiement si le statut est "NON PAYÉ"
        onTap: paiement["status"] != 1
            ? () => showPaymentBottomSheet(
          context,
          paiement["montant_paye"].toString(),
          paiement["id"],
        )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        leading: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: paiement["status"] == 1
                ? Colors.green.withOpacity(0.3)
                : Colors.red.withOpacity(0.3),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(
            paiement["status"] == 1 ? Icons.check_circle : Icons.cancel,
            color: paiement["status"] == 1 ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          tranche,
          style: TextStyle(
            fontSize: 18,
            fontFamily: GoogleFonts.lato(fontWeight: FontWeight.w800).fontFamily,
          ),
        ),
        subtitle: Text(
          "Montant : ${paiement["montant_paye"] ?? 'Erreur'} FCFA",
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        // Affiche simplement "PAYÉ" ou "NON PAYÉ" sans bouton interactif
        trailing: paiement["status"] == 1
            ? const Text(
          "PAYÉ",
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        )
            : const Text(
          "NON PAYÉ",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String getOrdinalSuffix(int number) {
    if (number == 1) return "ère";
    return "ème";
  }
}
