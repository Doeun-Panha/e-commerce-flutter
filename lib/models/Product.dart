class Product {
  final int id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final int stockQuantity;
  final int lowStockThreshold;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    this.imageUrl='',
    required this.stockQuantity,
    required this.lowStockThreshold,
  });

  factory Product.fromJson(Map<String, dynamic> json){
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 5
    );
  }

  Map<String, dynamic> toJson()=>{
    'name': name,
    'price': price,
    'description': description,
    'imageUrl': imageUrl,
    'stockQuantity': stockQuantity,
    'lowStockThreshold': lowStockThreshold,
  };

  Map<String, String> toMultipartFields(){
    return{
      'name': name,
      'price': price.toString(),
      'description': description,
      'stockQuantity': stockQuantity.toString(),
      'lowStockThreshold': lowStockThreshold.toString(),
    };
  }
}