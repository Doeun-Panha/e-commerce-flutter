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
      await _apiService.updateProduct(product, imageFile);
      await loadProducts(); // Refresh list to see the new server path
    } catch (e) {
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
}