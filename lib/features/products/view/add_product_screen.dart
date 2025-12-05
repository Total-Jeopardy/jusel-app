import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:jusel_app/core/utils/theme.dart';
import 'package:jusel_app/core/utils/product_constants.dart';
import 'package:jusel_app/core/providers/database_provider.dart';
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
  final _initialStockController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _costPriceController = TextEditingController();

  // Form state
  late String _selectedCategory;
  String? _selectedSubcategory;
  bool _isActive = true;
  bool _isSaving = false;

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
      _subcategoryDisplayNames[ProductHelpers.categoryToDisplay(category)] =
          subcats.map((sub) => ProductHelpers.subcategoryToDisplay(sub)).toList();
    }
    
    // Set default category
    _selectedCategory = _categoryDisplayNames.first;
    final defaultSubcats = _subcategoryDisplayNames[_selectedCategory];
    _selectedSubcategory = defaultSubcats?.isNotEmpty == true ? defaultSubcats![0] : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitsPerPackController.dispose();
    _initialStockController.dispose();
    _sellingPriceController.dispose();
    _costPriceController.dispose();
    super.dispose();
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

    final costPrice = _costPriceController.text.trim().isEmpty
        ? null
        : double.tryParse(_costPriceController.text.trim());
    if (costPrice != null && costPrice < 0) {
      _showError('Please enter a valid cost price');
      return;
    }

    final unitsPerPack = _unitsPerPackController.text.trim().isEmpty
        ? null
        : int.tryParse(_unitsPerPackController.text.trim());
    if (unitsPerPack != null && unitsPerPack <= 0) {
      _showError('Units per pack must be greater than 0');
      return;
    }

    final initialStock = int.tryParse(_initialStockController.text.trim()) ?? 0;
    if (initialStock < 0) {
      _showError('Initial stock cannot be negative');
      return;
    }

    // Get current user
    final authState = ref.read(authViewModelProvider);
    final currentUser = authState.valueOrNull;
    if (currentUser == null) {
      _showError('You must be logged in to add a product');
      return;
    }

    // Check if user is boss for cost price
    final isBoss = currentUser.role == 'boss';
    if (!isBoss && costPrice != null && costPrice > 0) {
      _showError('Only bosses can set cost price');
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
      final canonicalCategory = ProductHelpers.categoryFromDisplay(_selectedCategory) ?? 
                                _selectedCategory.toLowerCase();
      final canonicalSubcategory = _selectedSubcategory != null
          ? ProductHelpers.subcategoryFromDisplay(_selectedSubcategory!)
          : null;

      // Determine if product is produced using helper function
      final isProduced = ProductHelpers.isProduced(
        category: canonicalCategory,
        subcategory: canonicalSubcategory,
      );

      // Determine status from toggle
      final status = _isActive ? ProductStatus.active : ProductStatus.inactive;

      // Create product in local database
      await db.productsDao.createProduct(
        id: productId,
        name: _nameController.text.trim(),
        category: canonicalCategory,
        subcategory: canonicalSubcategory,
        isProduced: isProduced,
        currentCostPrice: costPrice,
        sellingPrice: sellingPrice,
        unitsPerPack: unitsPerPack,
        createdByUserId: currentUser.uid,
        initialStock: initialStock,
        status: status,
      );

      // Enqueue for sync to Firestore
      final payload = {
        'id': productId,
        'name': _nameController.text.trim(),
        'category': canonicalCategory,
        'subcategory': canonicalSubcategory,
        'isProduced': isProduced,
        'currentSellingPrice': sellingPrice,
        'currentCostPrice': costPrice ?? 0.0,
        'unitsPerPack': unitsPerPack,
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
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final currentUser = authState.valueOrNull;
    final isBoss = currentUser?.role == 'boss';

    return Scaffold(
      backgroundColor: JuselColors.background,
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
            _ImagePickerCard(),
            const SizedBox(height: JuselSpacing.s16),
            const _SectionTitle('BASIC INFO'),
            _FieldCard(
              child: Column(
                children: [
                  _LabeledField(
                    label: 'Product Name',
                    child: TextField(
                      controller: _nameController,
                      decoration: _inputDecoration('e.g. Orange Juice 1L'),
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
                          final subcats = _subcategoryDisplayNames[_selectedCategory];
                          _selectedSubcategory = subcats?.isNotEmpty == true ? subcats![0] : null;
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
                        });
                      },
                    ),
                  ),
                  const _DividerRow(),
                  _LabeledField(
                    label: 'Product Type',
                    child: _DisabledField(
                      text: ProductHelpers.isProduced(
                        category: ProductHelpers.categoryFromDisplay(_selectedCategory) ?? _selectedCategory.toLowerCase(),
                        subcategory: _selectedSubcategory != null
                            ? ProductHelpers.subcategoryFromDisplay(_selectedSubcategory!)
                            : null,
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
                      trailingText: 'btls',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: JuselSpacing.s16),
            const _SectionTitle('INVENTORY'),
            _FieldCard(
              child: Column(
                children: [
                  _LabeledField(
                    label: 'Initial Stock',
                    helper: 'Optional',
                    child: _FilledInput(
                      controller: _initialStockController,
                      hint: '0',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      trailingText: 'units',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: JuselSpacing.s16),
            const _SectionTitle('PRICING'),
            _FieldCard(
              child: Column(
                children: [
                  _LabeledField(
                    label: 'Selling Price',
                    child: _FilledInput(
                      controller: _sellingPriceController,
                      hint: '\$ 0.00',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                    ),
                  ),
                  const _DividerRow(),
                  _LabeledField(
                    label: 'Cost Price',
                    trailing: const _UnitTag('BOSS ONLY', color: Color(0xFF2563EB)),
                    child: _FilledInput(
                      controller: _costPriceController,
                      hint: '\$ 0.00',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      enabled: isBoss,
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
                  backgroundColor: JuselColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save Product',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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

class _ImagePickerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: JuselSpacing.s56),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.camera_alt_outlined, color: JuselColors.primary, size: 32),
          SizedBox(height: JuselSpacing.s8),
          Text(
            'Add Image',
            style: TextStyle(
              color: JuselColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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
        style: JuselTextStyles.bodySmall.copyWith(
          color: JuselColors.mutedForeground,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
                style: JuselTextStyles.bodySmall.copyWith(
                  color: JuselColors.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (helper != null)
                Text(
                  helper!,
                  style: JuselTextStyles.bodySmall.copyWith(
                    color: JuselColors.mutedForeground,
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

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF2F6FF),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
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
        color: const Color(0xFFF2F6FF),
        borderRadius: BorderRadius.circular(14),
        border: null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.expand_more,
            color: JuselColors.mutedForeground,
          ),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: JuselTextStyles.bodyMedium.copyWith(
                      color: JuselColors.foreground,
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

class _UnitTag extends StatelessWidget {
  final String text;
  final Color color;
  const _UnitTag(this.text, {this.color = JuselColors.foreground});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: JuselColors.muted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: JuselTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w700,
          color: color,
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
                style: JuselTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: JuselColors.foreground,
                ),
              ),
              Text(
                helper,
                style: JuselTextStyles.bodySmall.copyWith(
                  color: JuselColors.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: JuselColors.primary,
        ),
      ],
    );
  }
}

class _DividerRow extends StatelessWidget {
  const _DividerRow();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 16, color: Color(0xFFE5E7EB), thickness: 1);
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
        color: const Color(0xFFE9EEF6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD7DFEB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: JuselTextStyles.bodyMedium.copyWith(
                color: JuselColors.mutedForeground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Icon(icon, color: JuselColors.mutedForeground),
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
        color: enabled 
            ? const Color(0xFFF2F6FF)
            : const Color(0xFFE9EEF6),
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
                hintStyle: JuselTextStyles.bodyMedium.copyWith(
                  color: JuselColors.mutedForeground,
                ),
              ),
              style: JuselTextStyles.bodyMedium.copyWith(
                color: enabled 
                    ? JuselColors.foreground
                    : JuselColors.mutedForeground,
              ),
            ),
          ),
          if (trailingText != null) ...[
            const SizedBox(width: 8),
            Text(
              trailingText!,
              style: JuselTextStyles.bodySmall.copyWith(
                color: JuselColors.mutedForeground,
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
