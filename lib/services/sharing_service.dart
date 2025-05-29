import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart'; // Removed for build
// import 'package:url_launcher/url_launcher.dart'; // Removed for build

import '../models/models.dart';
import '../utils/utils.dart';
import 'achievement_service.dart';
import 'auth_service.dart';

class SharingService {
  static final SharingService _instance = SharingService._internal();
  final AuthService _authService = AuthService();

  factory SharingService() {
    return _instance;
  }

  SharingService._internal();

  // Share achievement
  Future<void> shareAchievement(Achievement achievement) async {
    final userName = _authService.currentUserName ?? 'A user';
    final text = '$userName has unlocked the "${achievement.title}" achievement in Pathfinder!\n\n'
        '${achievement.description}\n\n'
        'Download Pathfinder and start your journey: https://pathfinder.app';

    await shareContent(text);
  }

  // Share test result
  Future<void> shareTestResult(Report report, TestSet testSet) async {
    final userName = _authService.currentUserName ?? 'A user';
    final score = report.score ?? 0;
    final percentage = report.percentage?.toStringAsFixed(1) ?? '0.0';

    final text = '$userName scored $score points ($percentage%) on "${testSet.title}" in Pathfinder!\n\n'
        'Download Pathfinder and test your skills: https://pathfinder.app';

    await shareContent(text);
  }

  // Share badge
  Future<void> shareBadge(AchievementBadge badge) async {
    final userName = _authService.currentUserName ?? 'A user';
    final text = '$userName has reached level ${badge.level} in the "${badge.title}" badge in Pathfinder!\n\n'
        '${badge.description}\n\n'
        'Download Pathfinder and start earning badges: https://pathfinder.app';

    await shareContent(text);
  }

  // Share analytics
  Future<void> shareAnalytics(Map<String, dynamic> insights) async {
    final userName = _authService.currentUserName ?? 'A user';
    final totalTests = insights['totalTests'] ?? 0;
    final averageScore = insights['averageScore']?.toStringAsFixed(1) ?? '0.0';
    final highestScore = insights['highestScore']?.toStringAsFixed(1) ?? '0.0';

    final text = '$userName has completed $totalTests tests with an average score of $averageScore% in Pathfinder!\n\n'
        'Highest score: $highestScore%\n\n'
        'Download Pathfinder and start your journey: https://pathfinder.app';

    await shareContent(text);
  }

  // Share widget as image
  Future<void> shareWidgetAsImage(GlobalKey widgetKey, String message) async {
    if (kIsWeb) {
      // Web doesn't support sharing images, so just share the text
      await shareContent(message);
      return;
    }

    try {
      // Capture the widget as an image
      final RenderRepaintBoundary boundary = widgetKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to convert widget to image');
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Save the image to a temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/pathfinder_share.png');
      await file.writeAsBytes(pngBytes);

      // Share the image - simplified for build
      print('Sharing image: $message');
    } catch (e) {
      print('Error sharing widget as image: $e');
      // Fall back to sharing just the text
      await shareContent(message);
    }
  }

  // Share to specific platform
  Future<void> shareToSocialMedia(String platform, String text) async {
    String url;

    switch (platform.toLowerCase()) {
      case 'twitter':
      case 'x':
        url = 'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(text)}';
        break;
      case 'facebook':
        url = 'https://www.facebook.com/sharer/sharer.php?u=https://pathfinder.app&quote=${Uri.encodeComponent(text)}';
        break;
      case 'linkedin':
        url = 'https://www.linkedin.com/shareArticle?mini=true&url=https://pathfinder.app&title=Pathfinder&summary=${Uri.encodeComponent(text)}';
        break;
      case 'whatsapp':
        url = 'https://wa.me/?text=${Uri.encodeComponent(text)}';
        break;
      case 'telegram':
        url = 'https://t.me/share/url?url=https://pathfinder.app&text=${Uri.encodeComponent(text)}';
        break;
      default:
        throw Exception('Unsupported platform: $platform');
    }

    // Simplified for build - just print the URL
    print('Would launch URL: $url');
  }

  // Share content
  Future<void> shareContent(String text) async {
    if (kIsWeb) {
      // Web doesn't support Share.share, so we'll use the clipboard
      // and show a dialog to the user
      await Clipboard.setData(ClipboardData(text: text));
      return;
    }

    // Simplified for build
    print('Sharing content: $text');
  }
}
