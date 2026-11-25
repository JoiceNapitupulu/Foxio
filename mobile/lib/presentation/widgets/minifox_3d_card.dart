import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';

class MiniFox3dCard extends StatefulWidget {
  final bool? initial3dEnabled;

  const MiniFox3dCard({super.key, this.initial3dEnabled});

  @override
  State<MiniFox3dCard> createState() => _MiniFox3dCardState();
}

class _MiniFox3dCardState extends State<MiniFox3dCard>
    with TickerProviderStateMixin {
  late bool _is3dEnabled;
  late final AnimationController _breathController;
  late final Animation<double> _breathOffset;
  late final AnimationController _squishController;
  late final Animation<double> _squishScale;

  bool get _supports3dPlatform =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void initState() {
    super.initState();
    _is3dEnabled = widget.initial3dEnabled ?? _supports3dPlatform;

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _breathOffset = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _squishController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _squishScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.91)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.91, end: 1.05)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
    ]).animate(_squishController);
  }

  @override
  void dispose() {
    _breathController.dispose();
    _squishController.dispose();
    super.dispose();
  }

  void _triggerTapSquish() {
    _squishController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          children: [
            // Top Pills Row: Hint Badge & 3D/2D Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _is3dEnabled
                            ? Icons.threesixty_rounded
                            : Icons.touch_app_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _is3dEnabled
                            ? '360° • Putar Mini Fox'
                            : 'Tap Mini Fox',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11.5,
                            ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    setState(() => _is3dEnabled = !_is3dEnabled);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _is3dEnabled
                          ? AppColors.primaryLight
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _is3dEnabled
                            ? AppColors.primary.withValues(alpha: 0.35)
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _is3dEnabled
                              ? Icons.view_in_ar_rounded
                              : Icons.eco_rounded,
                          size: 13,
                          color: _is3dEnabled
                              ? AppColors.primaryDark
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _is3dEnabled ? '3D' : '2D',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: _is3dEnabled
                                        ? AppColors.primaryDark
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11.5,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Interactive 3D / Animated 2D Stage
            SizedBox(
              height: 210,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Soft Radial Blush Peach Glow
                  Container(
                    width: 176,
                    height: 176,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primaryLight,
                          AppColors.primaryLight.withValues(alpha: 0.35),
                          AppColors.surface.withValues(alpha: 0.0),
                        ],
                        stops: const [0.45, 0.78, 1.0],
                      ),
                    ),
                  ),

                  if (_is3dEnabled)
                    const Positioned.fill(
                      child: ModelViewer(
                        src: AppAssets.fox3dIdle,
                        poster: AppAssets.foxIdle,
                        alt: 'Mini Fox 3D Companion',
                        autoPlay: true,
                        cameraControls: true,
                        disableZoom: true,
                        disablePan: true,
                        touchAction: TouchAction.panY,
                        interactionPrompt: InteractionPrompt.none,
                        minCameraOrbit: 'auto 60deg auto',
                        maxCameraOrbit: 'auto 95deg auto',
                        backgroundColor: Colors.transparent,
                        shadowIntensity: 0.25,
                        exposure: 1.05,
                        debugLogging: false,
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _triggerTapSquish,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _breathController,
                          _squishController,
                        ]),
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _breathOffset.value),
                            child: Transform.scale(
                              scale: _squishScale.value,
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            AppAssets.foxIdle,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Cozy Companion Caption
            Text(
              'Mini Fox is cheering for you!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Complete a task (+10 pts) or habit (+15 pts) to help your sprout grow.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13.5,
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
