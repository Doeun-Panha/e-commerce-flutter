import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Add this
import '../../../core/constants/api_constants.dart';
import 'Product.dart';

class ProductApiService {
  final _storage = const FlutterSecureStorage();

  // Helper to get headers with the Token
  Future<Map<String, String>> _getHeaders() async {
    String? token = await _storage.read(key: 'jwt_token');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse(ApiConstants.products),
      headers: await _getHeaders(), // Use the helper
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((data) => Product.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  Future<Product> saveProduct(Product product, File? imageFile, {bool isUpdate = false}) async {
    final url = isUpdate ? "${ApiConstants.products}/${product.id}" : ApiConstants.products;
    var request = http.MultipartRequest(isUpdate ? 'PUT' : 'POST', Uri.parse(url));

    // 1. Add Auth Header to Multipart
    String? token = await _storage.read(key: 'jwt_token');
    request.headers['Authorization'] = 'Bearer $token';

    request.fields.addAll(product.toMultipartFields());

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: http.MediaType('image', 'jpeg'),
      ));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Product.fromJson(json.decode(response.body));
    }
    throw Exception('Product operation failed: ${response.body}');
  }

  Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse("${ApiConstants.products}/$id"),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Delete failed');
    }
  }
}