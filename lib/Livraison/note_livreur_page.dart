import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NoteLivreurPage extends StatefulWidget {
  final String customId;
  const NoteLivreurPage({Key? key, required this.customId}) : super(key: key);

  @override
  State<NoteLivreurPage> createState() => _NoteLivreurPageState();
}

class _NoteLivreurPageState extends State<NoteLivreurPage> {
  double moyenne = 0.0;
  int nbNotes = 0;
  bool isLoading = true;
  List<Map<String, dynamic>> notesList = [];

  @override
  void initState() {
    super.initState();
    fetchNoteFromAllRiders();
  }
  String convertToGmt0(String dateStr) {
    try {
      final original = DateTime.parse(dateStr).toUtc();
      final adjusted = original.subtract(Duration(hours: 2)); // Si le serveur est en GMT+2
      return "${adjusted.year}-${adjusted.month.toString().padLeft(2, '0')}-${adjusted.day.toString().padLeft(2, '0')} ${adjusted.hour.toString().padLeft(2, '0')}:${adjusted.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> fetchNoteFromAllRiders() async {
    final url = Uri.parse("https://apps.farisbusinessgroup.com/api/Livraison/get_all_riders.php");
    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data['success']) {
        final List<dynamic> riders = data['riders'];
        final rider = riders.firstWhere(
              (r) => r['custom_id'] == widget.customId,
          orElse: () => null,
        );

        if (rider != null) {
          setState(() {
            moyenne = rider['note'] != null ? double.tryParse(rider['note'].toString()) ?? 0.0 : 0.0;
            nbNotes = rider['total_notes'] ?? 0;
            notesList = List<Map<String, dynamic>>.from(rider['notes'] ?? []);
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        throw data['message'];
      }
    } catch (e) {
      print("Erreur : $e");
      setState(() => isLoading = false);
    }
  }

  Widget buildStars(double note) {
    int fullStars = note.floor();
    bool halfStar = (note - fullStars) >= 0.5;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, color: Colors.amber, size: 30);
        } else if (index == fullStars && halfStar) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 30);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 30);
        }
      }),
    );
  }

  String getStatutLabel(dynamic status) {
    switch (status) {
      case 0:
        return "En attente";
      case 1:
        return "Acceptée";
      case 3:
        return "Livré";
      case 4:
        return "Non livré";
      case 5:
        return "Annulé";
      default:
        return "Inconnu";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: Text("Détails de ma note"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(2, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "$moyenne / 5",
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                ),
                const SizedBox(height: 8),
                Text(
                  "$nbNotes évaluation(s)",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                buildStars(moyenne),
                const Divider(height: 40),
                if (notesList.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Détails des notes :",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ...notesList.map((note) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.deepOrange.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 20),
                                  const SizedBox(width: 6),
                                  Text("Note : ${note['note']} / 5", style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text("Course de ${note['origin_ville']}-${note['origin_quartier']} à ${note['destination_quartier']}"),
                              Text("Date : ${convertToGmt0(note['created_at'])}"),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  )
                else
                  const Text(
                    "Aucune note pour le moment.",
                    style: TextStyle(color: Colors.grey),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
