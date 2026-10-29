import 'package:flutter/material.dart';
import 'add_expense_screen.dart';
import 'expense_detail_screen.dart';

class Expense {
  final String title;
  final double amount;
  final String category;
  Expense(this.title, this.amount, this.category);

  Expense copyWith({String? title, double? amount, String? category}) =>
      Expense(title ?? this.title, amount ?? this.amount,
          category ?? this.category);
}

const categoryIcons = {
  'Food': Icons.restaurant,
  'Transport': Icons.directions_bus,
  'Bills': Icons.receipt_long,
  'Shopping': Icons.shopping_bag,
  'Other': Icons.category,
};

const categoryColors = <String, MaterialColor>{
  'Food': Colors.orange,
  'Transport': Colors.blue,
  'Bills': Colors.red,
  'Shopping': Colors.purple,
  'Other': Colors.teal,
};

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final List<Expense> _expenses = [];
  final List<Expense> _history = [];

  double get _total => _expenses.fold(0, (sum, e) => sum + e.amount);

  void _add() async {
    final res = await Navigator.push<Expense>(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
    if (res != null) setState(() => _expenses.add(res));
  }

  void _open(Expense e) async {
    final index = _expenses.indexOf(e);
    if (await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => ExpenseDetailScreen(
              expense: e,
              onChanged: (updatedExpense) =>
                  setState(() => _expenses[index] = updatedExpense),
            ),
          ),
        ) ==
        true) {
      setState(() => _history.add(_expenses.removeAt(index)));
    }
  }

  void _clearAll() async {
    if (await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Clear all expenses?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear', style: TextStyle(color: Colors.red))),
            ],
          ),
        ) == true) {
      setState(() { _history.addAll(_expenses); _expenses.clear(); });
    }
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Deletion History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (_history.isNotEmpty)
                    TextButton(
                      onPressed: () => setState(() { _history.clear(); setSheetState(() {}); }),
                      child: const Text('Clear', style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
              const Divider(),
              Expanded(
                child: _history.isEmpty
                    ? const Center(child: Text('No history yet.', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: _history.length,
                        itemBuilder: (_, i) {
                          final e = _history[i];
                          final c = categoryColors[e.category]!;
                          return ListTile(
                            leading: CircleAvatar(backgroundColor: c.shade100, child: Icon(categoryIcons[e.category], color: c.shade700)),
                            title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(e.category),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('₱${e.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                IconButton(
                                  tooltip: 'Restore expense',
                                  icon: const Icon(Icons.restore),
                                  onPressed: () => setState(() {
                                    _expenses.add(e);
                                    _history.removeAt(i);
                                    setSheetState(() {});
                                  }),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 24, 24, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF00796B), Color(0xFF4DB6AC)]),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Total Spent', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const Spacer(),
                    IconButton(onPressed: _showHistory, icon: const Icon(Icons.history, color: Colors.white)),
                    if (_expenses.isNotEmpty)
                      IconButton(onPressed: _clearAll, icon: const Icon(Icons.delete_sweep, color: Colors.white)),
                  ],
                ),
                Text('₱${_total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                Text('${_expenses.length} expense(s)', style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          Expanded(
            child: _expenses.isEmpty
                ? Center(child: Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey.shade400))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _expenses.length,
                    itemBuilder: (_, i) {
                      final e = _expenses[i];
                      final c = categoryColors[e.category]!;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          leading: CircleAvatar(backgroundColor: c.shade100, child: Icon(categoryIcons[e.category], color: c.shade700)),
                          title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(e.category),
                          trailing: Text('₱${e.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          onTap: () => _open(e),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}