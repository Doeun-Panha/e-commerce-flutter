import 'dart:convert';

import 'package:ecommerce/model/Product.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl="http://10.0.2.2:8080/api/products";

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if(response.statusCode == 200){
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Product.fromJson(data)).toList();
    }else{
      throw Exception('Failed to load products from Spring API');
    }
  }
}