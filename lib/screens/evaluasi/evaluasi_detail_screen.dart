import 'package:flutter/material.dart';
import 'package:pembelajaran_app/config/constants.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';
import 'package:pembelajaran_app/widgets/app_button.dart';
import 'package:pembelajaran_app/widgets/loading_widget.dart';

class EvaluasiDetailScreen extends StatefulWidget {
  const EvaluasiDetailScreen({Key? key}) : super(key: key);

  @override
  State<EvaluasiDetailScreen> createState() => _EvaluasiDetailScreenState();
}

class _EvaluasiDetailScreenState extends State<EvaluasiDetailScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  List<Soal> _soalList = [];
  bool _isStarted = false;
  int _currentSoalIndex = 0;
  List<int> _userAnswers = [];
  bool _showResult = false;
  int _correctCount = 0;

  @override
  Widget build(BuildContext context) {
    final Evaluasi evaluasi = ModalRoute.of(context)!.settings.arguments as Evaluasi;

    if (!_isStarted) {
      // Tampilkan informasi evaluasi dan tombol mulai
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Evaluasi'),
          centerTitle: true,
        ),
        body: _isLoading
            ? const LoadingWidget(message: 'Memuat data evaluasi...')
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.assignment,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    evaluasi.judul,
                                    style: AppTheme.subtitleLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${evaluasi.soalIds.length} Soal',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Deskripsi
                      Text(
                        'Deskripsi',
                        style: AppTheme.subtitleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        evaluasi.deskripsi,
                        style: AppTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),

                      // Instruksi
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.infoColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.infoColor.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.info,
                                  color: AppTheme.infoColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Instruksi',
                                  style: AppTheme.subtitleMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.infoColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '• Kerjakan soal sesuai dengan kemampuan kamu',
                              style: AppTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• Pilih salah satu jawaban yang kamu anggap benar',
                              style: AppTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• Hasil evaluasi akan muncul setelah kamu menyelesaikan semua soal',
                              style: AppTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),

                      // Tombol Mulai
                      AppButton(
                        text: 'Mulai Evaluasi',
                        icon: Icons.play_arrow,
                        onPressed: () => _startEvaluasi(evaluasi),
                        isFullWidth: true,
                      ),
                    ],
                  ),
                ),
              ),
      );
    } else if (_showResult) {
      // Tampilkan hasil evaluasi
      return Scaffold(
        appBar: AppBar(
          title: const Text('Hasil Evaluasi'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header Hasil
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _getResultColor(),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getResultIcon(),
                        color: Colors.white,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getResultTitle(),
                        style: AppTheme.headingMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kamu menjawab $_correctCount dari ${_soalList.length} soal dengan benar',
                        style: AppTheme.bodyLarge.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'Nilai: ${(_correctCount / _soalList.length * 100).toStringAsFixed(0)}',
                          style: AppTheme.headingSmall.copyWith(
                            color: _getResultColor(),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Detail Jawaban
                Expanded(
                  child: ListView.builder(
                    itemCount: _soalList.length,
                    itemBuilder: (context, index) {
                      final soal = _soalList[index];
                      final isCorrect =
                          _userAnswers[index] == soal.jawabanBenar;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isCorrect
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isCorrect
                                          ? AppTheme.successColor
                                          : AppTheme.errorColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isCorrect ? Icons.check : Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Soal ${index + 1}',
                                      style: AppTheme.subtitleMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                soal.pertanyaan,
                                style: AppTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Jawaban kamu: ${soal.opsi[_userAnswers[index]]}',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: isCorrect
                                      ? AppTheme.successColor
                                      : AppTheme.errorColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (!isCorrect) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Jawaban benar: ${soal.opsi[soal.jawabanBenar]}',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.successColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Tombol Selesai
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Kembali ke Daftar',
                        type: ButtonType.outlined,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppButton(
                        text: 'Lihat Detail Hasil',
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppConstants.routeHasil,
                            arguments: {
                              'evaluasi': evaluasi,
                              'soalList': _soalList,
                              'userAnswers': _userAnswers,
                              'correctCount': _correctCount,
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Tampilkan soal evaluasi
      final currentSoal = _soalList[_currentSoalIndex];
      return Scaffold(
        appBar: AppBar(
          title: Text('Soal ${_currentSoalIndex + 1} dari ${_soalList.length}'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Bar
                LinearProgressIndicator(
                  value: (_currentSoalIndex + 1) / _soalList.length,
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 10,
                ),
                const SizedBox(height: 24),

                // Pertanyaan
                Text(
                  currentSoal.pertanyaan,
                  style: AppTheme.subtitleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Gambar (jika ada)
                if (currentSoal.gambarUrl != null &&
                    currentSoal.gambarUrl!.isNotEmpty) ...[
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.withOpacity(0.1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        currentSoal.gambarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 48,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Pilihan Jawaban
                Expanded(
                  child: ListView.builder(
                    itemCount: currentSoal.opsi.length,
                    itemBuilder: (context, index) {
                      final isSelected = _userAnswers.length > _currentSoalIndex &&
                          _userAnswers[_currentSoalIndex] == index;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (_userAnswers.length <= _currentSoalIndex) {
                                _userAnswers.add(index);
                              } else {
                                _userAnswers[_currentSoalIndex] = index;
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.grey.withOpacity(0.3),
                                width: isSelected ? 2 : 1,
                              ),
                              color: isSelected
                                  ? AppTheme.primaryColor.withOpacity(0.1)
                                  : Colors.white,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? AppTheme.primaryColor
                                        : Colors.grey.withOpacity(0.1),
                                    border: isSelected
                                        ? null
                                        : Border.all(
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                  ),
                                  child: Center(
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 18,
                                          )
                                        : Text(
                                            String.fromCharCode(
                                                'A'.codeUnitAt(0) + index),
                                            style: AppTheme.subtitleMedium,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    currentSoal.opsi[index],
                                    style: AppTheme.bodyMedium.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Tombol Navigasi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tombol Kembali
                    if (_currentSoalIndex > 0)
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentSoalIndex--;
                          });
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Sebelumnya'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(140, 48),
                        ),
                      )
                    else
                      const SizedBox(width: 140),

                    // Tombol Selanjutnya/Selesai
                    ElevatedButton.icon(
                      onPressed: _userAnswers.length > _currentSoalIndex
                          ? () {
                              if (_currentSoalIndex == _soalList.length - 1) {
                                // Hitung jawaban benar
                                _calculateResult();
                              } else {
                                setState(() {
                                  _currentSoalIndex++;
                                });
                              }
                            }
                          : null,
                      icon: Icon(_currentSoalIndex == _soalList.length - 1
                          ? Icons.check
                          : Icons.arrow_forward),
                      label: Text(_currentSoalIndex == _soalList.length - 1
                          ? 'Selesai'
                          : 'Selanjutnya'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(140, 48),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<void> _startEvaluasi(Evaluasi evaluasi) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final soalList = await _firebaseService.getSoalFromEvaluasi(evaluasi.id);
      setState(() {
        _soalList = soalList;
        _isLoading = false;
        _isStarted = true;
        _currentSoalIndex = 0;
        _userAnswers = [];
        _showResult = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat soal: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _calculateResult() {
    int correctCount = 0;
    for (int i = 0; i < _soalList.length; i++) {
      if (_userAnswers[i] == _soalList[i].jawabanBenar) {
        correctCount++;
      }
    }

    setState(() {
      _correctCount = correctCount;
      _showResult = true;
    });
  }

  Color _getResultColor() {
    final score = _correctCount / _soalList.length;
    if (score >= 0.8) {
      return AppTheme.successColor;
    } else if (score >= 0.6) {
      return AppTheme.warningColor;
    } else {
      return AppTheme.errorColor;
    }
  }

  IconData _getResultIcon() {
    final score = _correctCount / _soalList.length;
    if (score >= 0.8) {
      return Icons.emoji_events;
    } else if (score >= 0.6) {
      return Icons.thumb_up;
    } else {
      return Icons.sentiment_dissatisfied;
    }
  }

  String _getResultTitle() {
    final score = _correctCount / _soalList.length;
    if (score >= 0.8) {
      return 'Sangat Baik!';
    } else if (score >= 0.6) {
      return 'Cukup Baik';
    } else {
      return 'Perlu Belajar Lagi';
    }
  }
}