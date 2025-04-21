import 'package:dotted_border/dotted_border.dart';
import 'package:faris/controller/splash_controller.dart';
import 'package:faris/data/models/config_model.dart';
import 'package:faris/data/models/tontine_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:faris/common/common.dart';
import 'package:faris/controller/indiv_add_tontine_controller.dart';
import 'package:faris/data/models/body/tontine_body.dart';
import 'package:faris/presentation/journey/tontine/success_page.dart';
import 'package:faris/presentation/theme/theme_color.dart';
import 'package:faris/presentation/widgets/custom_loader.dart';
import 'package:faris/presentation/widgets/custom_snackbar.dart';

class IndivAddTontinePage extends StatefulWidget {
  final Tontine? tontine;

  IndivAddTontinePage({Key? key, this.tontine}) : super(key: key);

  @override
  State<IndivAddTontinePage> createState() => _AddTontinePageState();
}

class _AddTontinePageState extends State<IndivAddTontinePage> {
  // Contrôleur
  IndivAddTontineController indivaddTontineController = Get.find<IndivAddTontineController>();

  // TextEditingControllers
  TextEditingController _nomController = TextEditingController();
  TextEditingController isPublicController = TextEditingController();
  TextEditingController _montantTontineController = TextEditingController();
  TextEditingController _montantFraisController = TextEditingController();
  TextEditingController _beginDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  // Contrôles pour savoir si certains champs sont modifiables
  bool _enablePeriodicity = true;
  bool _enableBeginDate = true;

  // Montant min/max
  int _minAmount = 1000;
  int _maxAmount = 300000;

  // Clé du formulaire
  final _formKey = GlobalKey<FormState>();

  // L'épargne est publique par défaut (selon votre logique existante)
  bool isPublic = false;

  @override
  void initState() {
    super.initState();
    _populateData();
    _initConfigData();
  }

  /// Initialise les minAmount / maxAmount depuis la config
  void _initConfigData() {
    if (Get.find<SplashController>().config != null) {
      if (Get.find<SplashController>().config!.minAmount != null &&
          Get.find<SplashController>().config!.maxAmount != null) {
        _minAmount = Get.find<SplashController>().config!.minAmount!;
        _maxAmount = Get.find<SplashController>().config!.maxAmount!;
      }
    }
  }

  /// Remplit les champs si on est en mode édition (widget.tontine != null)
  void _populateData() {
    if (widget.tontine != null) {
      final tontine = widget.tontine!;
      // On applique les valeurs
      indivaddTontineController.changeType(tontine.type!);
      _nomController.text = tontine.libelle!;
      isPublicController.text = tontine.isPublic != null
          ? tontine.isPublic!
          ? 'true'
          : 'false'
          : '';

      indivaddTontineController.changePeriodicite(tontine.periodicite!);
      indivaddTontineController.changeNbrePersonne(tontine.nbrePersonne!);
      indivaddTontineController.changeDureePeriod(tontine.nbrePeriode!);

      _montantTontineController.text = tontine.montantTontine!.toString();
      _montantFraisController.text = tontine.montantTontineFrais!.toString();

      indivaddTontineController.setMontantMise(tontine.montantTontine!.toString());
      indivaddTontineController.setSelectedBeginDate(
        DateTime.parse(tontine.dateDebut!.toString().split(" ")[0]),
      );
      indivaddTontineController.setSelectedEndDate(
        DateTime.parse(tontine.dateFin!.toString().split(" ")[0]),
      );
      _descriptionController.text = tontine.description ?? "";

      // Désactivation de la périodicité et de la date de début si la tontine a des paiements
      if (tontine.hasPayment == 1) {
        setState(() {
          _enablePeriodicity = false;
          _enableBeginDate = false;
        });
      }
    }
  }

