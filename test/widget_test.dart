import 'package:flutter_test/flutter_test.dart';
import 'package:auranote/main.dart';

void main() {
  testWidgets('AuraNote smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AuraApp());

    // Verify that the title 'AuraNote' is present.
    expect(find.text('AuraNote'), findsOneWidget);
  });
}
