import 'package:dotted_border/dotted_border.dart';
import 'package:faris/controller/splash_controller.dart';
import 'package:faris/data/models/config_model.dart';
import 'package:faris/data/models/tontine_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:faris/common/common.dart';
import 'package:faris/controller/col_add_tontine_controller.dart';
import 'package:faris/data/models/body/tontine_body.dart';
import 'package:faris/presentation/journey/tontine/success_page.dart';
import 'package:faris/presentation/theme/theme_color.dart';
import 'package:faris/presentation/widgets/custom_loader.dart';
import 'package:faris/presentation/widgets/custom_snackbar.dart';

class ColAddTontinePage extends StatefulWidget {
  final Tontine? tontine;

  const ColAddTontinePage({Key? key, this.tontine}) : super(key: key);

  @override
  State<ColAddTontinePage> createState() => _ColAddTontinePageState();
}

class _ColAddTontinePageState extends State<ColAddTontinePage> {
  late final ColAddTontineController coladdTontineController;

  // Champs texte
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController isPublicController = TextEditingController();
  final TextEditingController _montantTontineController = TextEditingController();
  final TextEditingController _montantFraisController = TextEditingController();
  final TextEditingController _beginDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Champ durée (à taper)
  final TextEditingController _dureeController = TextEditingController();

  bool isPublic = false;
  bool _enablePeriodicity = true;
  bool _enableBeginDate = true;

  int _minAmount = 1000;
  int _maxAmount = 300000;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // On enregistre le contrôleur
    coladdTontineController = Get.put(
      ColAddTontineController(farisTontineRepo: Get.find()),
    );

