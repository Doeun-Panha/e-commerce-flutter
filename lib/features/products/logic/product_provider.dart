import 'dart:io';

import 'package:flutter/material.dart';
import '../../auth/logic/auth_provider.dart';
import '../../../core/models/product.dart';
import '../data/product_api_service.dart';

class ProductProvider with ChangeNotifier{
  final ProductApiService _apiService = ProductApiService();
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  int get totalItems => _products.length;
  int get lowStockCount => _products.where((p) => p.stockQuantity<=p.lowStockThreshold).length;

  String _selectedFilter = 'All';
  String get selectedFilter => _selectedFilter;

  AuthProvider? _authProvider;

  void updateAuth(AuthProvider auth) {
    _authProvider = auth;
  }

  //Fetch all products
  Future<void> fetchProducts(AuthProvider authProvider) async {
    _isLoading = true;
    notifyListeners();
    try{
      _products=await _apiService.getProducts();
    }catch(e){
      debugPrint("Load Products Error: $e");
      if (e.toString().contains('403')) {
        // If the token is dead, force a logout to reset the app state
        await _authProvider?.logout();
      }
    }finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  //Add a new product
  Future<void> addProduct(Product product, File? imageFile) async {
    try {
      final newProduct = await _apiService.saveProduct(product, imageFile, isUpdate: false);
      _products.add(newProduct); // Add the actual object returned by the server
      notifyListeners();
    } catch (e) {
      debugPrint("Add Product Error: $e");
      rethrow;
    }
  }

  //Update existing product
  Future<void> updateProduct(Product product, File? imageFile) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 1. Send data to Spring Boot
      final updatedProduct = await _apiService.saveProduct(product, imageFile, isUpdate: true);

      // 2. Local Update: Find and replace the specific product
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updatedProduct; // Update only the specific item
        notifyListeners();
      }
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
    try {
      await _apiService.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint("Delete Product Error: $e");
      rethrow;
    }
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

  void setFilter(String filter){
    _selectedFilter = filter;
    notifyListeners();
  }

  List<Product> get filteredProducts {
    List<Product> list = [..._products];

    // 1. Handle Sorting (A-Z, Price, Low Stock)
    if (_selectedFilter == 'A-Z') {
      list.sort((a, b) => a.name.compareTo(b.name));
    } else if (_selectedFilter == 'Price') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (_selectedFilter == 'Low Stock') {
      list = list.where((p) => p.stockQuantity <= p.lowStockThreshold).toList();
    }

    // 2. Handle Category Filtering
    final specialFilters = ['All', 'A-Z', 'Price', 'Low Stock'];
    if (!specialFilters.contains(_selectedFilter)) {
      list = list.where((p) => p.category?.name == _selectedFilter).toList();
    }

    return list;
  }
}