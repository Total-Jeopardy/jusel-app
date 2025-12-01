import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/theme.dart';

class NewBatchScreen extends StatefulWidget {
  const NewBatchScreen({super.key});

  @override
  State<NewBatchScreen> createState() => _NewBatchScreenState();
}

class _NewBatchScreenState extends State<NewBatchScreen> {
  final TextEditingController _qtyController = TextEditingController(text: '20');
  final List<String> _recipes = ['Standard Recipe', 'Low Sugar Variant', 'Bulk'];
  String _selectedRecipe = 'Standard Recipe';
  final List<_CostItem> _costItems = [const _CostItem(type: 'Ingredients', amount: 12.0)];

  final _product = const _ProductSummary(
    name: 'Orange Juice 1L',
    tags: 'Homemade / Fresh',
    currentStock: 12,
  );

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JuselColors.background,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Production Batch',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // TODO: handle save batch
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: JuselSpacing.s16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Save Batch',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: JuselSpacing.s16),
              Text(
                'Product',
                style: JuselTextStyles.bodySmall.copyWith(
                  color: JuselColors.mutedForeground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: JuselSpacing.s8),
              _ProductCard(product: _product),
              const SizedBox(height: JuselSpacing.s16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(JuselSpacing.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity Produced (Units)',
                      style: JuselTextStyles.bodySmall.copyWith(
                        color: JuselColors.mutedForeground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s8),
                    _QtyField(controller: _qtyController),
                    const SizedBox(height: JuselSpacing.s16),
                    Text(
                      'Production Type',
                      style: JuselTextStyles.bodySmall.copyWith(
                        color: JuselColors.mutedForeground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s8),
                    const _ProductionTypeCard(),
                  ],
                ),
              ),
              const SizedBox(height: JuselSpacing.s20),
              Text(
                'Recipe Templates',
                style: JuselTextStyles.bodySmall.copyWith(
                  color: JuselColors.mutedForeground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: JuselSpacing.s8),
              _RecipeChips(
                recipes: _recipes,
                selected: _selectedRecipe,
                onSelected: (value) {
                  setState(() => _selectedRecipe = value);
                },
              ),
              const SizedBox(height: JuselSpacing.s20),
              Text(
                'Cost Breakdown',
                style: JuselTextStyles.bodySmall.copyWith(
                  color: JuselColors.mutedForeground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: JuselSpacing.s8),
              _CostBreakdownCard(
                items: _costItems,
                onAdd: () {
                  setState(() {
                    _costItems.add(const _CostItem(type: 'Ingredients', amount: 0));
                  });
                },
                onRemove: (index) {
                  setState(() {
                    _costItems.removeAt(index);
                  });
                },
                onAmountChanged: (index, value) {
                  setState(() {
                    _costItems[index] = _costItems[index].copyWith(amount: value);
                  });
                },
                onTypeChanged: (index, value) {
                  setState(() {
                    _costItems[index] = _costItems[index].copyWith(type: value);
                  });
                },
              ),
              const SizedBox(height: JuselSpacing.s20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final _ProductSummary product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: open product picker
        },
        child: Padding(
          padding: const EdgeInsets.all(JuselSpacing.s16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: JuselTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: JuselColors.foreground,
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s6),
                    Text(
                      product.tags,
                      style: JuselTextStyles.bodySmall.copyWith(
                        color: JuselColors.mutedForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: JuselSpacing.s12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F8EF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF16A34A),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Current Stock: ${product.currentStock} units',
                            style: JuselTextStyles.bodySmall.copyWith(
                              color: const Color(0xFF16A34A),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: JuselColors.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyField extends StatelessWidget {
  final TextEditingController controller;

  const _QtyField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: '0',
        suffixIcon: const Icon(Icons.edit, size: 18, color: JuselColors.mutedForeground),
        filled: true,
        fillColor: const Color(0xFFF8FAFF),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: JuselColors.primary, width: 1.2),
        ),
      ),
    );
  }
}

class _ProductionTypeCard extends StatelessWidget {
  const _ProductionTypeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: JuselSpacing.s12,
        vertical: JuselSpacing.s12,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_drink_outlined,
                  size: 16,
                  color: Color(0xFF6B5BFF),
                ),
                const SizedBox(width: 6),
                Text(
                  'Local Drink',
                  style: JuselTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF6B5BFF),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            'Auto-detected',
            style: JuselTextStyles.bodySmall.copyWith(
              color: JuselColors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeChips extends StatelessWidget {
  final List<String> recipes;
  final String selected;
  final ValueChanged<String> onSelected;

  const _RecipeChips({
    required this.recipes,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: recipes.map((recipe) {
          final isActive = recipe == selected;
          return Padding(
            padding: const EdgeInsets.only(right: JuselSpacing.s8),
            child: InkWell(
              onTap: () => onSelected(recipe),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFE8F1FF) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? JuselColors.primary : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  children: [
                    if (isActive)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(
                          Icons.edit_calendar_outlined,
                          size: 16,
                          color: JuselColors.primary,
                        ),
                      ),
                    Text(
                      recipe,
                      style: JuselTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isActive ? JuselColors.primary : JuselColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CostBreakdownCard extends StatelessWidget {
  final List<_CostItem> items;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;
  final void Function(int index, double value) onAmountChanged;
  final void Function(int index, String value) onTypeChanged;

  const _CostBreakdownCard({
    required this.items,
    required this.onAdd,
    required this.onRemove,
    required this.onAmountChanged,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(JuselSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review costs for Local Drink batch.',
              style: JuselTextStyles.bodySmall.copyWith(
                color: JuselColors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: JuselSpacing.s12),
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == items.length - 1 ? 0 : JuselSpacing.s12,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: JuselSpacing.s12,
                    vertical: JuselSpacing.s8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: item.type,
                            isExpanded: true,
                            borderRadius: BorderRadius.circular(12),
                            items: const [
                              DropdownMenuItem(
                                value: 'Ingredients',
                                child: Text('Ingredients'),
                              ),
                              DropdownMenuItem(
                                value: 'Labor',
                                child: Text('Labor'),
                              ),
                              DropdownMenuItem(
                                value: 'Packaging',
                                child: Text('Packaging'),
                              ),
                              DropdownMenuItem(
                                value: 'Transport',
                                child: Text('Transport'),
                              ),
                              DropdownMenuItem(
                                value: 'Other',
                                child: Text('Other'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) onTypeChanged(index, val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: JuselSpacing.s12),
                      Expanded(
                        flex: 4,
                        child: TextField(
                          controller: TextEditingController(
                            text: item.amount.toStringAsFixed(2),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (val) {
                            final parsed = double.tryParse(val) ?? 0;
                            onAmountChanged(index, parsed);
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8FAFF),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: JuselSpacing.s12,
                              vertical: JuselSpacing.s8,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: JuselColors.primary,
                                width: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: JuselSpacing.s8),
                      InkWell(
                        onTap: () => onRemove(index),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE9EA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: JuselColors.destructive,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: JuselSpacing.s12),
            OutlinedButton.icon(
              onPressed: onAdd,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD7E3F4)),
                padding: const EdgeInsets.symmetric(
                  vertical: JuselSpacing.s12,
                  horizontal: JuselSpacing.s12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add, color: JuselColors.primary),
              label: Text(
                'Add Cost Item',
                style: JuselTextStyles.bodySmall.copyWith(
                  color: JuselColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductSummary {
  final String name;
  final String tags;
  final int currentStock;

  const _ProductSummary({
    required this.name,
    required this.tags,
    required this.currentStock,
  });
}

class _CostItem {
  final String type;
  final double amount;

  const _CostItem({required this.type, required this.amount});

  _CostItem copyWith({String? type, double? amount}) {
    return _CostItem(
      type: type ?? this.type,
      amount: amount ?? this.amount,
    );
  }
}
