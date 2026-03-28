import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:algoowl/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: CodekataApp()),
    );
    await tester.pump();
    // App renders without crashing
    expect(find.byType(ProviderScope), findsOneWidget);
  });
}
