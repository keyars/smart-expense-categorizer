import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const SmartExpenseApp());

class SmartExpenseApp extends StatelessWidget {
  const SmartExpenseApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Smart Expense Categorizer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo, scaffoldBackgroundColor: const Color(0xFFF6F7FB)),
        home: const ExpensePage(),
      );
}

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});
  @override State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final description = TextEditingController(text: 'AWS monthly server bill');
  final amount = TextEditingController(text: '12400');
  bool loading = false;
  Map<String, dynamic>? result;
  String? error;
  final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000');

  Future<void> categorize() async {
    final text = description.text.trim();
    if (text.length < 2) { setState(() => error = 'Enter a little more detail.'); return; }
    setState(() { loading = true; error = null; result = null; });
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'description': text, 'amount': double.tryParse(amount.text.trim()) ?? 0}),
      );
      if (response.statusCode != 200) throw Exception('API ${response.statusCode}');
      setState(() => result = jsonDecode(response.body) as Map<String, dynamic>);
    } catch (_) {
      setState(() => error = 'Could not reach the categorization service.');
    } finally { if (mounted) setState(() => loading = false); }
  }

  void demo(String value) { description.text = value; categorize(); }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Expense Categorizer')),
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 900), child: LayoutBuilder(builder: (context, box) {
        final wide = box.maxWidth >= 760;
        final form = _form();
        final resultCard = _result();
        return wide ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: form), const SizedBox(width: 24), Expanded(child: resultCard)]) : Column(children: [form, const SizedBox(height: 20), resultCard]);
      })))),
    );
  }

  Widget _form() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Categorize Expense', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
    const SizedBox(height: 8),
    Text('Turn an everyday transaction description into a useful spending category.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54)),
    const SizedBox(height: 20),
    TextField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'Expense description', hintText: 'e.g. AWS monthly server bill', border: OutlineInputBorder())),
    const SizedBox(height: 14),
    TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Amount (optional)', prefixText: '₹ ', border: OutlineInputBorder())),
    const SizedBox(height: 16),
    SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: loading ? null : categorize, icon: loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome), label: Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Text(loading ? 'Categorizing…' : 'Categorize Expense')))),
    const SizedBox(height: 18),
    const Text('Try a demo', style: TextStyle(fontWeight: FontWeight.w700)),
    const SizedBox(height: 8),
    Wrap(spacing: 8, runSpacing: 8, children: [
      ActionChip(label: const Text('AWS bill'), onPressed: () => demo('AWS monthly server bill')),
      ActionChip(label: const Text('Uber ride'), onPressed: () => demo('Uber ride to office')),
      ActionChip(label: const Text('Restaurant dinner'), onPressed: () => demo('Dinner at restaurant')),
      ActionChip(label: const Text('Salary credited'), onPressed: () => demo('Salary credited')),
    ]),
  ]);

  Widget _result() {
    if (loading) return Card(elevation: 0, child: const ListTile(leading: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)), title: Text('Analyzing expense…'), subtitle: Text('FastAPI + TF-IDF + Logistic Regression')));
    if (error != null) return Card(elevation: 0, child: ListTile(leading: const Icon(Icons.error_outline), title: const Text('Something went wrong'), subtitle: Text(error!)));
    if (result == null) return Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(28), child: Column(children: const [Icon(Icons.receipt_long_outlined, size: 48), SizedBox(height: 12), Text('Your category will appear here', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height: 4), Text('Enter a description and categorize it.')]))) ;
    final category = '${result!['category']}';
    final confidence = ((result!['confidence'] as num).toDouble()).clamp(0, 1);
    final items = (result!['top_predictions'] as List).cast<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    return Column(children: [
      Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Recommended category'), const SizedBox(height: 6), Text(category, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 18), LinearProgressIndicator(value: confidence, minHeight: 10, borderRadius: BorderRadius.circular(8)), const SizedBox(height: 8), Text('${(confidence * 100).toStringAsFixed(1)}% confidence', style: const TextStyle(fontWeight: FontWeight.w700))])),
      const SizedBox(height: 14),
      Card(elevation: 0, child: Padding(padding: const EdgeInsets.fromLTRB(18, 18, 18, 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Top predictions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)), const SizedBox(height: 8), ...items.map((e) { final p = (e['confidence'] as num).toDouble(); return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Expanded(child: Text('${e['category']}')), Text('${(p * 100).toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.w700))])); })])),
      TextButton.icon(onPressed: () { description.clear(); amount.clear(); setState(() => result = null); }, icon: const Icon(Icons.refresh), label: const Text('Categorize another expense')),
    ]);
  }
}
