// مشغّل يوتيوب داخل التطبيق.

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/app_text_styles.dart';

/// يشغّل المقطع بمعرّفه عبر المشغّل المضمّن مع دعم ملء الشاشة — بلا ما يطلّع
/// المستخدم من التطبيق.
class YoutubeVideoScreen extends StatefulWidget {
  const YoutubeVideoScreen({
    required this.videoId,
    required this.title,
    super.key,
  });

  final String videoId;
  final String title;

  @override
  State<YoutubeVideoScreen> createState() => _YoutubeVideoScreenState();
}

class _YoutubeVideoScreenState extends State<YoutubeVideoScreen> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        enableCaption: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        aspectRatio: 16 / 9,
        progressIndicatorColor: AppColors.accentGoldLight,
        progressColors: const ProgressBarColors(
          playedColor: AppColors.accentGoldLight,
          handleColor: AppColors.accentGoldLight,
        ),
      ),
      builder: (context, player) => Scaffold(
        backgroundColor: AppColors.mediaBg,
        appBar: AppBar(
          backgroundColor: AppColors.mediaBg,
          foregroundColor: Colors.white,
          title: Text(
            widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            player,
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.title,
                textAlign: TextAlign.right,
                style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
