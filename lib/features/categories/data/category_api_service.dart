import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import 'Category.dart';

class CategoryApiService {
  Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse(ApiConstants.categories));

    if(response.statusCode == 200){
      List data = jsonDecode(response.body);
      return data.map((data) => Category.fromJson(data)).toList();
    }else{
      throw Exception('Failed to load categories');
    }
  }

  Future<Category> saveCategory(Category category, {bool isUpdate = false}) async{
    final url=isUpdate ? "${ApiConstants.categories}/${category.id}" : ApiConstants.categories;

    final response = await (isUpdate
        ? http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(category.toJson()),
    )
        : http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': category.name}), // New categories only need name
    ));

    if(response.statusCode==200||response.statusCode==201){
      return Category.fromJson(json.decode(response.body));
    }
    throw Exception('Category operation failed: ${response.body}');
  }

  Future<void> deleteCategory(int id) async {
    final response = await http.delete(Uri.parse("${ApiConstants.categories}/$id"));
    if (response.statusCode != 200 && response.statusCode != 204)
      throw Exception('Delete failed');
  }
}