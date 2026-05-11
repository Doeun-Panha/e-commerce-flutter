import 'package:ecommerce/features/categories/data/category_api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;

import '../../../core/models/category.dart';

class CategoryProvider with ChangeNotifier{
  final CategoryApiService _apiService = CategoryApiService();
  List<Category> _categories = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async{
    try{
      _categories = await _apiService.getCategories();
      notifyListeners();
    }catch (e){
      debugPrint("Error fetching categories: $e");
    }finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Category?> addCategory(String name) async{
    try{
      final newCategory = await _apiService.saveCategory(
        Category(id: 0, name: name),
        isUpdate: false
      );
      _categories.add(newCategory);
      notifyListeners();
      return newCategory;
    }catch (e) {
      debugPrint("Error adding category: $e");
      return null;
    }
  }

  Future<bool> updateCategory(int id, String newName) async {
    try {
      final updatedCategory = await _apiService.saveCategory(
        Category(id: id, name: newName),
        isUpdate: true
      );

      final index = _categories.indexWhere((cat)=>cat.id==id);
      if (index != -1) {
        _categories[index] = updatedCategory;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint("Error updating category: $e");
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      await _apiService.deleteCategory(id);
      _categories.removeWhere((cat)=>cat.id==id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error deleting category: $e");
      return false;
    }
  }
}