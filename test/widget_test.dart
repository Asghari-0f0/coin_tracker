import 'package:coin_tracker/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the coin tracker title', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Coin Tracker'), findsOneWidget);
  });
}
