import 'dart:convert';
import 'dart:io';

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

  Future<void> addProduct(Product product, File? imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

    //Add text fields
    request.fields.addAll(product.toMultipartFields());

    //Add image file if it exists
    if(imageFile!=null){
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: http.MediaType('image', 'jpeg'),
      ));
    }

    var streamedResponse = await request.send();
    if(streamedResponse.statusCode!=200&&streamedResponse.statusCode!=201){
      throw Exception('Failed to upload product. Status: ${streamedResponse.statusCode}');
    }
  }

  Future<Product> updateProduct(Product product, File? imageFile) async {
    // Use MultipartRequest for PUT to allow file uploads
    var request = http.MultipartRequest('PUT', Uri.parse("$baseUrl/${product.id}"));

    // 1. Add existing text fields
    request.fields.addAll(product.toMultipartFields());

    // 2. Add the new image file if the user picked one
    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: http.MediaType('image', 'jpeg'),
      ));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if(response.statusCode == 200){
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update product: ${response.body}');
    }
  }

  Future<void> deleteProduct(int id) async {
    await http.delete(Uri.parse("$baseUrl/$id"));
  }
}