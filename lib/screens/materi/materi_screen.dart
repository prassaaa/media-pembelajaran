import 'package:flutter/material.dart';
import 'package:pembelajaran_app/config/constants.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';
import 'package:pembelajaran_app/widgets/app_card.dart';
import 'package:pembelajaran_app/widgets/loading_widget.dart';

class MateriScreen extends StatelessWidget {
  const MateriScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materi Pembelajaran'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Materi>>(
        stream: firebaseService.getMateri(),
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
                // Refresh the stream
                setState(() {});
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
                  childAspectRatio: 0.7,
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
    return ImageCard(
      title: materi.judul,
      subtitle: materi.deskripsi,
      imageUrl: materi.gambarUrl.isNotEmpty
          ? materi.gambarUrl
          : 'assets/images/default_materi.png',
      isNetworkImage: materi.gambarUrl.isNotEmpty,
      onTap: () {
        Navigator.pushNamed(
          context,
          AppConstants.routeMateriDetail,
          arguments: materi,
        );
      },
      footer: Row(
        children: [
          const Icon(
            Icons.calendar_today,
            size: 12,
            color: Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            '${materi.updatedAt.day}/${materi.updatedAt.month}/${materi.updatedAt.year}',
            style: AppTheme.bodySmall.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk memaksa refresh UI
  void setState(VoidCallback fn) {
    fn();
  }
}