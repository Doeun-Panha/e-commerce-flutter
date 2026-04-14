import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ecommerce/models/Product.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/Category.dart';
import '../providers/category_provider.dart';
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

                  //image preview
                  _buildImagePreview(),
                  const Text('Product Image', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                  const SizedBox(height: 8,),

                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(_selectedImage == null ? Icons.add_a_photo : Icons.refresh),
                    label: Text(_selectedImage == null ? 'Select Product Image' : 'Change Image'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(AppTheme.borderRadius))
                    )
                  ),
                  const SizedBox(height: 20,),

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
                    controller: _stockQuantityController,
                    label: 'Stock Quantity',
                    icon: Icons.inventory_2_outlined,
                    isNumber: true,
                    validator: AppValidators.number,
                  ),
                  const SizedBox(height: 20),

                  ProductInputField(
                    controller: _lowStockThresholdController, // You'll need to create this controller
                    label: 'Low Stock Alert At',
                    icon: Icons.notifications_active_outlined,
                    isNumber: true,
                    validator: AppValidators.number,
                  ),
                  const SizedBox(height: 20),

                  const Text('Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  Consumer<CategoryProvider>(
                    builder: (context, provider, child) {
                      // Check if the current _selectedCategory actually exists in the provider's list
                      final bool categoryExists = provider.categories.any((cat) => cat.id == _selectedCategory?.id);

                      return DropdownButtonFormField<Category?>(
                        // Force value to null if the category is no longer in the list
                        value: categoryExists ? _selectedCategory : null,
                        isExpanded: true,
                        decoration: AppTheme.inputDecoration(label: 'Select Category', icon: Icons.category_outlined),
                        items: [
                          ...provider.categories.map((cat) => DropdownMenuItem(
                            value: cat, // Pass the whole object
                            child: Text(cat.name),
                          )),
                          const DropdownMenuItem<Category?>(
                            value: null, // We use null to signal a new creation
                            child: Text(
                              "+ Create New Category",
                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        onChanged: (Category? value) {
                          if (value == null) {
                            // 3. If they clicked the "+ Create New" item, open the dialog
                            _showNewCategoryDialog();
                          } else {
                            // Otherwise, just update the selection normally
                            setState(() => _selectedCategory = value);
                          }
                        },
                        hint: provider.categories.isEmpty
                            ? const Text("No categories available")
                            : const Text("Select Category"),
                      );
                    },
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

    if (!_isEditing && _selectedImage == null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product image'),),
      );
      return;
    }

    setState(() => _isLoading = true);

    //Get the provider without "listening" (since we are in a function, not the build method)
    final productProvider=Provider.of<ProductProvider>(context, listen: false);

    final price = double.tryParse(_priceController.text) ?? 0.0;
    final stock = int.tryParse(_stockQuantityController.text) ?? 0;
    final threshold = int.tryParse(_lowStockThresholdController.text) ?? 5;

    final productData = Product(
      id: widget.product?.id ?? 0,
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text),
      description: _descriptionController.text.trim(),
      imageUrl: widget.product?.imageUrl ?? '',
      stockQuantity: int.parse(_stockQuantityController.text),
      lowStockThreshold: int.parse(_lowStockThresholdController.text),
      category: _selectedCategory,
    );

    try {
      if (_isEditing) {
        //Use provider instead of api Service
        await productProvider.updateProduct(productData, _selectedImage);
      } else {
        //Use provider instead of api Service
        await productProvider.addProduct(productData, _selectedImage);
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
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: _selectedImage != null
        ? ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(AppTheme.borderRadius),
          child: Image.file(_selectedImage!, fit: BoxFit.cover,),
          )
        : (widget.product?.imageUrl != null && widget.product!.imageUrl.isNotEmpty)
          ? ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(AppTheme.borderRadius),
            child: Image.network(
              widget.product!.imageUrl.startsWith('http')
                ? widget.product!.imageUrl
                : 'http://10.0.2.2:8080${widget.product!.imageUrl}',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _errorPlaceholder(),
            ),
          )
          : const Center(child: Icon(Icons.image_search, size: 50, color: Colors.grey,)),
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

  //
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
                  setDialogState(()=>_isAddingNewCategory=true);

                  final provider = context.read<CategoryProvider>();

                  final newCat = await provider.addCategory(_categoryController.text.trim());

                  setDialogState(() => _isAddingNewCategory = false); // Stop Loading

                  if (newCat != null) {
                    setState(() => _selectedCategory = newCat);
                    if (context.mounted) Navigator.pop(context);
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

}
