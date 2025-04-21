import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// Optionnel pour déterminer le type MIME
import 'package:http_parser/http_parser.dart';
import 'package:mime_type/mime_type.dart';

class ImportVideoPage extends StatefulWidget {
  final String codeUnique;

  const ImportVideoPage({Key? key, required this.codeUnique}) : super(key: key);

  @override
  _ImportVideoPageState createState() => _ImportVideoPageState();
}

class _ImportVideoPageState extends State<ImportVideoPage> {
  bool _isUploading = false; // Pour gérer un éventuel indicateur de chargement

  Future<void> _pickAndUploadVideo() async {
    try {
      // 1) Sélection du fichier vidéo
      final result = await FilePicker.platform.pickFiles(type: FileType.video);
      if (result == null || result.files.isEmpty) {
        // L'utilisateur a annulé ou n'a pas sélectionné de fichier
        return;
      }

      setState(() {
        _isUploading = true;
      });

      final filePath = result.files.single.path!;
      final fileName = result.files.single.name;
      final file = File(filePath);

      // 2) Construire la requête Multipart
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://apps.farisbusinessgroup.com/api/upload_video_article.php'),
      );

      // Au lieu de passer article_id, on passe code_unique
      request.fields['code_unique'] = widget.codeUnique;

      // Déterminer le type MIME, ex: "video/mp4"
      final mimeStr = mime(filePath) ?? 'video/mp4';
      final mediaType = mimeStr.split('/'); // ["video","mp4"] par ex.

      // Ajouter le fichier à la requête
      request.files.add(
        await http.MultipartFile.fromPath(
          'video_file',   // Le champ attendu par l'API
          filePath,
          filename: fileName,
          contentType: MediaType(mediaType[0], mediaType[1]),
        ),
      );

      // 3) Envoyer la requête
      final responseStream = await request.send();
      final response = await http.Response.fromStream(responseStream);

      setState(() {
        _isUploading = false;
      });

      // 4) Analyser la réponse
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        if (jsonBody['success'] == true) {
          // Succès
          final videoUrl = jsonBody['video_url'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Vidéo importée avec succès !\n$videoUrl")),
          );
        } else {
          // Erreur renvoyée par l'API
          final message = jsonBody['message'] ?? "Erreur inconnue";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur API : $message")),
          );
        }
      } else {
        // Erreur HTTP
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur HTTP : ${response.statusCode}")),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      // Exception (réseau, parsing, etc.)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Exception : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Importer la vidéo"),
      ),
      body: Center(
        child: _isUploading
            ? CircularProgressIndicator()
            : ElevatedButton.icon(
          onPressed: _pickAndUploadVideo,
          icon: Icon(Icons.file_upload),
          label: Text("Sélectionner la vidéo"),
        ),
      ),
    );
  }
}
