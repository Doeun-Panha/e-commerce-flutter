import 'dart:io';

import 'package:flutter/material.dart';
import '../models/Product.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier{
  final ApiService _apiService = ApiService();
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  int get totalItems => _products.length;
  int get lowStockCount => _products.where((p) => p.stockQuantity<p.lowStockThreshold).length;

  //Fetch all products
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    try{
      _products=await _apiService.getProducts();
    }catch(e){
      rethrow;
    }finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  //Add a new product
  Future<void> addProduct(Product product, File? imageFile) async {
    await _apiService.addProduct(product, imageFile);
    await loadProducts();
  }

  //Update existing product
  Future<void> updateProduct(Product product, File? imageFile) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 1. Send data to Spring Boot
      final updatedProduct = await _apiService.updateProduct(product, imageFile);

      // 2. Local Update: Find and replace the specific product
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updatedProduct; // Update only the specific item
        notifyListeners();
      }
      await loadProducts(); // Refresh list to see the new server path
    } catch (e) {
      debugPrint("Update failed: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //Delete product
  Future<void> deleteProduct(int id) async{
    await _apiService.deleteProduct(id);
    _products.removeWhere((p)=>p.id==id);
    notifyListeners();
  }

  // Add this to your ProductProvider
  List<Product> getProductsByCategory(int categoryId) {
    return _products.where((p) => p.category?.id == categoryId).toList();
  }

  void syncProductsAfterCategoryDeletion(int categoryId) {
    bool changed = false;
    for (int i = 0; i < _products.length; i++) {
      if (_products[i].category?.id == categoryId) {
        // Set to 'None' or 'Uncategorized' locally
        _products[i] = _products[i].copyWith(category: null);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }
}