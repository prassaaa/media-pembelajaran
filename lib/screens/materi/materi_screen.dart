import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pembelajaran_app/config/constants.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';
import 'package:pembelajaran_app/widgets/app_card.dart';
import 'package:pembelajaran_app/widgets/loading_widget.dart';

class MateriScreen extends StatefulWidget {
  const MateriScreen({Key? key}) : super(key: key);

  @override
  State<MateriScreen> createState() => _MateriScreenState();
}

class _MateriScreenState extends State<MateriScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Stream<List<Materi>> _materiStream;

  @override
  void initState() {
    super.initState();
    _materiStream = _firebaseService.getMateri();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materi Pembelajaran'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Materi>>(
        stream: _materiStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(
              message: 'Memuat daftar materi...',
            );
          }

          if (snapshot.hasError) {
            return AppErrorWidget(
              message: 'Terjadi kesalahan: ${snapshot.error}',
              onRetry: () {
                setState(() {
                  _materiStream = _firebaseService.getMateri();
                });
              },
            );
          }

          final List<Materi> materiList = snapshot.data ?? [];

          if (materiList.isEmpty) {
            return const EmptyStateWidget(
              title: 'Belum Ada Materi',
              subtitle: 'Materi pembelajaran belum tersedia saat ini.',
              icon: Icons.book,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Pilih Materi Pembelajaran',
                style: AppTheme.headingMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih materi pembelajaran yang ingin kamu pelajari',
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: materiList.length,
                itemBuilder: (context, index) {
                  final materi = materiList[index];
                  return _buildMateriCard(context, materi);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMateriCard(BuildContext context, Materi materi) {
    print('Building materi card with image URL: ${materi.gambarUrl}');
    return AppCard(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppConstants.routeMateriDetail,
          arguments: materi,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Materi
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 100,
              width: double.infinity,
              child: materi.gambarUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: materi.gambarUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppTheme.primaryColorLight.withOpacity(0.2),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryColor.withOpacity(0.7),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        print("Error loading materi image: $error");
                        return Container(
                          color: AppTheme.primaryColorLight.withOpacity(0.2),
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: AppTheme.primaryColorLight.withOpacity(0.2),
                      child: const Center(
                        child: Icon(
                          Icons.book,
                          size: 40,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
            ),
          ),
          
          // Info Materi
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    materi.judul,
                    style: AppTheme.subtitleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    materi.deskripsi,
                    style: AppTheme.bodySmall.copyWith(
                      fontSize: 10,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 10,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${materi.updatedAt.day}/${materi.updatedAt.month}/${materi.updatedAt.year}',
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.grey,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget tambahan jika belum tersedia di project
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
      child: SingleChildScrollView(
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.refresh, size: 18),
                      SizedBox(width: 8),
                      Text('Coba Lagi'),
                    ],
                  ),
                ),
              ),
            ],
          ),
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