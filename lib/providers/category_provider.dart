import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:http/http.dart' as http;

import '../models/Category.dart';

class CategoryProvider with ChangeNotifier{
  List<Category> _categories = [];
  List<Category> get categories => _categories;

  final String baseUrl = 'http://10.0.2.2:8080/api/categories';

  Future<void> fetchCategories() async{
    try{
      final response = await http.get(Uri.parse(baseUrl));
      if(response.statusCode==200){
        final List<dynamic> data = json.decode(response.body);
        _categories = data.map((item) => Category.fromJson(item)).toList();
        notifyListeners();
      }
    }catch (e){
      debugPrint("Error fetching categories: $e");
    }
  }

  Future<Category?> addCategory(String name) async{
    try{
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name}),
      );
      if (response.statusCode == 200) {
        final newCategory = Category.fromJson(json.decode(response.body));
        _categories.add(newCategory);
        notifyListeners();
        return newCategory;
      }
    }catch (e) {
      debugPrint("Error adding category: $e");
    }
    return null;
  }

  Future<bool> updateCategory(int id, String newName) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': newName}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Find the category in our local list and update its name
        final index = _categories.indexWhere((cat) => cat.id == id);
        if (index != -1) {
          _categories[index] = Category(id: id, name: newName);
          notifyListeners(); // Refresh the dropdown list immediately
        }
        return true; // Operation successful
      }else{
        debugPrint("Server error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("Error updating category: $e");
    }
    return false; // Operation failed
  }

  Future<bool> deleteCategory(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200 || response.statusCode == 204) {
        _categories.removeWhere((cat) => cat.id == id);
        notifyListeners();
        return true;
      }else {
        debugPrint("❌ Server Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("Error deleting category: $e");
    }
    return false;
  }
}