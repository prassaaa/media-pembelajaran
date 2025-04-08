import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pembelajaran_app/config/constants.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';
import 'package:pembelajaran_app/widgets/loading_widget.dart';

class AdminVideoScreen extends StatefulWidget {
  const AdminVideoScreen({Key? key}) : super(key: key);

  @override
  State<AdminVideoScreen> createState() => _AdminVideoScreenState();
}

class _AdminVideoScreenState extends State<AdminVideoScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  late Stream<List<Video>> _videoStream;

  @override
  void initState() {
    super.initState();
    _videoStream = _firebaseService.getVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Video'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppConstants.routeAdminVideoForm,
              ).then((_) => setState(() {
                    _videoStream = _firebaseService.getVideos();
                  }));
            },
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Video',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Memuat data video...')
          : StreamBuilder<List<Video>>(
              stream: _videoStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget(message: 'Memuat data video...');
                }

                if (snapshot.hasError) {
                  return AppErrorWidget(
                    message: 'Terjadi kesalahan: ${snapshot.error}',
                    onRetry: () {
                      setState(() {
                        _videoStream = _firebaseService.getVideos();
                      });
                    },
                  );
                }

                final List<Video> videoList = snapshot.data ?? [];

                if (videoList.isEmpty) {
                  return const EmptyStateWidget(
                    title: 'Belum Ada Video',
                    subtitle:
                        'Tambahkan video pembelajaran untuk ditampilkan pada aplikasi.',
                    icon: Icons.video_library,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: videoList.length,
                  itemBuilder: (context, index) {
                    final video = videoList[index];
                    return _buildVideoItem(context, video);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppConstants.routeAdminVideoForm,
          ).then((_) => setState(() {
                _videoStream = _firebaseService.getVideos();
              }));
        },
        backgroundColor: AppTheme.accentColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildVideoItem(BuildContext context, Video video) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  video.thumbnailUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: video.thumbnailUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppTheme.accentColor.withOpacity(0.2),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.accentColor.withOpacity(0.7),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            print("Error loading image: $error");
                            return Container(
                              color: AppTheme.accentColor.withOpacity(0.2),
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: AppTheme.accentColor,
                                  size: 48,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppTheme.accentColor.withOpacity(0.2),
                          child: const Center(
                            child: Icon(
                              Icons.video_library,
                              color: AppTheme.accentColor,
                              size: 48,
                            ),
                          ),
                        ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Info Video
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.judul,
                  style: AppTheme.subtitleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  video.deskripsi,
                  style: AppTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.link,
                      size: 16,
                      color: AppTheme.accentColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        video.youtubeUrl,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.accentColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Diperbarui: ${_formatDate(video.updatedAt)}',
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tombol Aksi
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        'Edit',
                        Icons.edit,
                        AppTheme.accentColor,
                        () {
                          Navigator.pushNamed(
                            context,
                            AppConstants.routeAdminVideoForm,
                            arguments: video,
                          ).then((_) => setState(() {
                                _videoStream = _firebaseService.getVideos();
                              }));
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        'Hapus',
                        Icons.delete,
                        AppTheme.errorColor,
                        () => _showDeleteConfirmation(context, video),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 18,
      ),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Video video) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus video "${video.judul}"? Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                _deleteVideo(video);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteVideo(Video video) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firebaseService.deleteVideo(video.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video berhasil dihapus'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        setState(() {
          _videoStream = _firebaseService.getVideos();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus video: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AppErrorWidget({
    Key? key,
    required this.message,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: AppTheme.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const EmptyStateWidget({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTheme.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTheme.bodyMedium.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}