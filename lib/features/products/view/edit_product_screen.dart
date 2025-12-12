import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jusel_app/core/database/app_database.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/services/image_upload_service.dart';
import 'package:jusel_app/core/services/permission_service.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/core/utils/product_constants.dart';
import 'package:jusel_app/features/products/providers/products_provider.dart';

final productProvider = FutureProvider.autoDispose
    .family<ProductsTableData?, String>((ref, productId) async {
      final db = ref.read(appDatabaseProvider);
      return db.productsDao.getProduct(productId);
    });

class EditProductScreen extends ConsumerStatefulWidget {
  final String productId;

  const EditProductScreen({super.key, required this.productId});

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  // Form controllers
  late final TextEditingController _nameController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _unitsPerPackController;
  late final TextEditingController _reasonController;

  // Form state
  String? _selectedCategory;
  String? _selectedSubcategory;
  File? _selectedImage;
  String? _imageUrl;
  String? _selectedStatus;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  final ImagePicker _imagePicker = ImagePicker();
  final ImageUploadService _imageUploadService = ImageUploadService();

  // Category options
  late final List<String> _categoryDisplayNames;
  late final Map<String, List<String>> _subcategoryDisplayNames;

  ProductsTableData? _originalProduct;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _sellingPriceController = TextEditingController();
    _costPriceController = TextEditingController();
    _unitsPerPackController = TextEditingController();
    _reasonController = TextEditingController();

    // Initialize category display names
    _categoryDisplayNames = ProductCategories.all
        .map((cat) => ProductHelpers.categoryToDisplay(cat))
        .toList();

