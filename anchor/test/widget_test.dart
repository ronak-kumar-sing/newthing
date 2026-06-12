import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anchor/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AnchorApp(),
      ),
    );

    // Verify the app title is present
    expect(find.text('ANCHOR'), findsOneWidget);
  });
}
