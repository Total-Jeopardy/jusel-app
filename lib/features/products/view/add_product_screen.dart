import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/core/utils/product_constants.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
import 'package:jusel_app/core/services/image_upload_service.dart';
import 'package:jusel_app/core/services/permission_service.dart';
import 'package:jusel_app/features/auth/viewmodel/auth_viewmodel.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  // Form controllers
  final _nameController = TextEditingController();
  final _unitsPerPackController = TextEditingController();
  final _sellingPriceController = TextEditingController();

  // Form state
  late String _selectedCategory;
  String? _selectedSubcategory;
  File? _selectedImage;
  String? _imageUrl;
  String? _selectedSize;
  bool _isActive = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  final ImagePicker _imagePicker = ImagePicker();
  final ImageUploadService _imageUploadService = ImageUploadService();

  // Category options (using display names for UI)
  late final List<String> _categoryDisplayNames;
  late final Map<String, List<String>> _subcategoryDisplayNames;

  @override
  void initState() {
    super.initState();
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

    // Set default category
    _selectedCategory = _categoryDisplayNames.first;
    final defaultSubcats = _subcategoryDisplayNames[_selectedCategory];
    _selectedSubcategory = defaultSubcats?.isNotEmpty == true
        ? defaultSubcats![0]
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitsPerPackController.dispose();
    _sellingPriceController.dispose();
    super.dispose();
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
            if (_selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remove Image'),
                onTap: () {
                  Navigator.of(context).pop();
                  _removeImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (_isUploadingImage) return;

      // Request permission first with user-friendly dialog
      final permissionService = ref.read(permissionServiceProvider);
      final hasPermission = await permissionService.requestImagePermission(
        context,
        source,
      );

      if (!hasPermission) {
        return; // Permission denied, user was already notified
      }

      final pickedImage = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
      );

      if (pickedImage == null) return;

      final savedFile = await _imageUploadService.saveLocalCopy(pickedImage);

      if (!mounted) return;
      setState(() {
        _selectedImage = savedFile;
        _imageUrl = null;
      });
    } catch (e) {
      if (mounted) {
        _showError('Failed to pick image: $e');
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _imageUrl = null;
    });
  }

  bool _isWaterBottle(String categoryDisplay, String? subcategoryDisplay) {
    final canonicalCategory =
        ProductHelpers.categoryFromDisplay(categoryDisplay) ??
        categoryDisplay.toLowerCase();
    final canonicalSubcategory = subcategoryDisplay != null
        ? ProductHelpers.subcategoryFromDisplay(subcategoryDisplay)
        : null;

    return canonicalCategory == ProductCategories.water &&
        canonicalSubcategory == ProductSubcategories.bottle;
  }

  String _getUnitLabel(String categoryDisplay, String? subcategoryDisplay) {
    final canonicalCategory =
        ProductHelpers.categoryFromDisplay(categoryDisplay) ??
        categoryDisplay.toLowerCase();
    final canonicalSubcategory = subcategoryDisplay != null
        ? ProductHelpers.subcategoryFromDisplay(subcategoryDisplay)
        : null;

    if (canonicalCategory == ProductCategories.water) {
      if (canonicalSubcategory == ProductSubcategories.sachetWater) {
        return 'sachets';
      }
      if (canonicalSubcategory == ProductSubcategories.bottle) {
        return 'bottles';
      }
      return 'units';
    }

    if (canonicalCategory == ProductCategories.drink) {
      return 'btls';
    }

    return 'units';
  }

  String _getPricingUnitLabel(
    String categoryDisplay,
    String? subcategoryDisplay,
  ) {
    final canonicalCategory =
        ProductHelpers.categoryFromDisplay(categoryDisplay) ??
        categoryDisplay.toLowerCase();
    final canonicalSubcategory = subcategoryDisplay != null
        ? ProductHelpers.subcategoryFromDisplay(subcategoryDisplay)
        : null;

    if (canonicalCategory == ProductCategories.water) {
      if (canonicalSubcategory == ProductSubcategories.sachetWater) {
        return 'per sachet';
      }
      return 'per bottle';
    }

    if (canonicalCategory == ProductCategories.drink) {
      return 'per bottle';
    }

    return 'per unit';
  }

  bool _isPurchased(String categoryDisplay, String? subcategoryDisplay) {
    final canonicalCategory =
        ProductHelpers.categoryFromDisplay(categoryDisplay) ??
        categoryDisplay.toLowerCase();
    final canonicalSubcategory = subcategoryDisplay != null
        ? ProductHelpers.subcategoryFromDisplay(subcategoryDisplay)
        : null;

    if (canonicalCategory == ProductCategories.water) return true;
    if (canonicalCategory == ProductCategories.drink &&
        canonicalSubcategory == ProductSubcategories.purchased) {
      return true;
    }
    return false;
  }

  Future<void> _handleSave() async {
    // Validation
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter a product name');
      return;
    }

    final sellingPrice = double.tryParse(_sellingPriceController.text.trim());
    if (sellingPrice == null || sellingPrice < 0) {
      _showError('Please enter a valid selling price');
      return;
    }

    final unitsPerPack = _unitsPerPackController.text.trim().isEmpty
        ? null
        : int.tryParse(_unitsPerPackController.text.trim());
    if (unitsPerPack != null && unitsPerPack <= 0) {
      _showError('Units per pack must be greater than 0');
      return;
    }

    // Get current user
    final authState = ref.read(authViewModelProvider);
    final currentUser = authState.valueOrNull;
    if (currentUser == null) {
      _showError('You must be logged in to add a product');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final db = ref.read(appDatabaseProvider);
      final syncQueueDao = ref.read(pendingSyncQueueDaoProvider);

      // Generate unique product ID (using timestamp for now)
      // TODO: Consider using Firestore auto-ID generation if backend expects it
      final productId = DateTime.now().millisecondsSinceEpoch.toString();

      // Convert display names to canonical values
      final canonicalCategory =
          ProductHelpers.categoryFromDisplay(_selectedCategory) ??
          _selectedCategory.toLowerCase();
      final canonicalSubcategory = _selectedSubcategory != null
          ? ProductHelpers.subcategoryFromDisplay(_selectedSubcategory!)
          : null;
      final isBottleWater =
          canonicalCategory == ProductCategories.water &&
          canonicalSubcategory == ProductSubcategories.bottle;
      final isPurchased = _isPurchased(_selectedCategory, _selectedSubcategory);

      if (isBottleWater && (_selectedSize == null || _selectedSize!.isEmpty)) {
        _showError('Please select a size for bottled water.');
        return;
      }

      if (isPurchased && (_unitsPerPackController.text.trim().isEmpty)) {
        _showError('Units per pack is required for purchased items.');
        return;
      }
      if (isPurchased && unitsPerPack == null) {
        _showError('Please enter a valid units per pack value.');
        return;
      }

      var productName = _nameController.text.trim();
      if (isBottleWater && _selectedSize != null && _selectedSize!.isNotEmpty) {
        productName = '$productName ${_selectedSize!}';
      }

      // Determine if product is produced using helper function
      final isProduced = ProductHelpers.isProduced(
        category: canonicalCategory,
        subcategory: canonicalSubcategory,
      );

      // Determine status from toggle
      final status = _isActive ? ProductStatus.active : ProductStatus.inactive;

      if (_selectedImage != null) {
        if (mounted) {
          setState(() {
            _isUploadingImage = true;
          });
        }
        try {
          _imageUrl = await _imageUploadService.uploadProductImage(
            file: _selectedImage!,
            productId: productId,
          );
          try {
            await _selectedImage!.delete();
          } catch (_) {
            // Best-effort cleanup; ignore failures
          }
          _selectedImage = null;
        } catch (e) {
          if (mounted) {
            _showError('Failed to upload image: $e');
          }
          return;
        } finally {
          if (mounted) {
            setState(() {
              _isUploadingImage = false;
            });
          }
        }
      }

      // Create product in local database
      await db.productsDao.createProduct(
        id: productId,
        name: productName,
        category: canonicalCategory,
        subcategory: canonicalSubcategory,
        imageUrl: _imageUrl,
        isProduced: isProduced,
        sellingPrice: sellingPrice,
        unitsPerPack: isPurchased ? unitsPerPack : null,
        createdByUserId: currentUser.uid,
        status: status,
      );

      // Enqueue for sync to Firestore
      final payload = {
        'id': productId,
        'name': productName,
        'category': canonicalCategory,
        'subcategory': canonicalSubcategory,
        'isProduced': isProduced,
        'currentSellingPrice': sellingPrice,
        'unitsPerPack': isPurchased ? unitsPerPack : null,
        'imageUrl': _imageUrl,
        'status': status,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': null,
      };

      await syncQueueDao.enqueueOperation(
        id: productId,
        operationType: 'product_create',
        payload: jsonEncode(payload),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to save product: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authViewModelProvider);
    final canonicalCategory =
        ProductHelpers.categoryFromDisplay(_selectedCategory) ??
        _selectedCategory.toLowerCase();
    final canonicalSubcategory = _selectedSubcategory != null
        ? ProductHelpers.subcategoryFromDisplay(_selectedSubcategory!)
        : null;
    final isBottleWater =
        canonicalCategory == ProductCategories.water &&
        canonicalSubcategory == ProductSubcategories.bottle;
    final isPurchased = _isPurchased(_selectedCategory, _selectedSubcategory);

    return Scaffold(
      backgroundColor: JuselColors.background(context),
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isSaving ? null : () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Add Product',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ImagePickerCard(
              selectedImage: _selectedImage,
              onPickImage: _showImageSourceSheet,
              onRemoveImage: _removeImage,
              isUploading: _isUploadingImage,
            ),
            const SizedBox(height: JuselSpacing.s16),
            const _SectionTitle('BASIC INFO'),
            _FieldCard(
              child: Column(
                children: [
                  _LabeledField(
                    label: 'Product Name',
                    child: TextField(
                      controller: _nameController,
                      decoration: _inputDecoration('e.g. Orange Juice 1L', context),
                    ),
                  ),
                  const _DividerRow(),
                  _LabeledField(
                    label: 'Category',
                    child: _DropdownField(
                      value: _selectedCategory,
                      items: _categoryDisplayNames,
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                          // Reset subcategory when category changes
                          final subcats =
                              _subcategoryDisplayNames[_selectedCategory];
                          _selectedSubcategory = subcats?.isNotEmpty == true
                              ? subcats![0]
                              : null;
                          _selectedSize = null;
                          if (!_isPurchased(
                            _selectedCategory,
                            _selectedSubcategory,
                          )) {
                            _unitsPerPackController.clear();
                          }
                        });
                      },
                    ),
                  ),
                  const _DividerRow(),
                  _LabeledField(
                    label: 'Subcategory',
                    child: _DropdownField(
                      value: _selectedSubcategory,
                      items: _subcategoryDisplayNames[_selectedCategory] ?? [],
                      onChanged: (value) {
                        setState(() {
                          _selectedSubcategory = value;
                          if (!_isWaterBottle(
                            _selectedCategory,
                            _selectedSubcategory,
                          )) {
                            _selectedSize = null;
                          }
                          if (!_isPurchased(
                            _selectedCategory,
                            _selectedSubcategory,
                          )) {
                            _unitsPerPackController.clear();
                          }
                        });
                      },
                    ),
                  ),
                  if (isBottleWater) ...[
                    const _DividerRow(),
                    _LabeledField(
                      label: 'Size',
                      child: _DropdownField(
                        value: _selectedSize,
                        items: const ['500ml', '750ml', '1 Liter', '1.5 Liter'],
                        onChanged: (value) {
                          setState(() {
                            _selectedSize = value;
                          });
                        },
                      ),
                    ),
                  ],
                  const _DividerRow(),
                  _LabeledField(
                    label: 'Product Type',
                    child: _DisabledField(
                      text:
                          ProductHelpers.isProduced(
                            category: canonicalCategory,
                            subcategory: canonicalSubcategory,
                          )
                          ? 'Produced (Auto-detected)'
                          : 'Purchased (Auto-detected)',
                      icon: Icons.info_outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: JuselSpacing.s16),
            const _SectionTitle('PACK CONFIGURATION'),
            if (isPurchased) ...[
              _FieldCard(
                child: Column(
                  children: [
                    _LabeledField(
                      label: 'Units per Pack',
                      child: _FilledInput(
                        controller: _unitsPerPackController,
                        hint: '6',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        trailingText: _getUnitLabel(
                          _selectedCategory,
                          _selectedSubcategory,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: JuselSpacing.s16),
            ],
            const _SectionTitle('PRICING'),
            _FieldCard(
              child: Column(
                children: [
                  _LabeledField(
                    label: 'Selling Price',
                    child: _FilledInput(
                      controller: _sellingPriceController,
                      hint: '\$ 0.00',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      trailingText: _getPricingUnitLabel(
                        _selectedCategory,
                        _selectedSubcategory,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: JuselSpacing.s16),
            const _SectionTitle('SETTINGS'),
            _FieldCard(
              child: _ToggleRow(
                label: 'Product Status',
                helper: 'Available for sales',
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
            ),
            const SizedBox(height: JuselSpacing.s20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: JuselSpacing.s12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: JuselColors.primaryColor(context),
                  foregroundColor: JuselColors.primaryForeground,
                  disabledBackgroundColor: Colors.grey,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            JuselColors.primaryForeground,
                          ),
                        ),
                      )
                    : const Text(
                        'Save Product',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: JuselSpacing.s12),
          ],
        ),
      ),
    );
  }
}

class _ImagePickerCard extends StatefulWidget {
  final File? selectedImage;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;
  final bool isUploading;

  const _ImagePickerCard({
    required this.selectedImage,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.isUploading,
  });

  @override
  State<_ImagePickerCard> createState() => _ImagePickerCardState();
}

class _ImagePickerCardState extends State<_ImagePickerCard> {
  @override
  Widget build(BuildContext context) {
    final hasImage = widget.selectedImage != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: widget.isUploading ? null : widget.onPickImage,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                padding: hasImage
                    ? const EdgeInsets.all(JuselSpacing.s12)
                    : const EdgeInsets.symmetric(vertical: JuselSpacing.s56),
                decoration: BoxDecoration(
                  color: JuselColors.card(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: JuselColors.border(context)),
                ),
                child: hasImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Image.file(
                            widget.selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            color: JuselColors.primaryColor(context),
                            size: 32,
                          ),
                          SizedBox(height: JuselSpacing.s8),
                          Text(
                            'Add Image',
                            style: TextStyle(
                              color: JuselColors.primaryColor(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
              if (widget.isUploading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: SizedBox(
                        height: 32,
                        width: 32,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            JuselColors.primaryForeground,
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (hasImage) ...[
          const SizedBox(height: JuselSpacing.s8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: widget.isUploading ? null : widget.onRemoveImage,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove Image'),
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: JuselSpacing.s8),
      child: Text(
        text,
        style: JuselTextStyles.bodySmall(context).copyWith(
          color: JuselColors.mutedForeground(context),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  final Widget child;
  const _FieldCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(JuselSpacing.s16),
      decoration: BoxDecoration(
        color: JuselColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: JuselColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final String? helper;
  final Widget child;
  final Widget? trailing;

  const _LabeledField({
    required this.label,
    required this.child,
    this.helper,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: JuselSpacing.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: JuselTextStyles.bodySmall(context).copyWith(
                  color: JuselColors.foreground(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (helper != null)
                Text(
                  helper!,
                  style: JuselTextStyles.bodySmall(context).copyWith(
                    color: JuselColors.mutedForeground(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (trailing != null) ...[
                const SizedBox(width: JuselSpacing.s6),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: JuselSpacing.s8),
          child,
        ],
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint, BuildContext context) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: JuselColors.muted(context),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: JuselColors.primaryColor(context), width: 2),
    ),
  );
}

class _DropdownField extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;

  const _DropdownField({
    required this.value,
    required this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: JuselColors.muted(context),
        borderRadius: BorderRadius.circular(14),
        border: null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.expand_more,
            color: JuselColors.mutedForeground(context),
          ),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: JuselTextStyles.bodyMedium(context).copyWith(
                      color: JuselColors.foreground(context),
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String helper;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.helper,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: JuselTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.w700,
                  color: JuselColors.foreground(context),
                ),
              ),
              Text(
                helper,
                style: JuselTextStyles.bodySmall(context).copyWith(
                  color: JuselColors.mutedForeground(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: JuselColors.primaryForeground,
          activeTrackColor: JuselColors.primaryColor(context),
        ),
      ],
    );
  }
}

class _DividerRow extends StatelessWidget {
  const _DividerRow();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 16, color: JuselColors.border(context), thickness: 1);
  }
}

class _DisabledField extends StatelessWidget {
  final String text;
  final IconData icon;

  const _DisabledField({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: JuselColors.muted(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: JuselColors.border(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: JuselTextStyles.bodyMedium(context).copyWith(
                color: JuselColors.mutedForeground(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Icon(icon, color: JuselColors.mutedForeground(context)),
        ],
      ),
    );
  }
}

class _FilledInput extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? trailingText;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;

  const _FilledInput({
    this.controller,
    required this.hint,
    this.keyboardType,
    this.trailingText,
    this.enabled = true,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: enabled ? JuselColors.muted(context) : JuselColors.muted(context).withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: trailingText != null ? 0 : 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              enabled: enabled,
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintStyle: JuselTextStyles.bodyMedium(context).copyWith(
                  color: JuselColors.mutedForeground(context),
                ),
              ),
              style: JuselTextStyles.bodyMedium(context).copyWith(
                color: enabled
                    ? JuselColors.foreground(context)
                    : JuselColors.mutedForeground(context),
              ),
            ),
          ),
          if (trailingText != null) ...[
            const SizedBox(width: 8),
            Text(
              trailingText!,
              style: JuselTextStyles.bodySmall(context).copyWith(
                color: JuselColors.mutedForeground(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
