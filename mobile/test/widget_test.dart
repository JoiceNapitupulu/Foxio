import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foxio_mobile/main.dart';

void main() {
  testWidgets('Foxio app boots to SplashScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FoxioApp(),
      ),
    );

    expect(find.text('Foxio'), findsOneWidget);
    expect(find.text('Grow your day, one task at a time'), findsOneWidget);
  });
}
