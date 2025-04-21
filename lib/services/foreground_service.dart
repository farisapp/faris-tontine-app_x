import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// TaskHandler personnalisé pour mettre à jour la position GPS toutes les 2 minutes
class LocationUpdateTaskHandler extends TaskHandler {
  Timer? _timer;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    print("🚀 ForegroundTask démarré");

    // Lancement manuel d’un timer toutes les 2 minutes (optionnel, car onRepeatEvent fait déjà ça)
    _timer = Timer.periodic(const Duration(minutes: 2), (_) {
      _sendLocation();
    });
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    await _sendLocation();
  }

  Future<void> _sendLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // ✅ Récupère le user_id depuis les données enregistrées
      final userId = await FlutterForegroundTask.getData(key: 'user_id');

      if (userId == null) {
        print("⚠️ user_id manquant pour mise à jour GPS");
        return;
      }

      final response = await http.post(
        Uri.parse('https://apps.farisbusinessgroup.com/api/Livraison/update_rider_position.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': int.parse(userId),
          'latitude': position.latitude,
          'longitude': position.longitude,
        }),
      );

      if (response.statusCode == 200) {
        print("📍 Position envoyée : ${position.latitude}, ${position.longitude}");
      } else {
        print("❌ Échec mise à jour position : ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Erreur GPS : $e");
    }
  }


  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    _timer?.cancel();
    print("🛑 ForegroundTask arrêté");
  }

  @override
  void onButtonPressed(String id) {
    print('🔘 Bouton notification pressé : $id');
  }

  @override
  void onNotificationPressed() {
    print('🔔 Notification cliquée');
  }
}

/// Fonction appelée par FlutterForegroundTask.startService()
@pragma('vm:entry-point') // Obligatoire en release
void startCallback() {
  FlutterForegroundTask.setTaskHandler(LocationUpdateTaskHandler());
}
