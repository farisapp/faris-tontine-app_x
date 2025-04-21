import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
// Importation du package de géocodification
import 'package:geocoding/geocoding.dart';

class MapSelectionPage extends StatefulWidget {
  final String title;

  const MapSelectionPage({Key? key, required this.title}) : super(key: key);

  @override
  _MapSelectionPageState createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapSelectionPage> {
  GoogleMapController? _mapController;
  LatLng? selectedPosition;
  LatLng? initialCameraPosition;

  @override
  void initState() {
    super.initState();
    _determineInitialPosition();
  }

  Future<void> _determineInitialPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;
      setState(() {
        initialCameraPosition = LatLng(position.latitude, position.longitude);
        selectedPosition = initialCameraPosition;
      });
    } catch (e) {
      print("Erreur dans _determineInitialPosition: $e");
    }
  }

  // Ajout de la fonction de géocodification inverse
  Future<Map<String, String>> getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;

        String city = place.locality ??
            place.administrativeArea ??
            place.subAdministrativeArea ??
            place.name ??
            "Ville inconnue";

        String neighborhood = place.subLocality ??
            place.subAdministrativeArea ??
            place.name ??
            place.street ??
            "Quartier inconnu";

        return {
          'ville': city,
          'quartier': neighborhood,
        };
      } else {
        return {'ville': "Ville inconnue", 'quartier': "Quartier inconnu"};
      }
    } catch (e) {
      print("Erreur lors de la géocodification inverse: $e");
      return {'ville': "Ville inconnue", 'quartier': "Quartier inconnu"};
    }
  }


  void _onMapTap(LatLng position) {
    setState(() {
      selectedPosition = position;
    });
  }

  void _onConfirm() async {
    if (selectedPosition != null) {
      Map<String, String> address = await getAddressFromLatLng(selectedPosition!);

      print("Ville détectée : ${address['ville']}, Quartier détecté : ${address['quartier']}");

      Navigator.pop(context, {
        "position": selectedPosition,
        "ville": address['ville'],
        "quartier": address['quartier'],
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez sélectionner un point sur la carte")),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choix de l"emplacement sur la carte',style: TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.bold),
            maxLines: 2),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.green, Colors.deepOrangeAccent]),
          ),
        ),
      ),
      body: initialCameraPosition == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialCameraPosition!,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: _onMapTap,
            markers: selectedPosition != null
                ? {
              Marker(
                markerId: MarkerId('selected'),
                position: selectedPosition!,
              ),
            }
                : {},
          ),
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: ElevatedButton.icon(
              icon: Icon(Icons.check),
              label: Text("Confirmer la position"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _onConfirm,
            ),
          ),
        ],
      ),
    );
  }
}
