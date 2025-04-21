
class StatTontine {
  String? name;
  int? value;

  StatTontine({this.name, this.value});

  StatTontine.fromJson(Map<String, dynamic> json){
    name = json['name'];
    value = json['value'] != null ? int.parse(json['value'].toString()) : 0;
  }

  toJson(){
    return {
      'name': name,
      'value': value,
    };
  }

  @override
  String toString() {
    return 'StatTontine{name: $name, value: $value}';
  }
}

List<StatTontine> statsFromJson(List<dynamic> maps) =>
    List.generate(maps.length, (i){
      return StatTontine.fromJson(maps[i]);
    });