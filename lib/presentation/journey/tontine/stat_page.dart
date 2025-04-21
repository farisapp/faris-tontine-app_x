import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:faris/controller/tontine_details_controller.dart';
import 'package:faris/data/models/stat_tontine_model.dart';
import 'package:faris/data/models/tontine_model.dart';
import 'package:faris/presentation/journey/tontine/components/statChart.dart';
import 'package:faris/presentation/theme/theme_color.dart';

class TontineStatPage extends StatefulWidget {
  final Tontine tontine;

  TontineStatPage({Key? key, required this.tontine}) : super(key: key);

  @override
  _TontineStatPageState createState() => _TontineStatPageState();
}

class _TontineStatPageState extends State<TontineStatPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loaddata(true);
  }

  void _loaddata(bool reload) async {
    await Get.find<TontineDetailsController>().getTontineStats(
      widget.tontine.id,
      reload,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Statistiques",
          style: TextStyle(
            color: AppColor.kTontinet_secondary,
            fontSize: 20,
            fontFamily: GoogleFonts.lato(fontWeight: FontWeight.w800).fontFamily,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColor.kTontinet_secondary),
      ),
      body: GetBuilder<TontineDetailsController>(builder: (detailController) {
        if (detailController.loading) {
          return Center(child: CircularProgressIndicator());
        } else if (detailController.statTontineList != null &&
            detailController.statTontineList!.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 40, 0, 20),
                    child: Text(
                      'Statistiques des cotisations',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Expanded(
                    child: StatChart(statTontines: detailController.statTontineList!),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Center(
            child: Text(
              "Aucune donnée disponible...",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }
      }),
    );
  }
}
