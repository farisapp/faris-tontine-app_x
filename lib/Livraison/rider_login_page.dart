import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:faris/Livraison/profil_rider_page.dart';
import '../presentation/journey/home/home_page.dart';
import '../presentation/widgets/progress_dialog.dart';
import '../../../../common/app_constant.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(fontSize: 14),
      ),
      textTheme: const TextTheme(),
    ),
    home: RiderLoginPage(),
  ));
}

//=============================================================================
// RiderLoginPage : Saisie des informations personnelles
//=============================================================================
class RiderLoginPage extends StatefulWidget {
  const RiderLoginPage({Key? key}) : super(key: key);

  @override
  _RiderLoginPageState createState() => _RiderLoginPageState();
}

class _RiderLoginPageState extends State<RiderLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController prenom = TextEditingController();
  final TextEditingController telephone = TextEditingController();
  final TextEditingController cnib = TextEditingController();
  final TextEditingController email = TextEditingController();

  @override
  void initState() {
    super.initState();
    telephone.addListener(() {
      if (telephone.text.length > 8) {
        telephone.text = telephone.text.substring(0, 8);
        telephone.selection = TextSelection.fromPosition(
            TextPosition(offset: telephone.text.length));
      }
    });
    cnib.addListener(() {
      if (cnib.text.length > 9) {
        cnib.text = cnib.text.substring(0, 9);
        cnib.selection =
            TextSelection.fromPosition(TextPosition(offset: cnib.text.length));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Inscription en tant que\ncoursier",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orangeAccent, Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Utilisation d'un SingleChildScrollView pour éviter les débordements
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.red, Colors.deepOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Text(
                    "Vos informations personnelles",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                _buildTextField(prenom, "Votre nom et prénom", Icons.person,
                    isRequired: true),
                _buildTextField(
                    telephone, "Votre numéro de téléphone", Icons.phone,
                    isRequired: true, isNumeric: true, maxLength: 8),
                _buildTextField(cnib, "Numéro de votre CNIB", Icons.credit_card,
                    isRequired: true, isAlphanumeric: true, maxLength: 9),
                _buildTextField(email, "Email (facultatif)", Icons.email,
                    isEmail: true),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RiderStepTwoPage(
                            prenom: prenom.text,
                            telephone: telephone.text,
                            cnib: cnib.text,
                            email: email.text,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    "Suivant",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fonction générique de création d'un TextFormField
  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isRequired = false,
        bool isNumeric = false,
        bool isEmail = false,
        bool isAlphanumeric = false,
        int? maxLength,
        int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumeric
            ? TextInputType.number
            : (isEmail ? TextInputType.emailAddress : TextInputType.text),
        style: const TextStyle(fontSize: 16),
        inputFormatters: [
          if (isNumeric)
            FilteringTextInputFormatter.digitsOnly
          else if (isAlphanumeric)
            FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]+$')),
          if (label.contains("CNIB") || label.toLowerCase().contains("nom"))
            UpperCaseTextFormatter(),
        ],
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 16),
          prefixIcon: Icon(icon, color: Colors.orange),
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (val) {
          if (isRequired && (val == null || val.isEmpty)) {
            return "Champ obligatoire";
          }
          if (isNumeric && maxLength != null && val != null && val.length != maxLength) {
            return "Doit contenir exactement $maxLength chiffres";
          }
          if (isAlphanumeric && maxLength != null && val != null && val.length != maxLength) {
            return "Doit contenir exactement $maxLength caractères alphanumériques";
          }
          if (isEmail &&
              val != null &&
              val.isNotEmpty &&
              !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                  .hasMatch(val)) {
            return "Adresse email invalide";
          }
          return null;
        },
      ),
    );
  }
}

//=============================================================================
// RiderStepTwoPage : Complément d'inscription (Sélection ville, quartiers, etc.)
//=============================================================================
class RiderStepTwoPage extends StatefulWidget {
  final String prenom;
  final String telephone;
  final String cnib;
  final String email;

