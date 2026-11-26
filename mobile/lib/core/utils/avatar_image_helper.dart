import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image_picker/image_picker.dart';
import '../constants/app_assets.dart';

class AvatarImageHelper {
  AvatarImageHelper._();

  static const String presetIdle = 'preset:fox_idle';
  static const String presetExcited = 'preset:fox_excited';
  static const String presetLevelUp = 'preset:fox_levelup';
  static const String presetSleepy = 'preset:fox_sleepy';

  static const int targetAvatarSize = 240;

  static const List<({String id, String label, String asset})> presets = [
    (id: presetIdle, label: 'Santai', asset: AppAssets.foxIdle),
    (id: presetExcited, label: 'Semangat', asset: AppAssets.foxExcited),
    (id: presetLevelUp, label: 'Juara', asset: AppAssets.foxLevelUp),
    (id: presetSleepy, label: 'Ngantuk', asset: AppAssets.foxSleepy),
  ];

  static bool isCustomDataUri(String? avatarData) {
    return avatarData != null && avatarData.startsWith('data:image/');
  }

  static String presetAssetFor(String? avatarData) {
    switch (avatarData) {
      case presetExcited:
        return AppAssets.foxExcited;
      case presetLevelUp:
        return AppAssets.foxLevelUp;
      case presetSleepy:
        return AppAssets.foxSleepy;
      case presetIdle:
      default:
        return AppAssets.foxIdle;
    }
  }

  static Uint8List? decodeDataUri(String? avatarData) {
    if (!isCustomDataUri(avatarData)) return null;
    final raw = avatarData!;
    final commaIndex = raw.indexOf(',');
    if (commaIndex == -1 || commaIndex >= raw.length - 1) {
      return null;
    }
    try {
      return base64Decode(raw.substring(commaIndex + 1));
    } catch (_) {
      return null;
    }
  }

  /// Memilih gambar dari galeri/file picker (Web & Android) atau kamera,
  /// memotong center-square, lalu mengompresi ke PNG 240x240 Data URI.
  static Future<String?> pickAndEncode({
    ImageSource source = ImageSource.gallery,
  }) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return null;

    final rawBytes = await picked.readAsBytes();
    return encodeBytesToAvatarDataUri(rawBytes);
  }

  static Future<String?> encodeBytesToAvatarDataUri(Uint8List rawBytes) async {
    ui.Codec? codec;
    ui.Image? sourceImage;
    ui.Image? croppedImage;
    try {
      codec = await ui.instantiateImageCodec(rawBytes);
      final frame = await codec.getNextFrame();
      sourceImage = frame.image;

      final srcW = sourceImage.width.toDouble();
      final srcH = sourceImage.height.toDouble();
      if (srcW <= 0 || srcH <= 0) return null;

      final cropSide = math.min(srcW, srcH);
      final srcRect = ui.Rect.fromLTWH(
        (srcW - cropSide) / 2,
        (srcH - cropSide) / 2,
        cropSide,
        cropSide,
      );
      const dstSize = 240.0;
      const dstRect = ui.Rect.fromLTWH(0, 0, dstSize, dstSize);

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder, dstRect);
      final paint = ui.Paint()
        ..isAntiAlias = true
        ..filterQuality = ui.FilterQuality.medium;

      canvas.drawImageRect(sourceImage, srcRect, dstRect, paint);
      final picture = recorder.endRecording();
      try {
        croppedImage = await picture.toImage(
          targetAvatarSize,
          targetAvatarSize,
        );
      } finally {
        picture.dispose();
      }

      final byteData = await croppedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return null;

      final pngBytes = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );
      return 'data:image/png;base64,${base64Encode(pngBytes)}';
    } catch (_) {
      return null;
    } finally {
      croppedImage?.dispose();
      sourceImage?.dispose();
      codec?.dispose();
    }
  }
}
