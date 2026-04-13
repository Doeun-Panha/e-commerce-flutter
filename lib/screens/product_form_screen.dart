import 'package:flutter/material.dart';
import 'package:ecommerce/models/Product.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../utils/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/product_input_field.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  //global key
  final _formKey = GlobalKey<FormState>();

  //Text EditingController
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageController;
  late TextEditingController _stockQuantityController;
  
  bool _isLoading = false;
  bool get _isEditing => widget.product != null;

  //initState
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '',);
    _descriptionController = TextEditingController(text: widget.product?.description.toString() ?? '');
    _imageController = TextEditingController(text: widget.product?.imageUrl ?? '');
    _imageController.addListener((){if(mounted) setState(() {});});
    _stockQuantityController = TextEditingController(text: widget.product?.stockQuantity.toString() ?? '');
  }

  //dispose
  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _stockQuantityController.dispose();
    super.dispose();
  }
  
  //build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      //appBar
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add Product', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0,
      ),
      
      //body
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  //image preview
                  _buildImagePreview(),

                  //text fields
                  const Text('Product Details',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),

                  ProductInputField(
                    controller: _nameController,
                    label: 'Product Name',
                    icon: Icons.shopping_bag_outlined,
                    validator: AppValidators.required,
                  ),
                  const SizedBox(height: 20),

                  ProductInputField(
                    controller: _priceController,
                    label: 'Price',
                    icon: Icons.attach_money,
                    isNumber: true,
                    validator: AppValidators.number,
                  ),
                  const SizedBox(height: 20),

                  ProductInputField(
                    controller: _descriptionController,
                    label: 'Description',
                    icon: Icons.description,
                    maxLines: 5,
                    validator: AppValidators.required,
                  ),
                  const SizedBox(height: 20),

                  ProductInputField(
                    controller: _imageController,
                    label: 'Image URL',
                    icon: Icons.image,
                    hint: 'https://image-link.com',
                    validator: AppValidators.url,
                  ),
                  const SizedBox(height: 20),

                  ProductInputField(
                    controller: _stockQuantityController,
                    label: 'Stock Quantity',
                    icon: Icons.inventory_2_outlined,
                    isNumber: true,
                    validator: AppValidators.number,
                  ),
                  const SizedBox(height: 40),

                  //if _isEditing=true then show a row of 2 button (Update & Delete)
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
  
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    //Get the provider without "listening" (since we are in a function, not the build method)
    final productProvider=Provider.of<ProductProvider>(context, listen: false);

    final productData = Product(
      id: widget.product?.id ?? 0,
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text),
      description: _descriptionController.text.trim(),
      imageUrl: _imageController.text.trim(),
      stockQuantity: int.parse(_stockQuantityController.text),
    );

    try {
      if (_isEditing) {
        //Use provider instead of api Service
        await productProvider.updateProduct(productData);
      } else {
        //Use provider instead of api Service
        await productProvider.addProduct(productData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product ${_isEditing ? 'updated' : 'added'} successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving product: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && uri.hasAbsolutePath && (uri.isScheme('http') || uri.isScheme('https'));
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Product?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final productProvider = Provider.of<ProductProvider>(context, listen: false);
        await productProvider.deleteProduct(widget.product!.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product deleted')));
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting: $e')));
        }
      }
    }
  }

  Widget _buildImagePreview() {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),

        //Check and try to use the image, if not unable to do so, will display an errorplaceholder instead
        child: _imageController.text.isNotEmpty && _isValidUrl(_imageController.text) ? Image.network(
          _imageController.text,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _errorPlaceholder(),
        )
        : _errorPlaceholder(),
      ),
    );
  }

  //display errorplaceholder for image
  Widget _errorPlaceholder(){
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.broken_image, size: 50, color: Colors.grey,),
        Text('Invalid or No Image Link', style: TextStyle(color: Colors.grey),)
      ],
    );
  }

  Widget _buildActionButtons(){
    if(_isEditing){
      return Row(
        children: [

          //Update
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveProduct,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
              ),
              child: const Text('Update'),
            ),
          ),

          const SizedBox(width: 16,),

          //Delete
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _confirmDelete,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
              ),
            ),
          ),
        ],
      );
    }

    //if not _isEditing then show only a save product button
    return ElevatedButton(
      onPressed: _isLoading ? null : _saveProduct,
      style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius))
      ),
      child: const Text('Save Product'),
    );
  }
}
