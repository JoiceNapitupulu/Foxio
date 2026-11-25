import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foxio_mobile/main.dart';
import 'package:foxio_mobile/presentation/providers/todo_provider.dart';
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

  testWidgets('MiniFox3dCard displays excited reward banner and progress',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: MiniFox3dCard(
              initial3dEnabled: false,
              mood: MascotMood.excited,
              rewardBannerText: 'Yay! Task selesai (+10 pts)',
              completedCount: 2,
              totalCount: 4,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Yay! Task selesai (+10 pts)'), findsOneWidget);
    expect(find.text('2 / 4 selesai (50%)'), findsOneWidget);
    expect(find.text('Hebat!'), findsOneWidget);
  });
}
