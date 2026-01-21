import 'package:flutter_test/flutter_test.dart';
import 'package:wheat/main.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const WheatApp());

    // Just check app runs without crash
    expect(find.byType(WheatApp), findsOneWidget);
  });
}
