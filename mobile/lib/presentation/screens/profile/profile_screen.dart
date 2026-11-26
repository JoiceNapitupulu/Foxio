import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/avatar_image_helper.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/cozy_button.dart';
import '../../widgets/user_avatar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isPickingImage = false;

  Future<void> _pickCustomPhoto(ImageSource source) async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);

    try {
      final encoded = await AvatarImageHelper.pickAndEncode(source: source);
      if (encoded == null) return;

      final ok = await ref
          .read(authProvider.notifier)
          .updateAvatar(avatarData: encoded);
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil diperbarui!'),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memproses gambar. Coba pilih gambar lain.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  Future<void> _applyPresetOrReset({
    String? avatarData,
    bool clearAvatar = false,
  }) async {
    final ok = await ref.read(authProvider.notifier).updateAvatar(
          avatarData: avatarData,
          clearAvatar: clearAvatar,
        );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            clearAvatar
                ? 'Foto profil dikembalikan ke default.'
                : 'Avatar Mini Fox diperbarui!',
          ),
          backgroundColor: AppColors.secondary,
        ),
      );
    }
  }

  Future<void> _showAvatarPickerSheet(String? currentAvatar) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final hasCustomOrPreset =
            currentAvatar != null && currentAvatar.isNotEmpty;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pilih Foto Profil',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                _SheetActionTile(
                  icon: Icons.photo_library_outlined,
                  iconColor: AppColors.primary,
                  iconBg: AppColors.primaryLight,
                  title: 'Pilih Foto dari Perangkat',
                  subtitle: kIsWeb
                      ? 'Upload foto dari file browser / komputer'
                      : 'Pilih foto dari galeri HP',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _pickCustomPhoto(ImageSource.gallery);
                  },
                ),
                if (!kIsWeb) ...[
                  const SizedBox(height: 10),
                  _SheetActionTile(
                    icon: Icons.camera_alt_outlined,
                    iconColor: AppColors.secondary,
                    iconBg: AppColors.secondaryLight,
                    title: 'Ambil Foto Kamera',
                    subtitle: 'Foto langsung pakai kamera HP',
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _pickCustomPhoto(ImageSource.camera);
                    },
                  ),
                ],
                const SizedBox(height: 18),
                Text(
                  'Atau pilih gaya Mini Fox',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: AvatarImageHelper.presets.map((preset) {
                    final isSelected = currentAvatar == preset.id ||
                        ((currentAvatar == null || currentAvatar.isEmpty) &&
                            preset.id == AvatarImageHelper.presetIdle);
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        _applyPresetOrReset(avatarData: preset.id);
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.borderSubtle,
                                width: isSelected ? 2.5 : 1.2,
                              ),
                            ),
                            child: Image.asset(
                              preset.asset,
                              fit: BoxFit.contain,
                              cacheWidth: 180,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            preset.label,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                if (hasCustomOrPreset) ...[
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _applyPresetOrReset(clearAvatar: true);
                    },
                    icon: const Icon(Icons.restart_alt_rounded, size: 18),
                    label: const Text('Reset ke Foto Default'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final busy = authState.isUpdatingAvatar || _isPickingImage;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      UserAvatar(
                        avatarData: user?.avatarData,
                        size: 108,
                        isLoading: busy,
                        onTap: () => _showAvatarPickerSheet(user?.avatarData),
                      ),
                      const SizedBox(height: 6),
                      TextButton.icon(
                        onPressed: busy
                            ? null
                            : () => _showAvatarPickerSheet(user?.avatarData),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Ubah Foto'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user?.displayName ?? 'Student',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 22,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '-',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _StatTile(
                              icon: Icons.workspace_premium_rounded,
                              iconColor: AppColors.streak,
                              bgColor: AppColors.streakLight,
                              label: 'Level',
                              value: '${user?.level ?? 1}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatTile(
                              icon: Icons.auto_awesome_rounded,
                              iconColor: AppColors.secondary,
                              bgColor: AppColors.secondaryLight,
                              label: 'Total Points',
                              value: '${user?.totalPoints ?? 0} pts',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CozyButton(
                label: 'Logout',
                backgroundColor: AppColors.error,
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SheetActionTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
