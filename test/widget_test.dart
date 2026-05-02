// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:falcon_system/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FALCON-AIS app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FalconAISApp());

    // Verify that splash screen is displayed
    expect(find.text('FALCON'), findsOneWidget);
  });
}
