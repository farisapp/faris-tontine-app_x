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
import 'package:faris/controller/add_tontine_controller.dart';
import 'package:faris/data/models/body/tontine_body.dart';
import 'package:faris/presentation/journey/tontine/success_page.dart';
import 'package:faris/presentation/theme/theme_color.dart';
import 'package:faris/presentation/widgets/custom_loader.dart';
import 'package:faris/presentation/widgets/custom_snackbar.dart';

class AddTontinePage extends StatefulWidget {
  final Tontine? tontine;

  AddTontinePage({Key? key, this.tontine}) : super(key: key);

  @override
  State<AddTontinePage> createState() => _AddTontinePageState();
}

class _AddTontinePageState extends State<AddTontinePage> {
  // On récupère le contrôleur via Get.find
  AddTontineController addTontineController = Get.find<AddTontineController>();

  // Contrôleurs de texte
  TextEditingController _nomController = TextEditingController();
  TextEditingController isPublicController = TextEditingController();
  TextEditingController _montantTontineController = TextEditingController();
  TextEditingController _montantFraisController = TextEditingController();
  TextEditingController _beginDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  // Variables de contrôle pour activer/désactiver des champs
  bool _enablePeriodicity = true; // Gère périodicité & nbre de membres
  bool _enableBeginDate = true;   // Gère la date de début

