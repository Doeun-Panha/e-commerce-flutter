import 'package:ecommerce/features/products/presentation/user/cart_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/Product.dart';
import '../../logic/cart_provider.dart';
import '../user/product_detail_screen.dart';

class UserProductCard extends StatelessWidget {
  final Product product;
  const UserProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              _buildInfoSection(context),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Sections ---

  Widget _buildImageSection() {
    return Expanded(
      child: Stack(
        children: [
          Hero(
            tag: 'product_image_${product.id}',
            child: Image.network(
              product.fullImageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[100],
                  child: const Center(child: CupertinoActivityIndicator()),
                );
              },
              errorBuilder: (context, _, __) => _imagePlaceholder(),
            ),
          ),
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "\$${product.price.toStringAsFixed(2)}",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 16
                ),
              ),
              _buildAddToCartButton(context),
            ],
          ),
        ],
      ),
    );
  }

  // --- UI Helpers ---

  Widget _buildStatusBadge() {
    final bool isOutOfStock = product.stockQuantity <= 0;
    final bool isLowStock = product.stockQuantity <= product.lowStockThreshold;

    if (!isLowStock && !isOutOfStock) return const SizedBox.shrink();

    return Positioned(
      top: 10,
      left: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isOutOfStock ? Colors.black.withOpacity(0.7) : Colors.orangeAccent.withOpacity(0.9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          isOutOfStock ? "OUT OF STOCK" : "LIMITED",
          style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900
          ),
        ),
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    final bool isOutOfStock = product.stockQuantity <= 0;

    return InkWell(
      onTap: isOutOfStock
          ? null // Disable interaction if no stock
          : () => _handleAddToCart(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isOutOfStock ? Colors.grey[300] : Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
            isOutOfStock ? Icons.block : Icons.add_shopping_cart,
            size: 18,
            color: isOutOfStock ? Colors.grey[600] : Colors.white
        ),
      ),
    );
  }

  void _handleAddToCart(BuildContext context) {
    context.read<CartProvider>().addItem(product);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${product.name} added to cart!"),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: "VIEW",
          textColor: Colors.purpleAccent,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context)=> const CartScreen()),
            );
          },
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      width: double.infinity,
      child: const Icon(Icons.fitness_center, color: Colors.grey, size: 40),
    );
  }
}