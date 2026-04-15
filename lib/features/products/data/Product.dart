import 'package:flutter/foundation.dart' hide Category;
import '../../../core/constants/api_constants.dart';
import '../../categories/data/Category.dart';

class Product {
  final int id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final int stockQuantity;
  final int lowStockThreshold;

  final Category? category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    this.imageUrl='',
    required this.stockQuantity,
    required this.lowStockThreshold,

    this.category,
  });

  Product copyWith({
    int? id,
    String? name,
    double? price,
    String? description,
    String? imageUrl,
    int? stockQuantity,
    int? lowStockThreshold,
    Category? category,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      category: category ?? this.category,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json){
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 5,

      category: json['category'] != null ? Category.fromJson(json['category']) : null,
    );
  }

  Map<String, dynamic> toJson()=>{
    'name': name,
    'price': price,
    'description': description,
    'imageUrl': imageUrl,
    'stockQuantity': stockQuantity,
    'lowStockThreshold': lowStockThreshold,
    'category': category?.toJson(),
  };

  Map<String, String> toMultipartFields(){
    return{
      'name': name,
      'price': price.toString(),
      'description': description,
      'stockQuantity': stockQuantity.toString(),
      'lowStockThreshold': lowStockThreshold.toString(),
      'categoryId': category?.id.toString() ?? "",
    };
  }

  String get fullImageUrl {
    if (imageUrl.startsWith('http')) return imageUrl;
    final String cleanPath = imageUrl.startsWith('/') ? imageUrl : '/$imageUrl';
    return "${ApiConstants.uploadBase}$cleanPath";
  }
}