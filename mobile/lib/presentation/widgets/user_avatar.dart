import 'dart:typed_data';
import 'package:material_ui/material_ui.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/avatar_image_helper.dart';

class UserAvatar extends StatefulWidget {
  final String? avatarData;
  final double size;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool showEditBadge;

  const UserAvatar({
    super.key,
    required this.avatarData,
    this.size = 96,
    this.onTap,
    this.isLoading = false,
    this.showEditBadge = true,
  });

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  Uint8List? _decodedBytes;

  @override
  void initState() {
    super.initState();
    _decodedBytes = AvatarImageHelper.decodeDataUri(widget.avatarData);
  }

  @override
  void didUpdateWidget(covariant UserAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatarData != widget.avatarData) {
      _decodedBytes = AvatarImageHelper.decodeDataUri(widget.avatarData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeSize = (widget.size * 0.30).clamp(26.0, 34.0);
    final Widget imageContent = _decodedBytes != null
        ? ClipOval(
            child: Image.memory(
              _decodedBytes!,
              width: widget.size,
              height: widget.size,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => _buildPresetImage(),
            ),
          )
        : _buildPresetImage();

    return Semantics(
      button: widget.onTap != null,
      label: 'Foto profil',
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: imageContent,
                ),
                if (widget.isLoading)
                  Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary.withValues(alpha: 0.42),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  ),
                if (widget.onTap != null &&
                    widget.showEditBadge &&
                    !widget.isLoading)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: badgeSize,
                      height: badgeSize,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.2),
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: badgeSize * 0.52,
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

  Widget _buildPresetImage() {
    return ClipOval(
      child: Padding(
        padding: EdgeInsets.all(widget.size * 0.08),
        child: Image.asset(
          AvatarImageHelper.presetAssetFor(widget.avatarData),
          fit: BoxFit.contain,
          cacheWidth: 320,
        ),
      ),
    );
  }
}