  /// Réinitialise tous les champs
  void _resetFields() {
    _nomController.clear();
    isPublicController.clear();
    _montantTontineController.clear();
    _montantFraisController.clear();
    _beginDateController.clear();
    _endDateController.clear();
    _descriptionController.clear();

    indivaddTontineController.resetForm();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "CRÉATION D'UNE ÉPARGNE INDIVIDUELLE",
            style: TextStyle(
              color: AppColor.kTontinet_secondary,
              fontSize: 20,
              fontFamily: GoogleFonts.raleway(fontWeight: FontWeight.w800).fontFamily,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              indivaddTontineController.resetForm();
              Get.back();
            },
            icon: Icon(Icons.arrow_back, color: AppColor.kTontinet_secondary),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColor.kTontinet_secondary),
        ),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  // Montant total calculé (juste un affichage)
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DottedBorder(
                          borderType: BorderType.RRect,
                          radius: Radius.circular(5),
                          strokeWidth: 2,
                          color: Colors.grey,
                          child: Container(
                            height: 80,
                            margin: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade200,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Montant de l'épargne",
                                    style: TextStyle(
                                      color: AppColor.kTontinet_secondary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 5),
                                  GetBuilder<IndivAddTontineController>(
                                    builder: (addController) => RichText(
                                      text: TextSpan(
                                        text:
                                        "${Common.currency_format().format(addController.montantRamassage)}",
                                        style: TextStyle(
                                          color: AppColor.kTontinet_secondary,
                                          fontSize: 30,
                                          fontFamily: GoogleFonts.raleway(
                                            fontWeight: FontWeight.w800,
                                          ).fontFamily,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: " Fcfa",
                                            style: TextStyle(
                                              color: AppColor.kTontinet_secondary,
                                              fontSize: 15,
                                              fontFamily: GoogleFonts.raleway(
                                                fontWeight: FontWeight.w800,
                                              ).fontFamily,
                                            ),
                                          )
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Nom de l'épargne (toujours modifiable => bordure orange.shade200)
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Taper un nom pour votre épargne individuelle",
                          style: TextStyle(
                            color: AppColor.kTontinet_secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _nomController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(10.0),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.orange.shade200, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.orange.shade200, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red, width: 2),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Veuillez renseigner le nom de votre épargne";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  // Périodicité + Durée
                  Row(
                    children: [
                      // Périodicité
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Périodicité",
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              GetBuilder<IndivAddTontineController>(
                                builder: (addController) {
                                  final borderColor =
                                  _enablePeriodicity ? Colors.orange.shade200 : Colors.grey;
                                  return Container(
                                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: _enablePeriodicity
                                          ? Colors.white
                                          : Colors.grey[200],
                                      border: Border.all(color: borderColor, width: 2),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: DropdownButton<String>(
                                      dropdownColor: Colors.white,
                                      value: addController.selectedPeriodicite,
                                      icon: Icon(Icons.keyboard_arrow_down),
                                      isExpanded: true,
                                      underline: Container(),
                                      items: addController.periodicites.map((String type) {
                                        return DropdownMenuItem(
                                          enabled: _enablePeriodicity,
                                          value: type,
                                          child: Text(
                                            type,
                                            style: TextStyle(
                                              color: _enablePeriodicity
                                                  ? Colors.black
                                                  : Colors.grey,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        if (_enablePeriodicity && newValue != null) {
                                          addController.changePeriodicite(newValue);
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Durée (toujours modifiable => orange.shade200)
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Durée",
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              GetBuilder<IndivAddTontineController>(
                                builder: (addController) => Container(
                                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.orange.shade200, width: 2),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: DropdownButton<int>(
                                    dropdownColor: Colors.white,
                                    value: addController.selectedDureePeriod,
                                    icon: Icon(Icons.keyboard_arrow_down),
                                    isExpanded: true,
                                    underline: Container(),
                                    items: addController.dureePeriod.map((int nbre) {
                                      return DropdownMenuItem(
                                        value: nbre,
                                        child: Text("$nbre", style: const TextStyle(color: Colors.black)),
                                      );
                                    }).toList(),
                                    onChanged: (int? newValue) {
                                      if (newValue != null) {
                                        addController.changeDureePeriod(newValue);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Montant + Montant+frais
                  Row(
                    children: [
                      // Montant (modifiable => orange.shade200)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Montant",
                                style: TextStyle(
                                  color: AppColor.kTontinet_secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: _montantTontineController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  contentPadding: const EdgeInsets.all(10.0),
                                  floatingLabelBehavior: FloatingLabelBehavior.never,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.orange.shade200, width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.orange.shade200, width: 2),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red, width: 2),
                                  ),
                                ),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return "Veuillez renseigner le montant de l'épargne";
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  indivaddTontineController.setMontantMise(value);
                                  int? montant = int.tryParse(value);
                                  if (montant != null && montant > 0) {
                                    double montantFrais = montant +
                                        (montant *
                                            Common.getTauxTontine(
                                              Get.find<SplashController>().config!.commission!,
                                              montant,
                                            ) /
                                            100);
                                    _montantFraisController.text = montantFrais.ceil().toString();
                                  } else {
                                    _montantFraisController.text = "";
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Montant+frais (non modifiable => gris)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Montant+frais",
                                style: TextStyle(
                                  color: AppColor.kTontinet_secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: _montantFraisController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  fillColor: Colors.grey[200],
                                  filled: true,
                                  contentPadding: const EdgeInsets.all(10.0),
                                  floatingLabelBehavior: FloatingLabelBehavior.never,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey, width: 2),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey, width: 2),
                                  ),
                                ),
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                enabled: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Date de début + Date de fin
                  Row(
                    children: [
                      // DATE DE DÉBUT (avec contour orange si activé)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Date de début",
                                style: TextStyle(
                                  color: AppColor.kTontinet_secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              InkWell(
                                onTap: () => _enableBeginDate ? _selectBeginDate(context) : null,
                                child: GetBuilder<IndivAddTontineController>(
                                  builder: (addController) {
                                    final borderColor = _enableBeginDate
                                        ? Colors.orange.shade200
                                        : Colors.grey;

                                    return Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: borderColor, width: 2),
                                        borderRadius: BorderRadius.circular(5),
                                        color: _enableBeginDate ? Colors.white : Colors.grey[200],
                                      ),
                                      child: TextFormField(
                                        controller: _beginDateController,
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.all(10.0),
                                          hintText: addController.beginDate != null
                                              ? Common.formatDate(addController.beginDate!)
                                              : "Sélectionnez une date",
                                          hintStyle: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(fontSize: 16),
                                          suffixIcon: Icon(Icons.calendar_today),
                                          border: InputBorder.none,
                                        ),
                                        enabled: false,
                                        style: TextStyle(
                                          color: _enableBeginDate ? Colors.black : Colors.grey,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // DATE DE FIN (gris, non modifiable)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Date de fin",
                                style: TextStyle(
                                  color: AppColor.kTontinet_secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              InkWell(
                                onTap: () {}, // non modifiable
                                child: GetBuilder<IndivAddTontineController>(
                                  builder: (addController) => Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey, width: 2),
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.grey[200],
                                    ),
                                    child: TextFormField(
                                      controller: _endDateController,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.all(10.0),
                                        hintText: Common.formatDate(addController.endDate),
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(fontSize: 16),
                                        suffixIcon: Icon(Icons.calendar_today),
                                        border: InputBorder.none,
                                      ),
                                      enabled: false,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Indication de la durée
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Durée de votre épargne",
                              style: TextStyle(
                                color: AppColor.kTontinet_secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GetBuilder<IndivAddTontineController>(
                              builder: (addController) => Text(
                                "${addController.dureeString}",
                                style: TextStyle(
                                  color: AppColor.kTontinet_secondary,
                                  fontFamily: GoogleFonts.raleway(
                                    fontWeight: FontWeight.w700,
                                  ).fontFamily,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        // Barre de progression
                        GetBuilder<IndivAddTontineController>(
                          builder: (addController) => LinearProgressIndicator(
                            value: addController.progress,
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                            minHeight: 6,
                          ),
                        ),
                        SizedBox(height: 2),
                        // Dates de début / fin
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GetBuilder<IndivAddTontineController>(
                              builder: (addController) => Text(
                                "Début: ${Common.convertDateToString(addController.beginDate)}",
                                style: TextStyle(
                                  color: AppColor.kTontinet_secondary,
                                  fontSize: 13,
                                  fontFamily: GoogleFonts.raleway(
                                    fontWeight: FontWeight.w700,
                                  ).fontFamily,
                                ),
                              ),
                            ),
                            GetBuilder<IndivAddTontineController>(
                              builder: (addController) => Text(
                                "Fin: ${Common.convertDateToString(addController.endDate)}",
                                style: TextStyle(
                                  color: AppColor.kTontinet_secondary,
                                  fontSize: 13,
                                  fontFamily: GoogleFonts.raleway(
                                    fontWeight: FontWeight.w700,
                                  ).fontFamily,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  // Boutons (CRÉER / ANNULER)
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      children: [
                        // Bouton CREER
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                FocusScope.of(context).requestFocus(FocusNode());

                                // Vérification des dates
                                DateTime beginDate = indivaddTontineController.beginDate;
                                DateTime endDate = indivaddTontineController.endDate;

                                if (beginDate.year == endDate.year &&
                                    beginDate.month == endDate.month &&
                                    beginDate.day == endDate.day) {
                                  showCustomSnackBar(
                                    context,
                                    "Veuillez cliquer pour sélectionner une date de début, la date de fin sera calculée automatiquement.",
                                  );
                                  return;
                                }

                                // Vérification du montant
                                final montant =
                                double.parse(_montantTontineController.text);
                                if (montant >= _minAmount && montant <= _maxAmount) {
                                  // Ex: si c'est une épargne collective alors qu'on n'a qu'une personne,
                                  // on peut bloquer, etc. => vous aviez un check sur "EPARGNE COLLECTIVE"
                                  // ici on l'enlève ou on laisse
                                  if (indivaddTontineController.type == "EPARGNE COLLECTIVE" &&
                                      indivaddTontineController.selectedNbrePersonne == 1) {
                                    showCustomSnackBar(
                                      context,
                                      "Vous devez avoir au moins deux membres dans votre épargne.",
                                    );
                                  } else {
                                    Get.dialog(CustomerLoader(), barrierDismissible: false);
                                    String type = indivaddTontineController.type;

                                    TontineBody body = TontineBody(
                                      type: type,
                                      libelle: _nomController.text,
                                      isPublic: isPublic,
                                      nbre_personne:
                                      indivaddTontineController.selectedNbrePersonne,
                                      nbre_periode:
                                      indivaddTontineController.selectedDureePeriod,
                                      periodicite:
                                      indivaddTontineController.selectedPeriodicite,
                                      montant_tontine: montant,
                                      montant_tontine_frais:
                                      double.parse(_montantFraisController.text),
                                      frais: double.parse(_montantFraisController.text) - montant,
                                      date_debut: beginDate.toIso8601String().split("T")[0],
                                      date_fin: endDate.toIso8601String().split("T")[0],
                                      description: _descriptionController.text,
                                    );

                                    if (widget.tontine == null) {
                                      // Création
                                      indivaddTontineController
                                          .createTontine(body)
                                          .then((result) {
                                        if (result.isSuccess) {
                                          Get.back();
                                          _resetFields();
                                          Get.off(
                                                () => AddTontineSuccessPage(
                                              code_tontine: result.message ?? "",
                                              type: type,
                                            ),
                                          );
                                        } else {
                                          Get.back();
                                          showCustomSnackBar(context, result.message);
                                        }
                                      });
                                    } else {
                                      // Mise à jour
                                      indivaddTontineController
                                          .updateTontine(widget.tontine!.id!, body)
                                          .then((result) {
                                        if (result.isSuccess) {
                                          Get.back();
                                          _resetFields();
                                          Get.back();
                                        } else {
                                          Get.back();
                                          showCustomSnackBar(context, result.message);
                                        }
                                      });
                                    }
                                  }
                                } else {
                                  showCustomSnackBar(
                                    context,
                                    "Veuillez saisir un montant de cotisation compris entre $_minAmount et $_maxAmount",
                                  );
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
                                Icon(Icons.check_circle_outline_outlined, color: Colors.white),
                                SizedBox(width: 5),
                                Text(
                                  "CRÉER",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 5),

                        // Bouton ANNULER
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              indivaddTontineController.resetForm();
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
                                Icon(Icons.cancel_outlined, color: Colors.white),
                                SizedBox(width: 5),
                                Text(
                                  "ANNULER",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                )
                              ],
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
        ),
      ),
    );
  }

  /// Sélection de la date de début
  _selectBeginDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale("fr", "FR"),
      initialDate: indivaddTontineController.beginDate,
      firstDate: widget.tontine != null
          ? widget.tontine!.dateDebut!
          : DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      lastDate: DateTime(DateTime.now().year + 1),
      helpText: "Date de début",
      cancelText: "ANNULER",
      confirmText: "OK",
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null && picked != indivaddTontineController.beginDate) {
      indivaddTontineController.setSelectedBeginDate(picked);
    }
  }

  /// Sélection de la date de fin (non utilisée dans votre code actuel)
  _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale("fr", "FR"),
      initialDate: indivaddTontineController.endDate,
      firstDate: widget.tontine != null
          ? widget.tontine!.dateDebut!
          : DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      lastDate: DateTime(DateTime.now().year + 1),
      helpText: "Date de fin",
      cancelText: "ANNULER",
      confirmText: "OK",
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null && picked != indivaddTontineController.endDate) {
      indivaddTontineController.setSelectedEndDate(picked);
    }
  }
}
