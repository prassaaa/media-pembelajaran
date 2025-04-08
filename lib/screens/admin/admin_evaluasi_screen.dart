import 'package:flutter/material.dart';
import 'package:pembelajaran_app/config/constants.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';
import 'package:pembelajaran_app/widgets/loading_widget.dart';

class AdminEvaluasiScreen extends StatefulWidget {
  const AdminEvaluasiScreen({Key? key}) : super(key: key);

  @override
  State<AdminEvaluasiScreen> createState() => _AdminEvaluasiScreenState();
}

class _AdminEvaluasiScreenState extends State<AdminEvaluasiScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Evaluasi'),
        centerTitle: true,
        backgroundColor: AppTheme.successColor,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppConstants.routeAdminEvaluasiForm,
              ).then((_) => setState(() {}));
            },
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Evaluasi',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Memuat data evaluasi...')
          : StreamBuilder<List<Evaluasi>>(
              stream: _firebaseService.getEvaluasi(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget(
                      message: 'Memuat data evaluasi...');
                }

                if (snapshot.hasError) {
                  return AppErrorWidget(
                    message: 'Terjadi kesalahan: ${snapshot.error}',
                    onRetry: () {
                      setState(() {});
                    },
                  );
                }

                final List<Evaluasi> evaluasiList = snapshot.data ?? [];

                if (evaluasiList.isEmpty) {
                  return const EmptyStateWidget(
                    title: 'Belum Ada Evaluasi',
                    subtitle:
                        'Tambahkan evaluasi pembelajaran untuk ditampilkan pada aplikasi.',
                    icon: Icons.assignment,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: evaluasiList.length,
                  itemBuilder: (context, index) {
                    final evaluasi = evaluasiList[index];
                    return _buildEvaluasiItem(context, evaluasi);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppConstants.routeAdminEvaluasiForm,
          ).then((_) => setState(() {}));
        },
        backgroundColor: AppTheme.successColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEvaluasiItem(BuildContext context, Evaluasi evaluasi) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.assignment,
                    color: AppTheme.successColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        evaluasi.judul,
                        style: AppTheme.subtitleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        evaluasi.deskripsi,
                        style: AppTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Info Tambahan
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(
                    'Jumlah Soal',
                    '${evaluasi.soalIds.length}',
                    Icons.question_answer,
                  ),
                  _buildInfoItem(
                    'Dibuat',
                    _formatDate(evaluasi.createdAt),
                    Icons.calendar_today,
                  ),
                  _buildInfoItem(
                    'Diperbarui',
                    _formatDate(evaluasi.updatedAt),
                    Icons.update,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppConstants.routeAdminEvaluasiForm,
                        arguments: evaluasi,
                      ).then((_) => setState(() {}));
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.successColor,
                      side: const BorderSide(color: AppTheme.successColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showDeleteConfirmation(context, evaluasi),
                    icon: const Icon(Icons.delete),
                    label: const Text('Hapus'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, Evaluasi evaluasi) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus evaluasi "${evaluasi.judul}"? Tindakan ini juga akan menghapus semua soal terkait dan tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                _deleteEvaluasi(evaluasi);
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

  Future<void> _deleteEvaluasi(Evaluasi evaluasi) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firebaseService.deleteEvaluasi(evaluasi.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evaluasi berhasil dihapus'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus evaluasi: ${e.toString()}'),
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