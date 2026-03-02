// This is a basic Flutter widget test for WishMovies app
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterapp/main.dart';

void main() {
  testWidgets('WishMovies app starts with splash screen', (WidgetTester tester) async {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    // Build our app and trigger a frame
    await tester.pumpWidget(WishMoviesApp(sharedPreferences: sharedPreferences));

    // Wait for async initialization
    await tester.pumpAndSettle();

    // Verify that we have WishMovies text (either on splash or login screen)
    expect(find.text('WishMovies'), findsWidgets);
  });
}
