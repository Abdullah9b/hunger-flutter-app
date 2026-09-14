import 'package:flutter_test/flutter_test.dart';
import 'package:hunger/main.dart';

void main() {
  testWidgets('Hunger app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const HungerApp());

    expect(find.text('Hunger'), findsOneWidget);
    expect(find.text('What are you craving?'), findsOneWidget);
    expect(find.text('Popular Meals'), findsOneWidget);
    expect(find.text('Chicken Burger'), findsOneWidget);
  });
}
