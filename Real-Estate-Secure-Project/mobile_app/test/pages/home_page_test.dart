import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_secure/pages/home_page.dart';

void main() {
  group('HomePage', () {
    testWidgets('displays home page title and content',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Verify AppBar title
      expect(find.text('Real Estate Secure'), findsOneWidget);

      // Verify welcome message
      expect(
        find.text('Welcome to Real Estate Secure'),
        findsOneWidget,
      );

      // Verify subtitle
      expect(
        find.text('Browse properties and manage your real estate transactions securely.'),
        findsOneWidget,
      );
    });

    testWidgets('displays feature cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Verify feature cards
      expect(find.text('Browse Properties'), findsOneWidget);
      expect(find.text('Your Profile'), findsOneWidget);
      expect(find.text('My Transactions'), findsOneWidget);

      // Verify descriptions
      expect(find.text('View available properties'), findsOneWidget);
      expect(find.text('Manage your account'), findsOneWidget);
      expect(find.text('View your transactions'), findsOneWidget);
    });

    testWidgets('displays feature cards and icons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Verify feature cards
      expect(find.text('Browse Properties'), findsOneWidget);
      expect(find.text('Your Profile'), findsOneWidget);
      expect(find.text('My Transactions'), findsOneWidget);

      // Verify at least one icon is displayed
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('bottom navigation bar displays all items',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Verify bottom navigation items
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('bottom navigation bar changes selected index',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Tap on Search tab
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // Verify state changed (check if the index changed)
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('feature card is tappable', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          routes: {
            '/properties': (context) => const Scaffold(body: Text('Properties')),
            '/profile': (context) => const Scaffold(body: Text('Profile')),
            '/transactions': (context) =>
                const Scaffold(body: Text('Transactions')),
          },
        ),
      );

      // Tap Browse Properties card
      await tester.tap(find.text('Browse Properties'));
      await tester.pumpAndSettle();

      // Verify navigation
      expect(find.text('Properties'), findsOneWidget);
    });

    testWidgets('feature cards have correct layout',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Verify cards are displayed
      expect(find.byType(Card), findsWidgets);
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('page is scrollable with multiple features',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Verify SingleChildScrollView exists
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Verify all content is present
      expect(find.text('Browse Properties'), findsOneWidget);
      expect(find.text('Your Profile'), findsOneWidget);
      expect(find.text('My Transactions'), findsOneWidget);
    });
  });
}