    // Initialize subcategory display names by category
    _subcategoryDisplayNames = {};
    for (final category in ProductCategories.all) {
      final subcats = ProductCategories.subcategories[category] ?? [];
      _subcategoryDisplayNames[ProductHelpers.categoryToDisplay(
        category,
      )] = subcats
          .map((sub) => ProductHelpers.subcategoryToDisplay(sub))
          .toList();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sellingPriceController.dispose();
    _costPriceController.dispose();
    _unitsPerPackController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _loadProductData(ProductsTableData product) {
    if (_originalProduct != null) return; // Already loaded

    setState(() {
      _originalProduct = product;
      _nameController.text = product.name;
      _sellingPriceController.text = product.currentSellingPrice
          .toStringAsFixed(2);
      _costPriceController.text =
          product.currentCostPrice?.toStringAsFixed(2) ?? '';
      _unitsPerPackController.text = product.unitsPerPack?.toString() ?? '';
      _imageUrl = product.imageUrl;
      _selectedStatus = product.status;

      // Set category and subcategory
      _selectedCategory = ProductHelpers.categoryToDisplay(product.category);
      if (product.subcategory != null) {
        _selectedSubcategory = ProductHelpers.subcategoryToDisplay(
          product.subcategory!,
        );
      }
    });
  }

  Future<void> _showImageSourceSheet() async {
    if (_isSaving || _isUploadingImage) return;

    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_imageUrl != null || _selectedImage != null)
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: JuselColors.destructiveColor(context),
                ),
                title: Text(
                  'Remove Image',
                  style: TextStyle(color: JuselColors.destructiveColor(context)),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedImage = null;
                    _imageUrl = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Request permission first
      final permissionService = ref.read(permissionServiceProvider);
      final hasPermission = await permissionService.requestImagePermission(
        context,
        source,
      );

      if (!hasPermission) {
        return; // Permission denied, user was already notified
      }

      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _imageUrl = null; // Clear old URL when new image is selected
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: JuselColors.destructiveColor(context),
          ),
        );
      }
    }
  }

  bool get _isValid {
    return _nameController.text.trim().isNotEmpty &&
        _sellingPriceController.text.trim().isNotEmpty &&
        _selectedCategory != null &&
        _selectedStatus != null;
  }

  Future<void> _saveProduct() async {
    if (!_isValid || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('You must be logged in to edit products');
      }

      final db = ref.read(appDatabaseProvider);
      final syncDao = ref.read(pendingSyncQueueDaoProvider);

      // Upload image if new one is selected
      String? finalImageUrl = _imageUrl;
      if (_selectedImage != null) {
        finalImageUrl = await _imageUploadService.uploadProductImage(
          file: _selectedImage!,
          productId: widget.productId,
        );
        setState(() {
          _imageUrl = finalImageUrl;
          _selectedImage = null;
        });
      }

      // Get original product for comparison
      final original = _originalProduct;
      if (original == null) {
        throw Exception('Product data not loaded');
      }

      // Parse form values
      final name = _nameController.text.trim();
      final sellingPrice = double.tryParse(_sellingPriceController.text.trim());
      final costPrice = _costPriceController.text.trim().isEmpty
          ? null
          : double.tryParse(_costPriceController.text.trim());

      if (sellingPrice == null || sellingPrice <= 0) {
        throw Exception('Selling price must be greater than 0');
      }

      if (costPrice != null && costPrice <= 0) {
        throw Exception('Cost price must be greater than 0');
      }

      // Convert display names to canonical
      final canonicalCategory =
          ProductHelpers.categoryFromDisplay(_selectedCategory!) ??
          original.category;
      final canonicalSubcategory = _selectedSubcategory != null
          ? ProductHelpers.subcategoryFromDisplay(_selectedSubcategory!)
          : original.subcategory;

      // Determine what changed
      final nameChanged = name != original.name;
      final categoryChanged =
          canonicalCategory != original.category ||
          canonicalSubcategory != original.subcategory;
      final sellingPriceChanged = sellingPrice != original.currentSellingPrice;
      final costPriceChanged = costPrice != original.currentCostPrice;
      final statusChanged = _selectedStatus != original.status;
      final imageChanged = finalImageUrl != original.imageUrl;

      // Update product
      await db.productsDao.updateProduct(
        id: widget.productId,
        name: nameChanged ? name : null,
        category: categoryChanged ? canonicalCategory : null,
        subcategory: categoryChanged ? canonicalSubcategory : null,
        newSellingPrice: sellingPriceChanged ? sellingPrice : null,
        newCostPrice: costPriceChanged ? costPrice : null,
        status: statusChanged ? _selectedStatus : null,
        imageUrl: imageChanged ? finalImageUrl : null,
      );

      // Note: unitsPerPack is not updated via updateProduct method
      // It's typically set during product creation and doesn't change

      // Log price changes to history
      if (sellingPriceChanged || costPriceChanged) {
        final historyId = DateTime.now().millisecondsSinceEpoch.toString();
        String changeType;
        if (sellingPriceChanged && costPriceChanged) {
          changeType = 'both';
        } else if (sellingPriceChanged) {
          changeType = 'selling_price';
        } else {
          changeType = 'cost_price';
        }

        await db.productPriceHistoryDao.logPriceChange(
          ProductPriceHistoryTableCompanion.insert(
            id: historyId,
            productId: widget.productId,
            oldSellingPrice: Value(original.currentSellingPrice),
            newSellingPrice: sellingPriceChanged
                ? Value(sellingPrice)
                : Value(original.currentSellingPrice),
            oldCostPrice: Value(original.currentCostPrice),
            newCostPrice: costPriceChanged
                ? (costPrice != null ? Value(costPrice) : const Value.absent())
                : Value(original.currentCostPrice),
            changeType: changeType,
            reason: Value(
              _reasonController.text.trim().isEmpty
                  ? 'product_edit'
                  : _reasonController.text.trim(),
            ),
            createdAt: DateTime.now(),
          ),
        );
      }

      // Queue for sync
      final syncPayload = <String, dynamic>{
        'id': widget.productId,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (nameChanged) syncPayload['name'] = name;
      if (categoryChanged) {
        syncPayload['category'] = canonicalCategory;
        if (canonicalSubcategory != null) {
          syncPayload['subcategory'] = canonicalSubcategory;
        }
      }
      if (sellingPriceChanged)
        syncPayload['currentSellingPrice'] = sellingPrice;
      if (costPriceChanged && costPrice != null)
        syncPayload['currentCostPrice'] = costPrice;
      if (statusChanged) syncPayload['status'] = _selectedStatus;
      if (imageChanged && finalImageUrl != null)
        syncPayload['imageUrl'] = finalImageUrl;

      await syncDao.enqueueOperation(
        id: 'product_update_${widget.productId}_${DateTime.now().millisecondsSinceEpoch}',
        operationType: 'product_update',
        payload: jsonEncode(syncPayload),
      );

      if (mounted) {
        // Trigger refresh in products list
        ref.read(productsRefreshTriggerProvider.notifier).refresh();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Product updated successfully!'),
            backgroundColor: JuselColors.successColor(context),
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update product: $e'),
            backgroundColor: JuselColors.destructiveColor(context),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productProvider(widget.productId));

    return Scaffold(
      backgroundColor: JuselColors.background(context),
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Product',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(JuselSpacing.s16),
            child: Text(
              'Failed to load product: $e',
              style: JuselTextStyles.bodyMedium(context).copyWith(
                color: JuselColors.destructiveColor(context),
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (product) {
          if (product == null) {
            return Center(
              child: Text(
                'Product not found',
                style: JuselTextStyles.bodyMedium(context).copyWith(
                  color: JuselColors.mutedForeground(context),
                ),
              ),
            );
          }

          // Load product data once
          if (_originalProduct == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadProductData(product);
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(JuselSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Center(
                  child: GestureDetector(
                    onTap: _showImageSourceSheet,
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: JuselColors.muted(context),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: JuselColors.border(context)),
                          ),
                          child: _isUploadingImage
                              ? const Center(child: CircularProgressIndicator())
                              : (_selectedImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.file(
                                          _selectedImage!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : (_imageUrl != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Image.network(
                                                _imageUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Icon(
                                                      Icons.image_outlined,
                                                      size: 48,
                                                      color: JuselColors
                                                          .mutedForeground(context),
                                                    ),
                                              ),
                                            )
                                          : Icon(
                                              Icons
                                                  .add_photo_alternate_outlined,
                                              size: 48,
                                              color:
                                                  JuselColors.mutedForeground(context),
                                            ))),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: JuselColors.primaryColor(context),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: JuselColors.primaryForeground,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: JuselSpacing.s24),

                // Product Name
                _FormField(
                  label: 'Product Name',
                  controller: _nameController,
                  hint: 'Enter product name',
                ),
                const SizedBox(height: JuselSpacing.s16),

                // Category
                _FormField(
                  label: 'Category',
                  value: _selectedCategory,
                  onTap: () => _showCategoryPicker(),
                  hint: 'Select category',
                ),
                const SizedBox(height: JuselSpacing.s16),

                // Subcategory (if applicable)
                if (_selectedCategory != null &&
                    _subcategoryDisplayNames[_selectedCategory]?.isNotEmpty ==
                        true)
                  _FormField(
                    label: 'Subcategory',
                    value: _selectedSubcategory,
                    onTap: () => _showSubcategoryPicker(),
                    hint: 'Select subcategory',
                  ),
                if (_selectedCategory != null &&
                    _subcategoryDisplayNames[_selectedCategory]?.isNotEmpty ==
                        true)
                  const SizedBox(height: JuselSpacing.s16),

                // Selling Price
                _FormField(
                  label: 'Selling Price (GHS)',
                  controller: _sellingPriceController,
                  hint: '0.00',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: JuselSpacing.s16),

                // Cost Price (optional)
                _FormField(
                  label: 'Cost Price (GHS) - Optional',
                  controller: _costPriceController,
                  hint: '0.00',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: JuselSpacing.s16),

                // Units Per Pack (if applicable)
                if (product.category == ProductCategories.drink ||
                    product.category == ProductCategories.water)
                  _FormField(
                    label: 'Units Per Pack',
                    controller: _unitsPerPackController,
                    hint: 'e.g., 24',
                    keyboardType: TextInputType.number,
                  ),
                if (product.category == ProductCategories.drink ||
                    product.category == ProductCategories.water)
                  const SizedBox(height: JuselSpacing.s16),

                // Status
                _FormField(
                  label: 'Status',
                  value: _selectedStatus,
                  onTap: () => _showStatusPicker(),
                  hint: 'Select status',
                ),
                const SizedBox(height: JuselSpacing.s16),

                // Reason for price change (if price changed)
                _FormField(
                  label: 'Reason for Changes (Optional)',
                  controller: _reasonController,
                  hint: 'e.g., Price adjustment, supplier change',
                  maxLines: 2,
                ),
                const SizedBox(height: JuselSpacing.s24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isValid && !_isSaving ? _saveProduct : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: JuselColors.primaryColor(context),
                      foregroundColor: JuselColors.primaryForeground,
                      padding: const EdgeInsets.symmetric(
                        vertical: JuselSpacing.s16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: JuselColors.primaryForeground,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showCategoryPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(JuselSpacing.s16),
              child: Text(
                'Select Category',
                style: JuselTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ..._categoryDisplayNames.map(
              (cat) => ListTile(
                title: Text(cat),
                trailing: _selectedCategory == cat
                    ? Icon(Icons.check, color: JuselColors.primaryColor(context))
                    : null,
                onTap: () {
                  Navigator.of(context).pop(cat);
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedCategory = selected;
        // Reset subcategory when category changes
        final subcats = _subcategoryDisplayNames[selected];
        _selectedSubcategory = subcats?.isNotEmpty == true ? subcats![0] : null;
      });
    }
  }

  Future<void> _showSubcategoryPicker() async {
    if (_selectedCategory == null) return;

    final subcats = _subcategoryDisplayNames[_selectedCategory!];
    if (subcats == null || subcats.isEmpty) return;

    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(JuselSpacing.s16),
              child: Text(
                'Select Subcategory',
                style: JuselTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ...subcats.map(
              (sub) => ListTile(
                title: Text(sub),
                trailing: _selectedSubcategory == sub
                    ? Icon(Icons.check, color: JuselColors.primaryColor(context))
                    : null,
                onTap: () {
                  Navigator.of(context).pop(sub);
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedSubcategory = selected;
      });
    }
  }

  Future<void> _showStatusPicker() async {
    final statuses = ['active', 'inactive', 'sold_out'];
    final statusLabels = {
      'active': 'Active',
      'inactive': 'Inactive',
      'sold_out': 'Sold Out',
    };

    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(JuselSpacing.s16),
              child: Text(
                'Select Status',
                style: JuselTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ...statuses.map(
              (status) => ListTile(
                title: Text(statusLabels[status] ?? status),
                trailing: _selectedStatus == status
                    ? Icon(Icons.check, color: JuselColors.primaryColor(context))
                    : null,
                onTap: () {
                  Navigator.of(context).pop(status);
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedStatus = selected;
      });
    }
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? value;
  final VoidCallback? onTap;
  final String hint;
  final TextInputType? keyboardType;
  final int? maxLines;

  const _FormField({
    required this.label,
    this.controller,
    this.value,
    this.onTap,
    required this.hint,
    this.keyboardType,
    this.maxLines,
  }) : assert(
         controller != null || onTap != null,
         'Either controller or onTap must be provided',
       );

  @override
  Widget build(BuildContext context) {
    if (controller != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: JuselTextStyles.bodySmall(context).copyWith(
              fontWeight: FontWeight.w700,
              color: JuselColors.mutedForeground(context),
            ),
          ),
          const SizedBox(height: JuselSpacing.s6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: JuselColors.muted(context),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: JuselSpacing.s12,
                vertical: JuselSpacing.s12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: JuselColors.border(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: JuselColors.border(context)),
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: JuselTextStyles.bodySmall(context).copyWith(
              fontWeight: FontWeight.w700,
              color: JuselColors.mutedForeground(context),
            ),
          ),
          const SizedBox(height: JuselSpacing.s6),
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: JuselSpacing.s12,
                vertical: JuselSpacing.s12,
              ),
              decoration: BoxDecoration(
                color: JuselColors.card(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: JuselColors.border(context)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value ?? hint,
                      style: JuselTextStyles.bodyMedium(context).copyWith(
                        color: value != null
                            ? JuselColors.foreground(context)
                            : JuselColors.mutedForeground(context),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: JuselColors.mutedForeground(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }
}