  const RiderStepTwoPage({
    Key? key,
    required this.prenom,
    required this.telephone,
    required this.cnib,
    required this.email,
  }) : super(key: key);

  @override
  _RiderStepTwoPageState createState() => _RiderStepTwoPageState();
}

class _RiderStepTwoPageState extends State<RiderStepTwoPage> {
  final _formKey = GlobalKey<FormState>();
  double? latitude;
  double? longitude;
  bool isSubmitting = false; // ← ICI

  // Données récupérées via l'API
  List<String> villesBurkinaAPI = [];
  Map<String, List<String>> quartiersParVille = {};
  bool isLoading = true;

  // Variable d'état pour la ville sélectionnée
  String? selectedVille;

  // Liste des quartiers sélectionnés
  List<String> quartiersSelectionnes = [];

  // Contrôleur pour la description
  final TextEditingController description = TextEditingController();

  // Pour le moyen de transport
  String? selectedTransport;
  List<String> moyensTransport = ["Vélo", "Moto", "Voiture"];

  @override
  void initState() {
    super.initState();
    loadVillesEtQuartiers();
    _getCurrentLocation(); // Récupère la position initiale
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
      print("📍 Localisation: $latitude, $longitude");
    } catch (e) {
      print("Erreur localisation: $e");
    }
  }

  Future<void> loadVillesEtQuartiers() async {
    try {
      final response = await http.get(Uri.parse('https://apps.farisbusinessgroup.com/api/Livraison/get_villes_quartiers.php'));
      final data = jsonDecode(response.body);
      if (data['success']) {
        final List listData = data['data'];
        setState(() {
          villesBurkinaAPI = listData.map((v) => v['nom'].toString()).toList();
          quartiersParVille = {
            for (var v in listData)
              v['nom']: List<String>.from(v['quartiers'])
          };
          if (villesBurkinaAPI.isNotEmpty && selectedVille == null) {
            selectedVille = villesBurkinaAPI.first;
          }
          isLoading = false;
        });
      } else {
        setState(() { isLoading = false; });
        print("Erreur API: ${data['message']}");
      }
    } catch (e) {
      setState(() { isLoading = false; });
      print("Exception: $e");
    }
  }

  List<String> getQuartiersList() {
    if (selectedVille == null || selectedVille!.isEmpty) {
      return [];
    } else {
      return quartiersParVille[selectedVille] ?? [];
    }
  }

  Widget _buildDropdownField(String label, List<String> items, IconData icon, {bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedVille,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 16),
          prefixIcon: Icon(icon, color: Colors.orange),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: const TextStyle(fontSize: 16)),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            selectedVille = newValue;
            quartiersSelectionnes = [];
          });
        },
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty))
            return "Champ obligatoire";
          return null;
        },
      ),
    );
  }

  Widget _buildMultiSelectQuartiersField({required String label, required List<String> items, required IconData icon}) {
    return FormField<List<String>>(
      initialValue: quartiersSelectionnes,
      validator: (value) {
        if (quartiersSelectionnes.isEmpty) {
          return "Veuillez sélectionner au moins un quartier";
        }
        return null;
      },
      builder: (FormFieldState<List<String>> state) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () async {
                  if (items.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Information"),
                        content: const Text("Veuillez sélectionner une ville en premier."),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
                        ],
                      ),
                    );
                    return;
                  }
                  final List<String>? selected = await showDialog<List<String>>(
                    context: context,
                    builder: (context) => MultiSelectQuartiersDialog(
                      title: label,
                      items: items,
                      selectedItems: quartiersSelectionnes,
                    ),
                  );
                  if (selected != null) {
                    setState(() {
                      quartiersSelectionnes = selected;
                      state.didChange(selected);
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: label,
                    labelStyle: const TextStyle(fontSize: 18),
                    prefixIcon: Icon(icon, color: Colors.orange),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    errorText: state.errorText,
                  ),
                  child: Wrap(
                    spacing: 6,
                    children: quartiersSelectionnes
                        .map((q) => Chip(
                      label: Text(q),
                      backgroundColor: Colors.orange.shade100,
                    ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDescriptionField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: 5,
        style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
          hintText: label,
          hintMaxLines: 2,
          prefixIcon: Icon(icon, color: Colors.orange),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (val) => null,
      ),
    );
  }

  Future<void> _submitForm() async {
    if (isSubmitting) return;
    setState(() => isSubmitting = true);

    if (!_formKey.currentState!.validate()) {
      setState(() => isSubmitting = false);
      return;
    }

    // Vérifie la localisation avant soumission
    await _getCurrentLocation();
    if (latitude == null || longitude == null) {
      setState(() => isSubmitting = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Localisation requise"),
          content: const Text("Veuillez activer la géolocalisation pour finaliser votre inscription."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
          ],
        ),
      );
      return;
    }

    print("Coordonnées AVANT envoi : latitude = $latitude, longitude = $longitude");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext c) {
        return ProgressDialog(message: "Enregistrement en cours...");
      },
    );

    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      final token = sharedPreferences.getString(AppConstant.TOKEN);

      if (token == null) {
        Navigator.pop(context);
        setState(() => isSubmitting = false);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Erreur"),
            content: const Text("Erreur: Token non trouvé"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
            ],
          ),
        );
        return;
      }

      final Map<String, String> requestBody = {
        'prenom': widget.prenom,
        'telephone': widget.telephone,
        'cnib': widget.cnib,
        'email': widget.email,
        'ville': selectedVille ?? '',
        'quartiers': quartiersSelectionnes.join(', '),
        'moyen_livraison': selectedTransport ?? "Non défini",
        'description': description.text,
        'latitude': latitude?.toString() ?? '',
        'longitude': longitude?.toString() ?? '',
        'platform': Theme.of(context).platform.toString().split('.').last, // android / iOS
      };

      final response = await http.post(
        Uri.parse(AppConstant.ENREGISTREMENT_FARIS_RIDER_URI),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      Navigator.pop(context); // Ferme la ProgressDialog
      setState(() => isSubmitting = false);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final riderId = responseData['data']['custom_id'] ?? "inconnu";
        _showSuccessDialog(riderId);
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Erreur"),
            content: const Text("Ce CNIB est déjà utilisé ou vous avez déjà créé un profil livreur."),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
            ],
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      setState(() => isSubmitting = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Erreur"),
          content: Text("Erreur : ${e.toString()}"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
          ],
        ),
      );
    }
  }

  void _showSuccessDialog(String riderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Succès", style: TextStyle(color: Colors.green)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
                    children: [
                      const TextSpan(
                        text: "Votre profil livreur a été créé! Rendez-vous dans votre profil pour soumettre les photos de votre CNIB afin de compléter votre profil. N'oubliez pas aussi d'activer votre profil pour recevoir les courses.\n\n",
                      ),
                      const TextSpan(
                        text: "Votre code livreur est: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: riderId,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  child: const Text("Quitter",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilRiderPage()),
                    );
                  },
                  child: const Text("Voir mon profil",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                )
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> quartiersList = getQuartiersList();

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Inscription en tant que\ncoursier",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.red, Colors.deepOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Text(
                  "Informations diverses",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              _buildDropdownField("Ville de livraison", villesBurkinaAPI, Icons.location_city),
              _buildMultiSelectQuartiersField(
                label: "Quartiers proches de vous",
                items: quartiersList,
                icon: Icons.map,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  value: selectedTransport,
                  decoration: InputDecoration(
                    labelText: "Moyen de déplacement",
                    labelStyle: const TextStyle(fontSize: 16),
                    prefixIcon: const Icon(Icons.directions_bike, color: Colors.orange),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: moyensTransport.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontSize: 16)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedTransport = newValue;
                    });
                  },
                ),
              ),
              _buildDescriptionField(description, "Décrire ici votre disponibilité ou motivation (facultatif)", Icons.description),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Retour", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Suivant", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//==============================================================================
