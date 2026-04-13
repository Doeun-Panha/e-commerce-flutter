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
  int get lowStockCount => _products.where((p) => p.stockQuantity<5).length;

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
  Future<void> addProduct(Product product) async {
    await _apiService.addProduct(product);
    await loadProducts();
  }

  //Update existing product
  Future<void> updateProduct(Product product) async {
    await _apiService.updateProduct(product);
    await loadProducts();
  }

  //Delete product
  Future<void> deleteProduct(int id) async{
    await _apiService.deleteProduct(id);
    _products.removeWhere((p)=>p.id==id);
    notifyListeners();
  }
}