// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foodi/main.dart';

void main() {
  testWidgets('FoodiApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FoodiApp());

    // Verify that the app starts properly and renders without errors
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // The app should start with the splash screen
    await tester.pumpAndSettle();
    
    // This is a basic smoke test to ensure the app builds without errors
    expect(tester.takeException(), isNull);
  });
}
