import 'dart:convert';

import 'package:ecommerce/models/Product.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl="http://10.0.2.2:8080/api/products";

  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if(response.statusCode == 200){
      List data = json.decode(response.body);
      return data.map((data) => Product.fromJson(data)).toList();
    }else{
      throw Exception('Failed to load products from Spring API');
    }
  }

  Future<void> addProduct(Product product) async{
    await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(product.toJson()),
    );
  }

  Future<void> updateProduct(Product product) async {
    await http.put(
      Uri.parse("$baseUrl/${product.id}"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(product.toJson()),
    );
  }

  Future<void> deleteProduct(int id) async {
    await http.delete(Uri.parse("$baseUrl/$id"));
  }
}