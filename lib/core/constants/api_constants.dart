class ApiConstants {
  static const String ip = "10.0.2.2";
  static const String port = "8080";
  static const String baseUrl = "http://$ip:$port/api";

  // Specific endpoints
  static const String products = "$baseUrl/products";
  static const String categories = "$baseUrl/categories";
  static const String uploadBase = "http://$ip:$port";
}