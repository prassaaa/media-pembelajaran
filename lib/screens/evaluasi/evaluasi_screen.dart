import 'package:flutter/material.dart';
import 'package:pembelajaran_app/config/constants.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';
import 'package:pembelajaran_app/widgets/app_card.dart';
import 'package:pembelajaran_app/widgets/loading_widget.dart';

class EvaluasiScreen extends StatelessWidget {
  const EvaluasiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluasi Pembelajaran'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Evaluasi>>(
        stream: firebaseService.getEvaluasi(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(
              message: 'Memuat daftar evaluasi...',
            );
          }

          if (snapshot.hasError) {
            return AppErrorWidget(
              message: 'Terjadi kesalahan: ${snapshot.error}',
              onRetry: () {
                // Refresh the stream
                setState(() {});
              },
            );
          }

          final List<Evaluasi> evaluasiList = snapshot.data ?? [];

          if (evaluasiList.isEmpty) {
            return const EmptyStateWidget(
              title: 'Belum Ada Evaluasi',
              subtitle: 'Evaluasi pembelajaran belum tersedia saat ini.',
              icon: Icons.assignment,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Pilih Evaluasi Pembelajaran',
                style: AppTheme.headingMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih evaluasi pembelajaran untuk menguji pemahaman kamu',
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: evaluasiList.length,
                itemBuilder: (context, index) {
                  final evaluasi = evaluasiList[index];
                  return _buildEvaluasiCard(context, evaluasi);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEvaluasiCard(BuildContext context, Evaluasi evaluasi) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AppCard(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppConstants.routeEvaluasiDetail,
            arguments: evaluasi,
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ikon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.assignment,
                color: AppTheme.successColor,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            // Info Evaluasi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evaluasi.judul,
                    style: AppTheme.subtitleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    evaluasi.deskripsi,
                    style: AppTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoChip(
                        '${evaluasi.soalIds.length} Soal',
                        Icons.quiz,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        'Diperbarui ${_formatDate(evaluasi.updatedAt)}',
                        Icons.update,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColorLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppTheme.primaryColorDark,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.primaryColorDark,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Fungsi untuk memaksa refresh UI
  void setState(VoidCallback fn) {
    fn();
  }
}