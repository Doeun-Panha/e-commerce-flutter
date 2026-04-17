import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/api_constants.dart';
import 'Category.dart';

class CategoryApiService {
  final _storage = const FlutterSecureStorage();

  // 1. Private helper to handle Authorization headers
  Future<Map<String, String>> _getHeaders() async {
    String? token = await _storage.read(key: 'jwt_token');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // 2. Fetch all categories
  Future<List<Category>> getCategories() async {
    final response = await http.get(
      Uri.parse(ApiConstants.categories),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((data) => Category.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }
  }

  // 3. Save or Update category
  Future<Category> saveCategory(Category category, {bool isUpdate = false}) async {
    final url = isUpdate
        ? "${ApiConstants.categories}/${category.id}"
        : ApiConstants.categories;

    final headers = await _getHeaders();
    final body = json.encode(isUpdate ? category.toJson() : {'name': category.name});

    final response = await (isUpdate
        ? http.put(Uri.parse(url), headers: headers, body: body)
        : http.post(Uri.parse(url), headers: headers, body: body));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Category.fromJson(json.decode(response.body));
    }
    throw Exception('Category operation failed: ${response.body}');
  }

  // 4. Delete category
  Future<void> deleteCategory(int id) async {
    final response = await http.delete(
      Uri.parse("${ApiConstants.categories}/$id"),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Delete failed with status: ${response.statusCode}');
    }
  }
}