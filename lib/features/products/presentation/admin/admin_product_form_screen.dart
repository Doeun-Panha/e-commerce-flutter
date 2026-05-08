import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ecommerce/features/products/data/Product.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../categories/data/Category.dart';
import '../../../categories/logic/category_provider.dart';
import '../../logic/product_provider.dart';

class AdminProductFormScreen extends StatefulWidget {
  final Product? product;

  const AdminProductFormScreen({super.key, this.product});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  //global key
  final _formKey = GlobalKey<FormState>();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Category? _selectedCategory;
  bool _isAddingNewCategory = false;

  //Text EditingController
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _stockQuantityController;
  late TextEditingController _lowStockThresholdController;
  
  bool _isLoading = false;
  bool get _isEditing => widget.product != null;

  //initState
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '',);
    _descriptionController = TextEditingController(text: widget.product?.description.toString() ?? '');
    _stockQuantityController = TextEditingController(text: widget.product?.stockQuantity.toString() ?? '');
    _lowStockThresholdController = TextEditingController(text: widget.product?.lowStockThreshold.toString() ?? '');

    _selectedCategory = widget.product?.category;

    // Fetch categories when screen opens
    Future.microtask(() =>
        Provider.of<CategoryProvider>(context, listen: false).fetchCategories()
    );
  }

  //dispose
  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _stockQuantityController.dispose();
    _lowStockThresholdController.dispose();
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
                  _buildImageSection(),
                  const SizedBox(height: 24),
                  _buildFormFields(),
                  const SizedBox(height: 24),
                  _buildCategorySelector(),
                  const SizedBox(height: 40),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildImageSection(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImagePreview(),
        const SizedBox(height: 8),
        const Text('Product Image', style: TextStyle(fontSize: 20, fontWeight:  FontWeight.bold)),
        const SizedBox(height: 8,),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _pickImage,
            icon: Icon(_selectedImage == null ? Icons.add_a_photo : Icons.refresh),
            label: Text(_selectedImage == null ? 'Select Product Image' : 'Change Image'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(AppTheme.borderRadius)),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: _selectedImage != null
          ? ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(AppTheme.borderRadius),
        child: Image.file(_selectedImage!, fit: BoxFit.cover,width: double.infinity,),
      )
          : (widget.product != null && widget.product!.imageUrl.isNotEmpty)
          ? ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Image.network(
          widget.product!.fullImageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            debugPrint("Image Load Error: $error");
            return _errorPlaceholder();
          },
        ),
      )
          : const Center(child: Icon(Icons.image_search, size: 50, color: Colors.grey,)),
    );
  }

  Future<void> _pickImage() async {
    try{
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 720,
        imageQuality: 85,
      );

      if(pickedFile!=null){
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    }catch(e){
      debugPrint("Error picking image: $e");
    }
  }
  //display errorplaceholder for image
  Widget _errorPlaceholder(){
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 50, color: Colors.grey,),
          Text('Invalid or No Image Link', style: TextStyle(color: Colors.grey),)
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        // 1. Name Field
        CustomTextField(
          controller: _nameController,
          label: 'Product Name',
          icon: Icons.shopping_bag_outlined,
          textInputAction: TextInputAction.next,
          validator: AppValidators.required(message: "Product name is required"),
        ),
        const SizedBox(height: 20),

        // 2. Price Field
        CustomTextField(
          controller: _priceController,
          label: 'Price',
          icon: Icons.attach_money,
          isNumber: true,
          textInputAction: TextInputAction.next,
          validator: AppValidators.combine([
            AppValidators.required(message: "Price is required"),
            AppValidators.number(),
            AppValidators.min(0.01, message: "Price must be greater than 0"),
          ]),
        ),
        const SizedBox(height: 20),

        // 3. Description Field
        CustomTextField(
          controller: _descriptionController,
          label: 'Description',
          icon: Icons.description_outlined,
          maxLines: 4, // More space for product details
          textInputAction: TextInputAction.newline,
          validator: AppValidators.required(message: "Please describe the product"),
        ),
        const SizedBox(height: 20),

        // 4. Stock Quantity Field
        CustomTextField(
          controller: _stockQuantityController,
          label: 'Initial Stock Quantity',
          icon: Icons.inventory_2_outlined,
          isNumber: true,
          textInputAction: TextInputAction.next,
          validator: AppValidators.combine([
            AppValidators.required(),
            AppValidators.number(),
            AppValidators.min(0, message: "Stock cannot be negative"),
          ]),
        ),
        const SizedBox(height: 20),

        // 5. Low Stock Threshold Field
        CustomTextField(
          controller: _lowStockThresholdController,
          label: 'Low Stock Alert Threshold',
          icon: Icons.notifications_active_outlined,
          isNumber: true,
          textInputAction: TextInputAction.done, // Last field in this section
          validator: AppValidators.combine([
            AppValidators.required(),
            AppValidators.number(),
            AppValidators.min(0, message: "Threshold must be at least 0"),
          ]),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Consumer<CategoryProvider>(
          builder: (context, provider, child) {
            // Check if selected category is still valid (in case one was deleted)
            final bool categoryExists = provider.categories.any((cat) => cat.id == _selectedCategory?.id);

            return DropdownButtonFormField<Category?>(
              value: categoryExists ? _selectedCategory : null,
              isExpanded: true,
              decoration: AppTheme.inputDecoration(
                  label: 'Select Category',
                  icon: Icons.category_outlined
              ),
              items: [
                ...provider.categories.map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat.name),
                )),
                const DropdownMenuItem<Category?>(
                  value: null, // Used to trigger the dialog
                  child: Text(
                    "+ Create New Category",
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              onChanged: (Category? value) {
                if (value == null) {
                  _showNewCategoryDialog();
                } else {
                  setState(() => _selectedCategory = value);
                }
              },
              validator: (value) => value == null && _selectedCategory == null
                  ? 'Please select a category'
                  : null,
            );
          },
        ),
      ],
    );
  }

  void _showNewCategoryDialog() {
    TextEditingController _categoryController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState){
            return AlertDialog(
                title: const Text("New Category"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: _categoryController,),
                    if(_isAddingNewCategory)
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: LinearProgressIndicator(),
                      )
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: _isAddingNewCategory ? null : () => Navigator.pop(context),
                      child: const Text("Cancel")
                  ),
                  ElevatedButton(
                      onPressed: _isAddingNewCategory ? null : () async{
                        final name = _categoryController.text.trim();
                        if (name.isEmpty) return;

                        setDialogState(() => _isAddingNewCategory = true);
                        try {
                          final provider = context.read<CategoryProvider>();
                          final newCat = await provider.addCategory(name);

                          if (newCat != null && context.mounted) {
                            setState(() => _selectedCategory = newCat);
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          debugPrint("Failed to create category: $e");
                          // Optionally show a secondary toast here
                        } finally {
                          if (context.mounted) setDialogState(() => _isAddingNewCategory = false);
                        }
                      },
                      child: const Text("Create")
                  ),
                ]
            );
          },
        )
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

  Future<void> _saveProduct() async {
    // 1. Validate Form
    if (!_formKey.currentState!.validate()) return;

    // 2. Image Check (Required for new products)
    if (!_isEditing && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 3. Prepare Data
    final productData = Product(
      id: widget.product?.id ?? 0,
      name: _nameController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 0.0,
      description: _descriptionController.text.trim(),
      imageUrl: widget.product?.imageUrl ?? '', // Path handled by API Service
      stockQuantity: int.tryParse(_stockQuantityController.text) ?? 0,
      lowStockThreshold: int.tryParse(_lowStockThresholdController.text) ?? 5,
      category: _selectedCategory,
    );

    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);

      if (_isEditing) {
        await productProvider.updateProduct(productData, _selectedImage);
      } else {
        await productProvider.addProduct(productData, _selectedImage);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product ${_isEditing ? 'updated' : 'added'}!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black26,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
