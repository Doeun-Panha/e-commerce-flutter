class ApiConstants {
  //IP
  static const String androidIp = "10.0.2.2";
  static const String iosIp = "localhost";
  static const String physicalDeviceIp = "192.168.x.x"; //Replace with actual ip

  static const String ip = androidIp;

  static const String port = "8080";

  //BaseUrl
  static const String baseUrl = "http://$ip:$port/api";

  //Auth endpoints
  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/register}";

  //Specific endpoints
  static const String products = "$baseUrl/products";
  static const String categories = "$baseUrl/categories";

  //For images served by API
  static const String uploadBase = "http://$ip:$port";

  //Headers
  static Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  //Timeouts
  static const int connectTimeout = 15000; //15sec
  static const int receiveTimeout = 15000; //15sec

  //Status Codes
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusUnauthorized = 401;
  static const int statusNotFound = 404;
  static const int statusInternalError = 500;
}