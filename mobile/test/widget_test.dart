import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foxio_mobile/main.dart';
import 'package:foxio_mobile/presentation/widgets/minifox_3d_card.dart';
import 'package:material_ui/material_ui.dart';

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

  testWidgets('MiniFox3dCard renders cozy 2D fallback and caption',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MiniFox3dCard(initial3dEnabled: false),
        ),
      ),
    );

    expect(find.text('Mini Fox is cheering for you!'), findsOneWidget);
    expect(find.text('2D'), findsOneWidget);
  });
}
