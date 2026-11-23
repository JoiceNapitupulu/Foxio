import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'data/local/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  runApp(
    const ProviderScope(
      child: FoxioApp(),
    ),
  );
}

class FoxioApp extends StatelessWidget {
  const FoxioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foxio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const WelcomePreviewScreen(),
    );
  }
}

class WelcomePreviewScreen extends StatelessWidget {
  const WelcomePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mascot Placeholder Avatar
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      '🦊',
                      style: TextStyle(fontSize: 48),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Foxio',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 32,
                        color: AppColors.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Grow your day, one task at a time',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.success),
                            const SizedBox(width: 8),
                            Text(
                              'Tema Soft Clean Aktif',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Google Fonts Inter, palet warna oranye rubah lembut, dan ProviderScope Riverpod telah terpasang.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
