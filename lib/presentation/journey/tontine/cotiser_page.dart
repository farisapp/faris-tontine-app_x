import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:faris/common/common.dart';
import 'package:faris/controller/auth_controller.dart';
import 'package:faris/controller/cotiser_controller.dart';
import 'package:faris/data/models/body/cotiser_body.dart';
import 'package:faris/data/models/tontine_model.dart';
import 'package:faris/presentation/theme/theme_color.dart';
import 'package:faris/presentation/widgets/custom_loader.dart';
import 'package:faris/presentation/widgets/custom_snackbar.dart';
import 'package:faris/presentation/widgets/pediode_card_widget.dart';

import '../../../utils/ussd_helper.dart';

class CotiserPage extends StatefulWidget {
  final Tontine tontine;
  CotiserPage({Key? key, required this.tontine}) : super(key: key);

  @override
  State<CotiserPage> createState() => _CotiserPageState();
}

class _CotiserPageState extends State<CotiserPage> {
  AuthController _authController = Get.find<AuthController>();
  CotiserController _cotiserController = Get.find<CotiserController>();
  final _formKey = new GlobalKey<FormState>();
  TextEditingController _telephoneController = TextEditingController();
  TextEditingController _codeController = TextEditingController();
  FocusScopeNode _focusScopeNode = FocusScopeNode();
  bool sendCodeOtp = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData(true);
  }

  void _loadData(bool reload) {
    Future.delayed(const Duration(seconds: 0), () {
      _cotiserController.getPeriodicitesWithCotisations(
          widget.tontine.id, reload);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Payer ma cotisation",
          style: TextStyle(
              color: AppColor.kTontinet_secondary,
              fontSize: 20,
              fontFamily:
              GoogleFonts.raleway(fontWeight: FontWeight.w800).fontFamily),
        ),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back,
              color: AppColor.kTontinet_secondary,
            )),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColor.kTontinet_secondary),
      ),
      body: GetBuilder<CotiserController>(builder: (cotiserController) {
        if (cotiserController.periodiciteLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (cotiserController.periodicites != null) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 5, bottom: 20),
                  child: Text(
                    "Vueillez sélectionnez une date pour payer",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: cotiserController.periodicites?.length,
                      itemBuilder: (context, index) {
                        return PeriodeCardWidget(
                          periodicite: cotiserController.periodicites?[index],
                          onPress: () async {
                            _telephoneController.text = "";
                            _codeController.text = "";
                            if (index == 0 &&
                                cotiserController.periodicites?[index].isPaid ==
                                    0) {
                              cotiserController.setPeriodicite(
                                  cotiserController.periodicites?[index]);
                              //remplacer par _buildCotiserSheet
                              await _buildCotiserSheet(context);
                            } else if (index > 0) {
                              if (cotiserController
                                  .periodicites?[index].isPaid ==
                                  0 &&
                                  cotiserController
                                      .periodicites?[index - 1].isPaid ==
                                      1) {
                                cotiserController.setPeriodicite(
                                    cotiserController.periodicites?[index]);
                                await _buildCotiserSheet(context);
                              } else if (cotiserController
                                  .periodicites?[index].isPaid ==
                                  1 &&
                                  cotiserController
                                      .periodicites?[index - 1].isPaid ==
                                      1) {
                              } else {
                                showCustomSnackBar(context,
                                    "Vous devez vous acquitez de la cotosation du mois précédent.");
                              }
                            }
                          },
                        );
                      }),
                )
              ],
            );
          } else {
            return const SizedBox.shrink();
          }
        }
      }),
    );
  }
  Future<void> _callNumber(String montant) async {
    final code = '*144*4*6*$montant#';
    await UssdHelper.showUssdDialog(context, code);
  }


  _buildCotiserSheet(BuildContext context) {
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
                                "${Common.convertDateToString(DateTime.parse(cotiserController.selectedPeriode!.libelle!))}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                "${Common.fcfa_currency_format().format(cotiserController.selectedPeriode?.montantCotisation)}",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            children: List.generate(
                                cotiserController.providers.length,
                                    (index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: ChoiceChip(
                                      label: Text(
                                        "${cotiserController.providers[index]['libelle']}",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      avatar: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Image.asset(
                                                "${cotiserController.providers[index]['logo']}")),
                                      ),
                                      backgroundColor: Colors.blueGrey,
                                      selectedColor: Colors.teal,
                                      selected: cotiserController.selectedProvider ==
                                          cotiserController.providers[index]
                                          ['slug']
                                          ? true
                                          : false,
                                      onSelected: (value) {
                                        cotiserController.setProvider(
                                            cotiserController.providers[index]
                                            ['slug']!);
                                      },
                                    ),
                                  );
                                }),
                          ),
                        ),
                        Form(
                          key: _formKey,
                          child: FocusScope(
                            node: _focusScopeNode,
                            child: Column(
                              children: [
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text("Numéro de téléphone de paiement",
                                        style: TextStyle(
                                            color: AppColor.kTontinet_secondary,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    TextFormField(
                                      controller: _telephoneController,
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
                                      onEditingComplete:
                                      _focusScopeNode.nextFocus,
                                      validator: (String? val) {
                                        if (val!.isEmpty) {
                                          return "Veuillez renseigner votre numéro de téléphone";
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                cotiserController.selectedProvider ==
                                    "orange money"
                                    ? Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                      children: [
                                        Text("Code de validation",
                                            style: TextStyle(
                                                color: AppColor
                                                    .kTontinet_secondary,
                                                fontWeight:
                                                FontWeight.bold)),
                                        TextButton(
                                          onPressed: () => _callNumber(
                                              cotiserController
                                                  .selectedPeriode!
                                                  .montantCotisation
                                                  .toString()),
                                          child: Text(
                                              "Générer le code OTP",
                                              style: TextStyle(
                                                  color: AppColor
                                                      .kTontinet_googleColor,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  fontSize: 12)),
                                        )
                                      ],
                                    ),
                                    TextFormField(
                                      controller: _codeController,
                                      keyboardType:
                                      TextInputType.number,
                                      decoration: InputDecoration(
                                          filled: true,
                                          border: OutlineInputBorder(),
                                          contentPadding:
                                          const EdgeInsets.all(10.0),
                                          floatingLabelBehavior:
                                          FloatingLabelBehavior.never),
                                      autofocus: false,
                                      inputFormatters: [
                                        FilteringTextInputFormatter
                                            .digitsOnly,
                                      ],
                                      onChanged: (value) {},
                                      validator: (String? val) {
                                        if (val!.isEmpty) {
                                          return "Veuillez renseigner le numéro de validation";
                                        }
                                      },
                                    ),
                                    SizedBox(height: 5),
                                  ],
                                )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        // Ligne contenant les boutons VALIDER et ANNULER
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                        if (cotiserController.selectedProvider.isEmpty) {
                                          showCustomSnackBar(context,
                                              "Veuillez sélectionner un opérateur");
                                        } else {
                                          print("période: ");
                                          print(cotiserController.selectedPeriode!.id.toString());
                                          Get.dialog(CustomerLoader(),
                                              barrierDismissible: true);
                                          CotiserBody body = new CotiserBody(
                                              tontine: widget.tontine.id,
                                              periode: cotiserController.selectedPeriode!.id,
                                              montant: double.parse(cotiserController.selectedPeriode!.montantCotisation.toString()),
                                              provider: cotiserController.selectedProvider,
                                              telephone: _telephoneController.text.trim(),
                                              code_otp: _codeController.text.trim().isEmpty
                                                  ? "000000"
                                                  : _codeController.text.trim());
                                          if (cotiserController.selectedProvider == "moov money") {
                                            cotiserController.makeRequestInitMoovOtp(
                                                phone: _telephoneController.text,
                                                amount: cotiserController.selectedPeriode!.montantCotisation.toString())
                                                .then((result) {
                                              if (result.isSuccess) {
                                                Get.back();
                                                _buildSheetOtpConfirm(context, result.message.toString());
                                                showCustomSnackBar(context,
                                                    "Code OTP envoyé",
                                                    isError: false);
                                              } else {
                                                Get.back();
                                                Get.back();
                                                showCustomSnackBar(context,
                                                    result.message);
                                              }
                                            });
                                          } else {
                                            cotiserController.cotiser(body).then((result) {
                                              if (result.isSuccess) {
                                                Get.back();
                                                Get.back();
                                                cotiserController.getPeriodicitesWithCotisations(widget.tontine.id, true);
                                                showCustomSnackBar(context, result.message, isError: false);
                                              } else {
                                                Get.back();
                                                showCustomSnackBar(context, result.message);
                                              }
                                            });
                                          }
                                        }
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
                        // Nouveau bouton Copier le code USSD en dessous
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              String codeUSSD = '*144*4*6*${cotiserController.selectedPeriode?.montantCotisation}#';
                              Clipboard.setData(ClipboardData(text: codeUSSD));
                              showCustomSnackBar(context, "Code USSD copié : $codeUSSD", isError: false);
                            },
                            icon: Icon(Icons.copy, color: Colors.deepOrange),
                            label: Text(
                              "Copier le code USSD",
                              style: TextStyle(color: Colors.orange),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.all(5.0),
                              side: BorderSide.none, // Supprime le contour
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )),
        isScrollControlled: true);
  }


  _buildSheetOtpConfirm(BuildContext context,String contentvar) {
    sendCodeOtp = false;
    String transId=contentvar.split(";")[0];
    String reqId=contentvar.split(";")[1];
    return Get.bottomSheet(
        GetBuilder<CotiserController>(
            builder: (cotiserController) => Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.9,
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
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                      children: [
                                        Text("Code de validation",
                                            style: TextStyle(
                                                color: AppColor
                                                    .kTontinet_secondary,
                                                fontWeight:
                                                FontWeight.bold)),
                                      ],
                                    ),
                                    TextFormField(
                                      controller: _codeController,
                                      keyboardType:
                                      TextInputType.number,
                                      decoration: InputDecoration(
                                          filled: true,
                                          border:
                                          OutlineInputBorder(),
                                          contentPadding:
                                          const EdgeInsets.all(
                                              10.0),
                                          floatingLabelBehavior:
                                          FloatingLabelBehavior
                                              .never),
                                      autofocus: false,
                                      inputFormatters: [
                                        FilteringTextInputFormatter
                                            .digitsOnly,
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
                                //otpppp

                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                    onPressed: () {
                                      if (_formKey.currentState!
                                          .validate()) {
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());

                                        Get.dialog(CustomerLoader(),
                                            barrierDismissible: true);
                                        CotiserBody body = new CotiserBody(
                                            tontine: widget.tontine.id,
                                            periode: cotiserController
                                                .selectedPeriode!.id,
                                            trans_id: transId,
                                            request_id: reqId,
                                            montant: double.parse(
                                                cotiserController
                                                    .selectedPeriode!
                                                    .montantCotisation
                                                    .toString()),
                                            provider: "moov money",
                                            telephone:
                                            _telephoneController.text
                                                .trim(),
                                            code_otp: _codeController.text
                                                .trim()
                                                .isEmpty
                                                ? "000000"
                                                : _codeController.text
                                                .trim());


                                        cotiserController
                                            .cotiser(body,provider: "moov money")
                                            .then((result) {
                                          if (result.isSuccess) {
                                            sendCodeOtp = true;
                                            Get.back();
                                            Get.back();
                                            Get.back();
                                            showCustomSnackBar(context,
                                                "Payement effectué avec succès",
                                                isError: false);
                                          } else {
                                            Get.back();
                                            showCustomSnackBar(context,
                                                result.message);
                                          }
                                        });


                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      //minimumSize: Size(width, height),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(5),
                                      ),
                                      backgroundColor: Colors.green,
                                      //padding: EdgeInsets.symmetric(horizontal: 40)
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons
                                              .check_circle_outline_outlined,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 5),
                                        Text("VALIDER",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight:
                                                FontWeight.bold))
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
                                      //minimumSize: Size(100, 40),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(5),
                                      ),
                                      backgroundColor: Colors.red,
                                      //padding: EdgeInsets.symmetric(horizontal: 40)
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.cancel_outlined,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 5),
                                        Text("ANNULER",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight:
                                                FontWeight.bold))
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
            )),
        isScrollControlled: true);
  }



}
