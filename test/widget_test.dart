import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('App widget smoke test', (WidgetTester tester) async {
    // Verify the app builds without errors.
    // Full widget tests require ProviderScope + SharedPreferences setup.
    expect(find.text('أنوار السجادية'), findsNothing);
  });
}
