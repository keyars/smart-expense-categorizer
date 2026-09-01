import 'package:flutter_test/flutter_test.dart';
import 'package:smart_expense_categorizer/main.dart';

void main() {
  testWidgets('shows expense categorizer landing screen', (tester) async {
    await tester.pumpWidget(const SmartExpenseApp());
    await tester.pumpAndSettle();

    expect(find.text('Smart Expense Categorizer'), findsOneWidget);
    expect(find.text('Categorize Expense'), findsOneWidget);
    expect(find.text('Try a demo'), findsOneWidget);
  });
}