// Widgets complémentaires
//==============================================================================

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class MultiSelectQuartiersDialog extends StatefulWidget {
  final String title;
  final List<String> items;
  final List<String> selectedItems;

  const MultiSelectQuartiersDialog({
    Key? key,
    required this.title,
    required this.items,
    required this.selectedItems,
  }) : super(key: key);

  @override
  _MultiSelectQuartiersDialogState createState() => _MultiSelectQuartiersDialogState();
}

class _MultiSelectQuartiersDialogState extends State<MultiSelectQuartiersDialog> {
  late List<String> filteredItems;
  late List<String> tempSelected;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tempSelected = List.from(widget.selectedItems);
    filteredItems = List.from(widget.items);

    _searchController.addListener(() {
      setState(() {
        filteredItems = widget.items
            .where((q) => q.toLowerCase().contains(_searchController.text.toLowerCase()))
            .toList();
      });
    });
  }

  void _ajouterNouveauQuartier() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _newQuartier = TextEditingController();
        return AlertDialog(
          title: const Text("Ajouter un quartier"),
          content: TextField(
            controller: _newQuartier,
            decoration: const InputDecoration(labelText: "Nom du quartier"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
            ElevatedButton(
              onPressed: () {
                final quartier = _newQuartier.text.trim();
                if (quartier.isNotEmpty && !tempSelected.contains(quartier)) {
                  setState(() {
                    tempSelected.add(quartier);
                    if (!widget.items.contains(quartier)) {
                      widget.items.add(quartier);
                    }
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        height: 350,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Rechercher un quartier",
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  final isSelected = tempSelected.contains(item);
                  return CheckboxListTile(
                    title: Text(item),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          tempSelected.add(item);
                        } else {
                          tempSelected.remove(item);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.add, color: Colors.orange),
                label: const Text("Ajouter un quartier", style: TextStyle(color: Colors.orange)),
                onPressed: _ajouterNouveauQuartier,
              ),
            )
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
        ElevatedButton(onPressed: () => Navigator.pop(context, tempSelected), child: const Text("Valider")),
      ],
    );
  }
}

class SearchableDropdownDialog extends StatefulWidget {
  final String title;
  final List<String> items;

  const SearchableDropdownDialog({Key? key, required this.title, required this.items}) : super(key: key);

  @override
  _SearchableDropdownDialogState createState() => _SearchableDropdownDialogState();
}

class _SearchableDropdownDialogState extends State<SearchableDropdownDialog> {
  late List<String> filteredItems;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredItems = List.from(widget.items);
    searchController.addListener(() {
      setState(() {
        filteredItems = widget.items.where((item) => item.toLowerCase().contains(searchController.text.toLowerCase())).toList();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: "Rechercher",
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              width: double.maxFinite,
              child: filteredItems.isNotEmpty
                  ? ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filteredItems[index]),
                    onTap: () {
                      Navigator.of(context).pop(filteredItems[index]);
                    },
                  );
                },
              )
                  : const Center(child: Text("Aucun résultat")),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Annuler")),
        TextButton(
          onPressed: () async {
            final newQuartier = await showDialog<String>(
              context: context,
              builder: (context) => const AddQuartierDialog(),
            );
            if (newQuartier != null && newQuartier.isNotEmpty) {
              Navigator.of(context).pop(newQuartier);
            }
          },
          child: const Text("Ajouter un quartier"),
        ),
      ],
    );
  }
}

class AddQuartierDialog extends StatefulWidget {
  const AddQuartierDialog({Key? key}) : super(key: key);

  @override
  _AddQuartierDialogState createState() => _AddQuartierDialogState();
}

class _AddQuartierDialogState extends State<AddQuartierDialog> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Ajouter un nouveau quartier"),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          decoration: const InputDecoration(labelText: "Nom du quartier"),
          validator: (val) {
            if (val == null || val.isEmpty) {
              return "Veuillez entrer un nom";
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Annuler")),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(_controller.text);
            }
          },
          child: const Text("Ajouter"),
        ),
      ],
    );
  }
}
