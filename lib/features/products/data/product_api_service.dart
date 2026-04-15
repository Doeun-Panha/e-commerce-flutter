import 'dart:convert';
import 'dart:io';

import 'package:ecommerce/core/constants/api_constants.dart';
import 'package:ecommerce/features/products/data/Product.dart';
import 'package:http/http.dart' as http;

class ProductApiService {
  final String baseUrl="http://192.168.1.11:8080/api/products";
  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse(ApiConstants.products));

    if(response.statusCode == 200){
      List data = json.decode(response.body);
      return data.map((data) => Product.fromJson(data)).toList();
    }else{
      throw Exception('Failed to load products');
    }
  }

  Future<Product> saveProduct(Product product, File? imageFile, {bool isUpdate = false}) async{
    final url = isUpdate ? "${ApiConstants.products}/${product.id}" : ApiConstants.products;
    var request = http.MultipartRequest(isUpdate ? 'PUT' : 'POST', Uri.parse(url));

    //Add text fields
    request.fields.addAll(product.toMultipartFields());

    //Add image file if it exists
    if(imageFile != null){
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: http.MediaType('image', 'jpeg'),
      ));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if(response.statusCode==200||response.statusCode==201){
      return Product.fromJson(json.decode(response.body));
    }
    throw Exception('Product operation failed: ${response.body}');
  }

  Future<void> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse("${ApiConstants.products}/$id"));
    if (response.statusCode != 200 && response.statusCode != 204)
      throw Exception('Delete failed');
  }


}