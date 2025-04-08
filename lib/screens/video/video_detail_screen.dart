import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/widgets/loading_widget.dart';

class VideoDetailScreen extends StatefulWidget {
  const VideoDetailScreen({Key? key}) : super(key: key);

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  bool _isFullScreen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Video video = ModalRoute.of(context)!.settings.arguments as Video;
    final videoId = YoutubePlayer.convertUrlToId(video.youtubeUrl);

    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          captionLanguage: 'id',
        ),
      )..addListener(_controllerListener);
    }
  }

  void _controllerListener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _isFullScreen = false;
      });
    }

    if (_controller.value.isFullScreen) {
      setState(() {
        _isFullScreen = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_controllerListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Video video = ModalRoute.of(context)!.settings.arguments as Video;
    final videoId = YoutubePlayer.convertUrlToId(video.youtubeUrl);

    if (videoId == null) {
      // Invalid YouTube URL
      return Scaffold(
        appBar: AppBar(
          title: const Text('Video Pembelajaran'),
        ),
        body: const AppErrorWidget(
          message: 'URL YouTube tidak valid atau tidak dapat diputar.',
        ),
      );
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppTheme.primaryColor,
        progressColors: const ProgressBarColors(
          playedColor: AppTheme.primaryColor,
          handleColor: AppTheme.primaryColorDark,
        ),
        onReady: () {
          setState(() {
            _isPlayerReady = true;
          });
        },
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: _isFullScreen
              ? null
              : AppBar(
                  title: Text(video.judul),
                ),
          body: _isFullScreen
              ? player
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Video Player
                    player,

                    // Video Info
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Judul dan Info
                            Text(
                              video.judul,
                              style: AppTheme.headingMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Dipublikasikan: ${_formatDate(video.createdAt)}',
                                  style: AppTheme.bodySmall.copyWith(color: Colors.grey),
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.update,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Diperbarui: ${_formatDate(video.updatedAt)}',
                                  style: AppTheme.bodySmall.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                            const Divider(height: 32),

                            // Deskripsi
                            Text(
                              'Deskripsi',
                              style: AppTheme.subtitleLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              video.deskripsi,
                              style: AppTheme.bodyMedium,
                            ),
                            const SizedBox(height: 24),

                            // Video Controls
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColorLight.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kontrol Video',
                                    style: AppTheme.subtitleMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildControlButton(
                                        'Putar',
                                        Icons.play_arrow,
                                        () {
                                          if (_isPlayerReady) {
                                            _controller.play();
                                          }
                                        },
                                      ),
                                      _buildControlButton(
                                        'Jeda',
                                        Icons.pause,
                                        () {
                                          if (_isPlayerReady) {
                                            _controller.pause();
                                          }
                                        },
                                      ),
                                      _buildControlButton(
                                        'Ulang',
                                        Icons.replay,
                                        () {
                                          if (_isPlayerReady) {
                                            _controller.seekTo(Duration.zero);
                                            _controller.play();
                                          }
                                        },
                                      ),
                                      _buildControlButton(
                                        'Layar Penuh',
                                        Icons.fullscreen,
                                        () {
                                          if (_isPlayerReady) {
                                            _controller.toggleFullScreenMode();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildControlButton(String label, IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}