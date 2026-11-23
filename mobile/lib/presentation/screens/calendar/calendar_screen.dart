import 'package:material_ui/material_ui.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Calendar')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: Image.asset(AppAssets.foxEmpty, fit: BoxFit.contain),
              ),
              const SizedBox(height: 16),
              Text(
                'Calendar View Coming Soon',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track your productive days and habit milestones in one cozy calendar.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
