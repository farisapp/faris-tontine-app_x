class ApiResponse {
  final int httpCode;
  final ResponseData response;

  ApiResponse({
    required this.httpCode,
    required this.response,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      httpCode: json['http_code'],
      response: ResponseData.fromJson(json['response']),
    );
  }
}

class ResponseData {
  final String requestId;
  final String transId;
  final String status;
  final String message;

  ResponseData({
    required this.requestId,
    required this.transId,
    required this.status,
    required this.message,
  });

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      requestId: json['request-id'],
      transId: json['trans-id'],
      status: json['status'],
      message: json['message'],
    );
  }
}