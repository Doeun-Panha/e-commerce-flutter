import 'package:flutter/material.dart';
import '../../features/products/data/Product.dart';
import '../../features/products/presentation/product_form_screen.dart';

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
              _buildProductImage(),
              const SizedBox(width: 16,),
              _buildProductInfo(context),
              const Icon(Icons.chevron_right, color: Colors.grey,)
            ],
          ),
        ),
      ),
    );
  }

  // 1. Separate the Image Logic
  Widget _buildProductImage(){
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        product.fullImageUrl,
        fit: BoxFit.cover,
        width: 70,
        height: 70,
        errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image, color: Colors.red, size: 30,),
      ),
    );
  }

  // 2. Separate the Text/Details Logic
  Widget _buildProductInfo(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          _buildStockStatus(),
        ],
      ),
    );
  }

  // 3. Keep the specialized status badge
  Widget _buildStockStatus() {
    final bool isLowStock = product.stockQuantity <= product.lowStockThreshold;
    final colorScheme = isLowStock ? Colors.red : Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme[50],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Stock: ${product.stockQuantity}',
        style: TextStyle(
          color: colorScheme[700],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}