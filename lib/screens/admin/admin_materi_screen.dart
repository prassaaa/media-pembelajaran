import 'package:flutter/material.dart';
import 'package:pembelajaran_app/config/constants.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';
import 'package:pembelajaran_app/widgets/loading_widget.dart';

class AdminMateriScreen extends StatefulWidget {
  const AdminMateriScreen({Key? key}) : super(key: key);

  @override
  State<AdminMateriScreen> createState() => _AdminMateriScreenState();
}

class _AdminMateriScreenState extends State<AdminMateriScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Materi'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppConstants.routeAdminMateriForm,
              ).then((_) => setState(() {}));
            },
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Materi',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Memuat data materi...')
          : StreamBuilder<List<Materi>>(
              stream: _firebaseService.getMateri(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget(message: 'Memuat data materi...');
                }

                if (snapshot.hasError) {
                  return AppErrorWidget(
                    message: 'Terjadi kesalahan: ${snapshot.error}',
                    onRetry: () {
                      setState(() {});
                    },
                  );
                }

                final List<Materi> materiList = snapshot.data ?? [];

                if (materiList.isEmpty) {
                  return const EmptyStateWidget(
                    title: 'Belum Ada Materi',
                    subtitle:
                        'Tambahkan materi pembelajaran untuk ditampilkan pada aplikasi.',
                    icon: Icons.book,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: materiList.length,
                  itemBuilder: (context, index) {
                    final materi = materiList[index];
                    return _buildMateriItem(context, materi);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppConstants.routeAdminMateriForm,
          ).then((_) => setState(() {}));
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMateriItem(BuildContext context, Materi materi) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Materi
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: materi.gambarUrl.isNotEmpty
                  ? Image.network(
                      materi.gambarUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: AppTheme.primaryColorLight.withOpacity(0.2),
                          child: const Icon(
                            Icons.image_not_supported,
                            color: AppTheme.primaryColorLight,
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: AppTheme.primaryColorLight.withOpacity(0.2),
                      child: const Icon(
                        Icons.book,
                        color: AppTheme.primaryColorLight,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            // Info Materi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    materi.judul,
                    style: AppTheme.subtitleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    materi.deskripsi,
                    style: AppTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Diperbarui: ${_formatDate(materi.updatedAt)}',
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Tombol Aksi
                  Row(
                    children: [
                      _buildActionButton(
                        'Edit',
                        Icons.edit,
                        AppTheme.primaryColor,
                        () {
                          Navigator.pushNamed(
                            context,
                            AppConstants.routeAdminMateriForm,
                            arguments: materi,
                          ).then((_) => setState(() {}));
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        'Hapus',
                        Icons.delete,
                        AppTheme.errorColor,
                        () => _showDeleteConfirmation(context, materi),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Materi materi) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus materi "${materi.judul}"? Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                _deleteMateri(materi);
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

  Future<void> _deleteMateri(Materi materi) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firebaseService.deleteMateri(materi.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Materi berhasil dihapus'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus materi: ${e.toString()}'),
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