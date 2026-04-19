import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/Product.dart';

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
            // TODO: Navigate to ProductDetailScreen(product: product)
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

  // --- Sub-widgets ---

  Widget _buildImageSection() {
    return Expanded(
      child: Stack(
        children: [
          Image.network(
            product.fullImageUrl, // Use full URL helper from your model
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
          if (product.stockQuantity <= product.lowStockThreshold)
            _buildLowStockBadge(),
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
              _buildAddToCartButton(),
            ],
          ),
        ],
      ),
    );
  }

  // --- UI Helpers ---

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

  Widget _buildLowStockBadge() {
    return Positioned(
      top: 10,
      left: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orangeAccent.withOpacity(0.9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          "LIMITED",
          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.add_shopping_cart, size: 18, color: Colors.white),
    );
  }
}