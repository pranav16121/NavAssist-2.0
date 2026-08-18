import 'package:flutter_test/flutter_test.dart';
import 'package:navassist_2/main.dart';

void main() {
  testWidgets('App loads home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NavAssistApp());

    // Verify that NavAssist 2.0 home screen title is present.
    expect(find.text('NAVASSIST 2.0'), findsOneWidget);
  });
}