    _populateData();
    _initConfigData();
  }

  void _initConfigData() {
    final config = Get.find<SplashController>().config;
    if (config != null) {
      if (config.minAmount != null && config.maxAmount != null) {
        _minAmount = config.minAmount!;
        _maxAmount = config.maxAmount!;
      }
    }
  }

  /// Si on est en mode édition (widget.tontine != null), remplir les champs
  void _populateData() {
    if (widget.tontine != null) {
      final tontine = widget.tontine!;
      coladdTontineController.changeType(tontine.type!);
      _nomController.text = tontine.libelle!;
      isPublicController.text = tontine.isPublic == true ? 'true' : 'false';
      coladdTontineController.changePeriodicite(tontine.periodicite!);
      coladdTontineController.changeNbrePersonne(tontine.nbrePersonne!);
      coladdTontineController.changeDureePeriod(tontine.nbrePeriode!);

      // On remplit aussi le champ durée
      _dureeController.text = tontine.nbrePeriode!.toString();

      _montantTontineController.text = tontine.montantTontine!.toString();
      _montantFraisController.text = tontine.montantTontineFrais!.toString();

      coladdTontineController.setMontantMise(tontine.montantTontine!.toString());
      coladdTontineController.setSelectedBeginDate(
        DateTime.parse(tontine.dateDebut!.toString().split(" ")[0]),
      );
      coladdTontineController.setSelectedEndDate(
        DateTime.parse(tontine.dateFin!.toString().split(" ")[0]),
      );

      _descriptionController.text = tontine.description ?? "";

      // S'il y a déjà des paiements, on désactive la périodicité et la date de début
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
    _dureeController.clear();

    coladdTontineController.resetForm();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "CRÉATION D'UNE ÉPARGNE COLLECTIVE",
            style: TextStyle(
              color: AppColor.kTontinet_secondary,
              fontSize: 20,
              fontFamily: GoogleFonts.raleway(fontWeight: FontWeight.w800).fontFamily,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              coladdTontineController.resetForm();
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
                  // PARTAGE ?
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Votre épargne sera-t-elle partagée ?",
                          style: TextStyle(
                            color: AppColor.kTontinet_secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<bool>(
                                value: true,
                                groupValue: isPublic,
                                title: Text("Partager"),
                                onChanged: (bool? value) {
                                  setState(() {
                                    isPublic = value!;
                                    isPublicController.text = isPublic.toString();
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<bool>(
                                value: false,
                                groupValue: isPublic,
                                title: Text("Ne pas partager"),
                                onChanged: (bool? value) {
                                  setState(() {
                                    isPublic = value!;
                                    isPublicController.text = isPublic.toString();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // MONTANT TOTAL CALCULÉ
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
                                  GetBuilder<ColAddTontineController>(
                                    builder: (addController) => RichText(
                                      text: TextSpan(
                                        text: "${Common.currency_format().format(addController.montantRamassage)}",
                                        style: TextStyle(
                                          color: AppColor.kTontinet_secondary,
                                          fontSize: 30,
                                          fontFamily: GoogleFonts.raleway(fontWeight: FontWeight.w800).fontFamily,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: " Fcfa",
                                            style: TextStyle(
                                              color: AppColor.kTontinet_secondary,
                                              fontSize: 15,
                                              fontFamily: GoogleFonts.raleway(fontWeight: FontWeight.w800).fontFamily,
                                            ),
                                          ),
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

                  // NOM DE L'ÉPARGNE
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Taper un nom pour votre épargne collective",
                          style: TextStyle(
                            color: AppColor.kTontinet_secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _nomController,
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

                  // PÉRIODICITÉ + NBRE MEMBRES + DURÉE (CHAMP TEXTE)
                  Row(
                    children: [
                      // PÉRIODICITÉ
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Périodicité",
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              GetBuilder<ColAddTontineController>(
                                builder: (addController) {
                                  final borderColor = _enablePeriodicity
                                      ? Colors.orange.shade200
                                      : Colors.grey;
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
                                      underline: SizedBox(),
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

                      // NBRE MEMBRES
                      GetBuilder<ColAddTontineController>(
                        builder: (addTontineController) {
                          if (addTontineController.type == "EPARGNE COLLECTIVE") {
                            return Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Nbre de membres",
                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: _enablePeriodicity
                                            ? Colors.white
                                            : Colors.grey[200],
                                        border: Border.all(
                                          color: _enablePeriodicity
                                              ? Colors.orange.shade200
                                              : Colors.grey,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: DropdownButton<int>(
                                        dropdownColor: Colors.white,
                                        value: addTontineController.selectedNbrePersonne,
                                        icon: Icon(Icons.keyboard_arrow_down),
                                        isExpanded: true,
                                        underline: SizedBox(),
                                        items: addTontineController.nbrePersonnes.map((int nbre) {
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
                                            addTontineController.changeNbrePersonne(newValue);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        },
                      ),

                      // DURÉE (TEXTE) => 2..185
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Durée",
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: _dureeController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
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
                                onChanged: (value) {
                                  final intValue = int.tryParse(value) ?? 0;

                                  // Affiche un snack bar si < 2 ou > 185, mais on ne force pas la valeur
                                  if (intValue != 0 && (intValue < 2 || intValue > 185)) {
                                    showCustomSnackBar(context, "La durée doit être entre 2 et 185");
                                  }

                                  // On appelle quand même le contrôleur pour recalculer la date,
                                  // même si la valeur est hors intervalle
                                  coladdTontineController.changeDureePeriod(intValue);
                                },
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return "Veuillez renseigner la durée";
                                  }
                                  final intValue = int.tryParse(val);
                                  if (intValue == null) {
                                    return "Valeur invalide";
                                  }
                                  if (intValue < 2) {
                                    return "La durée doit être au moins 2";
                                  }
                                  if (intValue > 185) {
                                    return "La durée ne peut pas dépasser 185";
                                  }
                                  return null; // OK
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // MONTANT + MONTANT+FRAIS
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
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
                                    borderSide:
                                    BorderSide(color: Colors.orange.shade200, width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Colors.orange.shade200, width: 2),
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
                                  coladdTontineController.setMontantMise(value);
                                  final montant = int.tryParse(value);
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
                      // Montant+frais
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
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

                  // DATE DE DÉBUT + DATE DE FIN
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
                                child: GetBuilder<ColAddTontineController>(
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
                                child: GetBuilder<ColAddTontineController>(
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
                  // DURÉE DE L'ÉPARGNE (progress bar)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            GetBuilder<ColAddTontineController>(
                              builder: (addController) => Text(
                                "${addController.dureeString}",
                                style: TextStyle(
                                  color: AppColor.kTontinet_secondary,
                                  fontFamily: GoogleFonts.raleway(fontWeight: FontWeight.w700).fontFamily,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        GetBuilder<ColAddTontineController>(
                          builder: (addController) => LinearProgressIndicator(
                            value: addController.progress,
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                            minHeight: 6,
                          ),
                        ),
                        SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GetBuilder<ColAddTontineController>(
                              builder: (addController) => Text(
                                "Début: ${Common.convertDateToString(addController.beginDate)}",
                                style: TextStyle(
                                  color: AppColor.kTontinet_secondary,
                                  fontSize: 13,
                                  fontFamily: GoogleFonts.raleway(fontWeight: FontWeight.w700).fontFamily,
                                ),
                              ),
                            ),
                            GetBuilder<ColAddTontineController>(
                              builder: (addController) => Text(
                                "Fin: ${Common.convertDateToString(addController.endDate)}",
                                style: TextStyle(
                                  color: AppColor.kTontinet_secondary,
                                  fontSize: 13,
                                  fontFamily: GoogleFonts.raleway(fontWeight: FontWeight.w700).fontFamily,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // BOUTONS CREER / ANNULER
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        // CREER
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                FocusScope.of(context).requestFocus(FocusNode());

                                final beginDate = coladdTontineController.beginDate;
                                final endDate = coladdTontineController.endDate;

                                if (beginDate.year == endDate.year &&
                                    beginDate.month == endDate.month &&
                                    beginDate.day == endDate.day) {
                                  showCustomSnackBar(
                                    context,
                                    "Veuillez cliquer pour sélectionner une date de début, la date de fin sera calculée automatiquement.",
                                  );
                                  return;
                                }

                                final montant =
                                double.parse(_montantTontineController.text);
                                if (montant >= _minAmount && montant <= _maxAmount) {
                                  if (coladdTontineController.type == "EPARGNE COLLECTIVE" &&
                                      coladdTontineController.selectedNbrePersonne == 1) {
                                    showCustomSnackBar(
                                      context,
                                      "Vous devez avoir au moins deux membres dans votre épargne.",
                                    );
                                  } else {
                                    Get.dialog(CustomerLoader(), barrierDismissible: false);
                                    final type = coladdTontineController.type;

                                    TontineBody body = TontineBody(
                                      type: coladdTontineController.type,
                                      libelle: _nomController.text,
                                      isPublic: isPublic,
                                      nbre_personne: coladdTontineController.selectedNbrePersonne,
                                      nbre_periode: coladdTontineController.selectedDureePeriod,
                                      periodicite: coladdTontineController.selectedPeriodicite,
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
                                      coladdTontineController
                                          .createTontine(body)
                                          .then((result) {
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
                                      coladdTontineController
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
                        // ANNULER
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              coladdTontineController.resetForm();
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
  Future<void> _selectBeginDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale("fr", "FR"),
      initialDate: coladdTontineController.beginDate,
      firstDate: widget.tontine != null
          ? widget.tontine!.dateDebut!
          : DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      lastDate: DateTime(DateTime.now().year + 1),
      helpText: "Date de début",
      cancelText: "ANNULER",
      confirmText: "OK",
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null && picked != coladdTontineController.beginDate) {
      coladdTontineController.setSelectedBeginDate(picked);
    }
  }

  /// Sélection de la date de fin (si nécessaire)
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale("fr", "FR"),
      initialDate: coladdTontineController.endDate,
      firstDate: widget.tontine != null
          ? widget.tontine!.dateDebut!
          : DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      lastDate: DateTime(DateTime.now().year + 1),
      helpText: "Date de fin",
      cancelText: "ANNULER",
      confirmText: "OK",
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null && picked != coladdTontineController.endDate) {
      coladdTontineController.setSelectedEndDate(picked);
    }
  }
}
