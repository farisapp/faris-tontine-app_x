import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';

const String taskName = "updateRiderLocationTask";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final userId = inputData?['user_id'];
    if (userId == null) return Future.value(false);

    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final response = await http.post(
        Uri.parse('https://apps.farisbusinessgroup.com/api/Livraison/update_rider_position.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': int.parse(userId),
          'latitude': position.latitude,
          'longitude': position.longitude,
        }),
      );

      print("📍 Position mise à jour : ${position.latitude}, ${position.longitude}");
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Erreur dans WorkManager : $e");
      return false;
    }
  });
}
