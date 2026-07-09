import 'package:flutter_test/flutter_test.dart';

import 'package:citapps/app.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    // Verify that the App widget can be instantiated.
    // Full widget tests will be added per module.
    expect(const App(), isNotNull);
  });
}
