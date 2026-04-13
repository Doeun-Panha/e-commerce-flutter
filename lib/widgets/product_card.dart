import 'package:ecommerce/utils/validators.dart';
import 'package:flutter/material.dart';
import '../models/Product.dart';
import '../screens/product_form_screen.dart';

class ProductCard extends StatelessWidget{
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias, // Ensures the InkWell ripple matches card corners
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductFormScreen(product: product,)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              //1. Image with rounded corners
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  AppValidators.isRawUrlValid(product.imageUrl) ? product.imageUrl : 'https://via.placeholder.com/150',
                  width: 70, height: 70, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 70),
                ),
              ),

              const SizedBox(width: 16,),

              // 2. Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${product.price}',
                      style: const TextStyle(color: Colors.blueGrey),
                    ),
                    Text(
                      'Stock: ${product.stockQuantity}',
                      style: TextStyle(
                        color: product.stockQuantity < 5 ? Colors.red : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Navigation Hint
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}