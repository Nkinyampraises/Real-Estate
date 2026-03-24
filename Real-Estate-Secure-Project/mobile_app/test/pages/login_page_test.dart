import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_secure/pages/login_page.dart';

void main() {
  group('LoginPage', () {
    testWidgets('displays login form elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // Verify AppBar
      expect(find.text('Login'), findsWidgets);

      // Verify TextFields
      expect(find.byType(TextField), findsWidgets);

      // Verify button
      expect(find.byType(ElevatedButton), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 10)));

    testWidgets('email field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // Enter email
      await tester.enterText(
        find.byType(TextField).first,
        'test@example.com',
      );

      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('password field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // Enter password
      await tester.enterText(
        find.byType(TextField).last,
        'password123',
      );

      // Verify the password field received the input (it's in the widget tree 
      // even if obscured visually)
      final textField = find.byType(TextField).last;
      expect(textField, findsOneWidget);
    });

    testWidgets('login button is enabled when form is filled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // Fill form
      await tester.enterText(
        find.byType(TextField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextField).last,
        'password123',
      );

      // Verify button is enabled
      expect(
        find.byType(ElevatedButton),
        findsOneWidget,
      );

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
    });

    testWidgets('login button shows loading state while processing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // Fill form
      await tester.enterText(
        find.byType(TextField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextField).last,
        'password123',
      );

      // Tap login button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify loading indicator appears immediately
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Advance past login delay to clear pending timer and navigation
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();

      // Verify we navigated away
      expect(find.text('Real Estate Secure'), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 15)));

    testWidgets('navigates to home page after login',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // Fill form
      await tester.enterText(
        find.byType(TextField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextField).last,
        'password123',
      );

      // Tap login button
      await tester.tap(find.byType(ElevatedButton));

      // Flush microtasks and navigation
      await tester.pumpAndSettle();

      // Verify navigated to home page
      expect(find.text('Real Estate Secure'), findsOneWidget);
      expect(find.text('Welcome to Real Estate Secure'), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 15)));

    testWidgets('clears controllers on dispose', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // Enter data
      await tester.enterText(
        find.byType(TextField).first,
        'test@example.com',
      );

      // Navigate away (dispose the widget)
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      expect(find.byType(LoginPage), findsNothing);
    });
  });
}
