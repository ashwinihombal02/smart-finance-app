import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trackerapp/src/Providers/finance_provider.dart';
import 'package:trackerapp/Pages/Dashboard.dart';

void main() {
  testWidgets('Dashboard loads and shows balance text',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FinanceProvider(),
        child: MaterialApp(home: DashboardPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Current Balance'), findsOneWidget);
  });
}
