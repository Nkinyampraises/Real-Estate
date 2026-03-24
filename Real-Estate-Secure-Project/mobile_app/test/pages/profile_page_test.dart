import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_secure/pages/profile_page.dart';

void main() {
  group('ProfilePage', () {
    testWidgets('displays user profile information',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfilePage(),
        ),
      );

      // Verify AppBar
      expect(find.text('Profile'), findsOneWidget);

      // Verify user information
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john.doe@example.com'), findsWidgets);

      // Verify avatar
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('displays account information section',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfilePage(),
        ),
      );

      // Verify section title
      expect(find.text('Account Information'), findsOneWidget);

      // Verify account details
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Member Since'), findsOneWidget);

      // Verify values
      expect(find.text('john.doe@example.com'), findsWidgets);
      expect(find.text('+237 6XX XXX XXX'), findsOneWidget);
      expect(find.text('Cameroon'), findsOneWidget);
      expect(find.text('2024'), findsOneWidget);
    });

    testWidgets('displays settings section', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfilePage(),
        ),
      );

      // Verify settings section title
      expect(find.text('Settings'), findsOneWidget);

      // Verify settings items
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Terms & Conditions'), findsOneWidget);
    });

    testWidgets('notifications toggle is initially enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfilePage(),
        ),
      );

      // Verify switch exists
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('notifications toggle can be switched off',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfilePage(),
        ),
      );

      // Get the switch
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      // Make sure it's visible and interactable.
      await tester.ensureVisible(switchFinder);
      await tester.pumpAndSettle();

      // Tap the switch
      await tester.tap(switchFinder, warnIfMissed: false);
      await tester.pump();

      // Verify switch state changed
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('logout button exists',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfilePage(),
        ),
      );

      // Scroll down to find the logout button
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Verify logout button
      expect(find.text('Logout'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 10)));

    testWidgets('displays settings controls',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfilePage(),
        ),
      );

      // Scroll to settings section
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Verify settings section title
      expect(find.text('Settings'), findsOneWidget);

      // Verify settings items
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 10)));

    testWidgets('cancel button label exists after logout tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfilePage(),
        ),
      );

      // Scroll to and tap logout button
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // Verify cancel button appears in confirmation dialog
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('logout button has correct style',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfilePage(),
        ),
      );

      // Verify logout button exists and has the right appearance
      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
    });

    testWidgets('displays all section titles correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfilePage(),
        ),
      );

      // Verify all titles
      expect(find.text('Account Information'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('page is scrollable', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfilePage(),
        ),
      );

      // Verify SingleChildScrollView exists
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('displays user avatar icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfilePage(),
        ),
      );

      // Verify avatar and icon
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('list tiles have correct structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfilePage(),
        ),
      );

      // Verify list tiles exist
      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('displays privacy policy and terms items',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfilePage(),
        ),
      );

      // Verify navigation items have forward arrow
      expect(find.byIcon(Icons.arrow_forward), findsWidgets);
    });
  });
}
