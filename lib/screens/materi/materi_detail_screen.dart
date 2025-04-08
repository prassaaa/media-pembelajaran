import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';

class MateriDetailScreen extends StatelessWidget {
  const MateriDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Materi materi = ModalRoute.of(context)!.settings.arguments as Materi;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar dengan gambar materi
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                materi.judul,
                style: AppTheme.subtitleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: materi.gambarUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: materi.gambarUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppTheme.primaryColorLight.withOpacity(0.3),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppTheme.primaryColorLight.withOpacity(0.3),
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: AppTheme.primaryColor,
                      child: const Center(
                        child: Icon(
                          Icons.book,
                          color: Colors.white,
                          size: 64,
                        ),
                      ),
                    ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Materi
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
                          'Deskripsi Materi',
                          style: AppTheme.subtitleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          materi.deskripsi,
                          style: AppTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Terakhir diperbarui: ${_formatDate(materi.updatedAt)}',
                              style: AppTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Konten Materi
                  Text(
                    'Konten Materi',
                    style: AppTheme.headingSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildMateriContent(materi.konten),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMateriContent(String content) {
    // Ubah format konten jadi widget yang sesuai
    // Untuk saat ini tampilkan sebagai plain text
    return Text(
      content,
      style: AppTheme.bodyMedium,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}