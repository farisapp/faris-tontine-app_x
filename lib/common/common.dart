import 'dart:math';

import 'package:faris/data/models/config_model.dart';
import 'package:faris/presentation/widgets/round_textbutton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:faris/presentation/theme/theme_color.dart';

class Common {
  Common._();

  static getRandomListItem(List list){
    Random random = new Random();
    return list[random.nextInt(list.length)];
  }

  static getDuree(DateTime beginDate, DateTime endDate){
    return Jiffy.parse(endDate.toString()).diff(Jiffy.parse(beginDate.toString()), unit: Unit.day);
  }

  static getTontineStatut(String? statut){
    switch(statut){
      case "PENDING":
        return "NON DEMARRE";
      case "RUNNING":
        return "EN COURS";
      case "FINISHED":
        return "CLOTURE";
      default:
        return "PENDING";
    }
  }

  static Color getTontineStatutBgColor(String? status){
    switch(status){
      case "PENDING":
        return Colors.red.withOpacity(0.3);
      case "RUNNING":
        return Colors.orange.withOpacity(0.3);
      case "FINISHED":
        return Colors.green.withOpacity(0.3);
      default:
        return Colors.red.withOpacity(0.3);
    }
  }

  static Color getTontineStatutColor(String? statut){
    switch(statut){
      case "PENDING":
        return Colors.red;
      case "RUNNING":
        return Colors.orange;
      case "FINISHED":
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  static getRequestStatut(String? statut){
    switch(statut){
      case "ACCEPT":
        return "VOUS ÊTES MEMBRE";
      case "REJECT":
        return "DEMANDE D'ADHESION REJETTE";
      case "PENDING":
        return "DEMANDE EN COURS DE TRAITEMENT...";
    }
  }

  static Color getRequestStatutBgColor(String? status){
    switch(status){
      case "REJECT":
        return Colors.red.withOpacity(0.3);
      case "PENDING":
        return Colors.orange.withOpacity(0.3);
      case "ACCEPT":
        return Colors.green.withOpacity(0.3);
      default:
        return Colors.orange.withOpacity(0.3);
    }
  }

  static Color getRequestStatutColor(String? statut){
    switch(statut){
      case "REJECT":
        return Colors.red;
      case "PENDING":
        return Colors.orange;
      case "ACCEPT":
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  static String getPayStatut(String? statut){
    switch(statut){
      case "RUNNING":
        return "En cours";
      case "RECEIPT":
        return "Reçu";
      case "NOT RECEIPT":
        return "Non reçu";
      default:
        return "En attente";
    }
  }

  static Color getPayStatutColor(String? statut){
    switch(statut){
      case "RUNNING":
        return Colors.blue;
      case "RECEIPT":
        return Colors.green;
      case "NOT RECEIPT":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  static formatDate(DateTime date){
    var format = DateFormat("dd-MM-yyyy", "fr");
    return format.format(date);
  }

  static showSnackbar(String titre, String message, Color backgroundColor, Color textColor){
    Get.snackbar(titre, message, backgroundColor: backgroundColor, colorText: textColor, snackPosition: SnackPosition.BOTTOM);
  }

  static NumberFormat fcfa_currency_format(){
    return NumberFormat.currency(name: "Fcfa", symbol: "Fcfa", decimalDigits: 0, locale: "fr_FR");
  }

  static NumberFormat currency_format(){
    return NumberFormat.currency(name: "", symbol: "", decimalDigits: 0, locale: "fr_FR");
  }

  static showConfirmDialog(
      {required String titre, required String message, required VoidCallback onPressed, Color? btnConfirmColor}){
    return Get.defaultDialog(
        title: titre,
        middleText: message,
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RoundTextButton(
                  titre: "OUI",
                  backgroundColor: btnConfirmColor ?? Colors.red,
                  textColor: Colors.white,
                  fontSize: 14,
                  onPressed: onPressed
              ),
              const SizedBox(width: 10,),
              RoundTextButton(
                titre: "NON",
                width: 80,
                height: 40,
                backgroundColor: Colors.grey,
                textColor: Colors.black,
                fontSize: 14,
                onPressed: () {
                  Get.back();
                },
              )
            ],
          ),
        ]);
  }

  static phoneNumber(String phone){
    phone = phone.replaceAll(" ", "");
    phone = phone.replaceAll("-", "");
    if(phone.length == 8){
      phone = "+226"+phone;
    }
    return phone;
  }

  static pluralize(int size, String text){
    if(size > 1){
      return "$text"+"s";
    }else{
      return "$text";
    }
  }

  static convertDateToString(DateTime? date) {
    return Jiffy.parse(date.toString()).yMMMd;
  }

  static calculDuree(DateTime? debut, DateTime? fin){
    DateTime today = DateTime.now();
    //On détermine le nombre de temps qu'il reste entre aujourd'hui et la date de fin
    var duree1 = Jiffy.parse(fin.toString()).diff(Jiffy.parse(today.toString()));
    //On détermine le nombre de temps déjà fait
    var duree2 = Jiffy.parse(today.toString()).diff(Jiffy.parse(debut.toString()));
    //On détermine le nombre de temps qu'il reste entre la date de début et la date de fin
    var duree3 = Jiffy.parse(fin.toString()).diff(Jiffy.parse(debut.toString()));
    //Pourcentage du temps fait

    if(duree3 == 0){
      return 1.0;
    }else{
      return duree2 / duree3;
    }
  }

  static getTauxTontine(Commission commission, int montant){
    List<String> plageUn = commission.plageUn != null ? commission.plageUn!.split('-') : [];
    List<String> plageDeux = commission.plageDeux != null ? commission.plageDeux!.split('-') : [];
    List<String> plageTrois = commission.plageTrois != null ? commission.plageTrois!.split('-') : [];
    List<String> plageQuatre = commission.plageQuatre != null ? commission.plageQuatre!.split('>') : [];

    if(plageUn.isNotEmpty){
      //print("plageUn => $plageUn");
      if(montant >= int.parse(plageUn[0]) && montant <= int.parse(plageUn[1])){
        //print("Taux Un => ${commission.tauxUn}");
        return commission.tauxUn;
      }
    }

    if(plageDeux.isNotEmpty){
      //print("plageDeux => $plageDeux");
      if(montant >= int.parse(plageDeux[0]) && montant <= int.parse(plageDeux[1])){
        //print("Taux Deux => ${commission.tauxDeux}");
        return commission.tauxDeux;
      }
    }

    if(plageTrois.isNotEmpty){
      //print("plageTrois => $plageTrois");
      if(montant >= int.parse(plageTrois[0]) && montant <= int.parse(plageTrois[1])){
        //print("Taux Trois => ${commission.tauxTrois}");
        return commission.tauxTrois;
      }
    }

    if(plageQuatre.isNotEmpty){
      //print("plageQuatre => $plageQuatre");
      if(montant > int.parse(plageQuatre[1])){
        //print("Taux Quatre => ${commission.tauxQuatre}");
        return commission.tauxQuatre;
      }
    }

    return 3.9;
  }

  static getInitials(String? value){
    if(value != null){
      List<String> data = value.split(" ");
      if(data.length == 1){
        return data[0].substring(0, 1).toUpperCase();
      }else if(data.length >= 2){
        return data[0].substring(0, 1).toUpperCase()+""+data[1].substring(0, 1).toUpperCase();
      }else{
        return "T";
      }
    }
  }
}