  bool isPublic = false; // Par défaut, l'épargne n'est pas publique
  int _minAmount = 1000;
  int _maxAmount = 300000;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _populateData();
    _initConfigData();
    super.initState();
  }

  /// Chargement des limites min/max de config
  void _initConfigData() {
    final config = Get.find<SplashController>().config;
    if (config != null) {
      if (config.minAmount != null && config.maxAmount != null) {
        _minAmount = config.minAmount!;
        _maxAmount = config.maxAmount!;
      }
    }
  }

  /// Remplit les champs si une tontine est passée en paramètre
  void _populateData() {
    if (widget.tontine != null) {
      final tontine = widget.tontine!;
      addTontineController.changeType(tontine.type!);
      _nomController.text = tontine.libelle!;
      isPublicController.text = tontine.isPublic != null
          ? tontine.isPublic!
          ? 'true'
          : 'false'
          : '';

      addTontineController.changePeriodicite(tontine.periodicite!);
      addTontineController.changeNbrePersonne(tontine.nbrePersonne!);
      addTontineController.changeDureePeriod(tontine.nbrePeriode!);

      _montantTontineController.text = tontine.montantTontine!.toString();
      _montantFraisController.text = tontine.montantTontineFrais!.toString();

      addTontineController.setMontantMise(tontine.montantTontine!.toString());
      addTontineController.setSelectedBeginDate(
        DateTime.parse(tontine.dateDebut!.toString().split(" ")[0]),
      );
      addTontineController.setSelectedEndDate(
        DateTime.parse(tontine.dateFin!.toString().split(" ")[0]),
      );

      _descriptionController.text = tontine.description ?? "";

      // Désactivation si la tontine a des paiements
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

    addTontineController.resetForm();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "CRÉATION D'UNE TONTINE EN GROUPE",
            style: TextStyle(
              color: AppColor.kTontinet_secondary,
              fontSize: 20,
              fontFamily: GoogleFonts.raleway(fontWeight: FontWeight.w800).fontFamily,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              addTontineController.resetForm();
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back,
              color: AppColor.kTontinet_secondary,
            ),
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
                  // Montant à collecter
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
                                    "Montant de la cagnotte",
                                    style: TextStyle(
                                      color: AppColor.kTontinet_secondary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 5),
                                  GetBuilder<AddTontineController>(
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
                                            text: " FCFA",
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

                  // Nom de la tontine (toujours modifiable => orange.shade200 border)
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Taper un nom pour votre tontine",
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
                          validator: (String? val) {
                            if (val!.isEmpty) {
                              return "Veuillez renseigner le nom de votre épargne";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  // Périodicité + Nombre de membres
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
                              GetBuilder<AddTontineController>(
                                builder: (addController) {
                                  final bgColor = _enablePeriodicity
                                      ? Colors.white
                                      : Colors.grey[200];
                                  final borderColor = _enablePeriodicity
                                      ? Colors.orange.shade200
                                      : Colors.grey;
                                  return Container(
                                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: bgColor,
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
                      // Nombre de membres
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Nbre de membres",
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              GetBuilder<AddTontineController>(
                                builder: (addController) {
                                  final bgColor = _enablePeriodicity
                                      ? Colors.white
                                      : Colors.grey[200];
                                  final borderColor = _enablePeriodicity
                                      ? Colors.orange.shade200
                                      : Colors.grey;
                                  return Container(
                                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      border: Border.all(color: borderColor, width: 2),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: DropdownButton<int>(
                                      dropdownColor: Colors.white,
                                      value: addController.selectedNbrePersonne,
                                      icon: Icon(Icons.keyboard_arrow_down),
                                      isExpanded: true,
                                      underline: Container(),
                                      items: addController.nbrePersonnes.map((int nbre) {
                                        return DropdownMenuItem(
                                          enabled: _enablePeriodicity,
                                          value: nbre,
                                          child: Text(
                                            "$nbre",
                                            style: TextStyle(
                                              color: _enablePeriodicity
                                                  ? Colors.black
                                                  : Colors.grey,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (int? newValue) {
                                        if (_enablePeriodicity && newValue != null) {
                                          addController.changeNbrePersonne(newValue);
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
                    ],
                  ),

                  // Montant + Montant + frais
                  Row(
                    children: [
                      // Montant (toujours modifiable => orange.shade200)
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
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (value) {
                                  addTontineController.setMontantMise(value);
                                  int? montant = int.tryParse(value);
                                  if (montant != null && montant > 0) {
                                    double montantFrais = montant +
                                        (montant *
                                            Common.getTauxTontine(
                                              Get.find<SplashController>()
                                                  .config!
                                                  .commission!,
                                              montant,
                                            ) /
                                            100);
                                    setState(() {
                                      _montantFraisController.text = montantFrais.ceil().toString();
                                    });
                                  } else {
                                    setState(() {
                                      _montantFraisController.text = "";
                                    });
                                  }
                                },
                                validator: (String? val) {
                                  if (val == null || val.isEmpty) {
                                    return "Veuillez renseigner le montant de l'épargne";
                                  }
                                  return null;
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
                                  filled: true,
                                  fillColor: Colors.grey[200],
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
                                child: GetBuilder<AddTontineController>(
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
                                child: GetBuilder<AddTontineController>(
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
                  )
                  ,
                  // Indication de la durée
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre + valeur
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Durée de votre tontine",
                              style: TextStyle(
                                color: AppColor.kTontinet_secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GetBuilder<AddTontineController>(
                              builder: (addController) => Text(
                                "${addController.dureeString}",
                                style: TextStyle(
                                  color: AppColor.kTontinet_secondary,
                                  fontFamily:
                                  GoogleFonts.raleway(fontWeight: FontWeight.w700).fontFamily,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        // Barre de progression
                        GetBuilder<AddTontineController>(
                          builder: (addController) => LinearProgressIndicator(
                            value: addController.progress,
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                            minHeight: 6,
                          ),
                        ),
                        SizedBox(height: 2),
                        // Début + Fin
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GetBuilder<AddTontineController>(
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
                            GetBuilder<AddTontineController>(
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
                        ),
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
                                DateTime beginDate = addTontineController.beginDate;
                                DateTime endDate = addTontineController.endDate;
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
                                final montant = double.parse(_montantTontineController.text);
                                if (montant >= _minAmount && montant <= _maxAmount) {
                                  // Vérification nbre de membres
                                  if (addTontineController.type == "TONTINE EN GROUPE" &&
                                      addTontineController.selectedNbrePersonne == 1) {
                                    showCustomSnackBar(
                                      context,
                                      "Vous devez avoir au moins deux membres dans votre épargne.",
                                    );
                                  } else {
                                    // OK, on crée ou on met à jour
                                    Get.dialog(CustomerLoader(), barrierDismissible: false);
                                    String type = addTontineController.type;
                                    TontineBody body = TontineBody(
                                      type: addTontineController.type,
                                      libelle: _nomController.text,
                                      isPublic: isPublic,
                                      nbre_personne: addTontineController.selectedNbrePersonne,
                                      nbre_periode: addTontineController.selectedDureePeriod,
                                      periodicite: addTontineController.selectedPeriodicite,
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
                                      addTontineController.createTontine(body).then((result) {
                                        if (result.isSuccess) {
                                          Get.back();
                                          _resetFields();
                                          Get.off(() => AddTontineSuccessPage(
                                            code_tontine: result.message ?? "",
                                            type: type,
                                          ));
                                        } else {
                                          Get.back();
                                          showCustomSnackBar(context, result.message);
                                        }
                                      });
                                    } else {
                                      // Mise à jour
                                      addTontineController
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
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        // Bouton ANNULER
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              addTontineController.resetForm();
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
                                ),
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
      initialDate: addTontineController.beginDate,
      firstDate: widget.tontine != null
          ? widget.tontine!.dateDebut!
          : DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
      lastDate: DateTime(DateTime.now().year + 1),
      helpText: "Date de début",
      cancelText: "ANNULER",
      confirmText: "OK",
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null && picked != addTontineController.beginDate) {
      addTontineController.setSelectedBeginDate(picked);
    }
  }

  /// Sélection de la date de fin (non autorisée ici)
  _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale("fr", "FR"),
      initialDate: addTontineController.endDate,
      firstDate: widget.tontine != null
          ? widget.tontine!.dateDebut!
          : DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
      lastDate: DateTime(DateTime.now().year + 1),
      helpText: "Date de fin",
      cancelText: "ANNULER",
      confirmText: "OK",
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null && picked != addTontineController.endDate) {
      addTontineController.setSelectedEndDate(picked);
    }
  }
}
