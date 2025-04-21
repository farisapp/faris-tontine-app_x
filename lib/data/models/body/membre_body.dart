import 'package:faris/data/models/membre_model.dart';

class MembreBodyList {
  List<MembreBody>? membreBodies;

  MembreBodyList({this.membreBodies});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["membres"] = this.membreBodies!.map((v) => v.toJson()).toList();

    return data;
  }
}


class MembreBody {
  int? id;
  int? ordre;


  MembreBody({
    this.id,
    this.ordre,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data["ordre"] = this.ordre;

    return data;
  }

}
