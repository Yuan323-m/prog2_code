import 'package:flutter/material.dart';
import 'expense_list_screen.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final Expense expense;
  final ValueChanged<Expense> onChanged;
  const ExpenseDetailScreen({
    super.key,
    required this.expense,
    required this.onChanged,
  });

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  late Expense _current;

  @override
  void initState() {
    super.initState();
    _current = widget.expense;
  }

  void _update(Expense expense) {
    setState(() => _current = expense);
    widget.onChanged(expense);
  }

  Future<void> _edit({required bool amount}) async {
    final label = amount ? 'Amount' : 'Name';
    final formKey = GlobalKey<FormState>();
    final fieldKey = GlobalKey<FormFieldState<String>>();
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Edit $label'),
        content: Form(
          key: formKey,
          child: TextFormField(
            key: fieldKey,
            initialValue:
                amount ? _current.amount.toStringAsFixed(2) : _current.title,
            autofocus: true,
            keyboardType: amount
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            decoration: InputDecoration(labelText: label),
            validator: (value) {
              if (!amount) {
                return value == null || value.trim().isEmpty
                    ? 'Name is required'
                    : null;
              }
              final parsed = double.tryParse(value ?? '');
              return parsed == null || !parsed.isFinite || parsed <= 0
                  ? 'Enter a positive amount'
                  : null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                  Navigator.pop(
                    dialogContext,
                    fieldKey.currentState!.value!.trim(),
                  );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (value == null || !mounted) return;
    _update(_current.copyWith(
      title: amount ? null : value,
      amount: amount ? double.parse(value) : null,
    ));
  }

  Future<void> _editCategory() async {
    final category = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Edit Category'),
        children: categoryIcons.keys.map((category) {
          final color = categoryColors[category]!;
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, category),
            child: Row(
              children: [
                Icon(categoryIcons[category], color: color),
                const SizedBox(width: 12),
                Text(category),
                const Spacer(),
                if (category == _current.category) const Icon(Icons.check),
              ],
            ),
          );
        }).toList(),
      ),
    );
    if (category == null || !mounted) return;
    _update(_current.copyWith(category: category));
  }

  @override
  Widget build(BuildContext context) {
    final color = categoryColors[_current.category]!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 44,
              backgroundColor: color.shade100,
              child: Icon(categoryIcons[_current.category],
                  size: 44, color: color.shade700),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '₱${_current.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 36, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  tooltip: 'Edit amount',
                  onPressed: () => _edit(amount: true),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text('Name'),
                    subtitle: Text(_current.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    trailing: IconButton(
                      tooltip: 'Edit name',
                      onPressed: () => _edit(amount: false),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(categoryIcons[_current.category],
                        color: color.shade700),
                    title: const Text('Category'),
                    subtitle: Text(_current.category,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    trailing: IconButton(
                      tooltip: 'Edit category',
                      onPressed: _editCategory,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}