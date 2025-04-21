class ErrorResponse {
  List<Errors>? _errors;

  List<Errors> get errors => _errors!;

  ErrorResponse({required List<Errors> errors}){
    _errors = errors;
  }

  ErrorResponse.fromJson(dynamic json) {
    if(json["errors"] != null){
      _errors = [];
      json["errors"].forEach((v) {
        _errors!.add(Errors.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if(_errors != null){
      map['errors'] = _errors!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Errors {
  String? _code;
  String? _message;

  String get code => _code!;
  String get message => _message!;

  Errors({required String code, required String message}){
    _code = code;
    _message = _message;
  }

  Errors.fromJson(Map<String, dynamic> json) {
    _code = json['code'];
    _message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = _code;
    data['message'] = _message;
    return data;
  }
}
