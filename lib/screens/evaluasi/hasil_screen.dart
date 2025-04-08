import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/widgets/app_button.dart';
import 'package:intl/intl.dart';

class HasilScreen extends StatelessWidget {
  const HasilScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final Evaluasi evaluasi = args['evaluasi'] as Evaluasi;
    final List<Soal> soalList = args['soalList'] as List<Soal>;
    final List<int> userAnswers = args['userAnswers'] as List<int>;
    final int correctCount = args['correctCount'] as int;

    final double score = correctCount / soalList.length * 100;
    final String formattedScore = score.toStringAsFixed(0);
    final String formattedDate = DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Hasil Evaluasi'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header Hasil
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Info Evaluasi
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.assignment,
                            color: AppTheme.primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
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
                              const SizedBox(height: 4),
                              Text(
                                'Dikerjakan pada: $formattedDate',
                                style: AppTheme.bodySmall.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // Hasil
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildResultItem(
                          'Nilai',
                          formattedScore,
                          Icons.emoji_events,
                          _getResultColor(score),
                        ),
                        _buildResultItem(
                          'Benar',
                          '$correctCount/${soalList.length}',
                          Icons.check_circle,
                          AppTheme.successColor,
                        ),
                        _buildResultItem(
                          'Salah',
                          '${soalList.length - correctCount}/${soalList.length}',
                          Icons.cancel,
                          AppTheme.errorColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Detail Jawaban
            Text(
              'Detail Jawaban',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: soalList.length,
              itemBuilder: (context, index) {
                final soal = soalList[index];
                final userAnswer = userAnswers[index];
                final isCorrect = userAnswer == soal.jawabanBenar;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCorrect
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      soal.pertanyaan,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      isCorrect ? 'Jawaban benar' : 'Jawaban salah',
                      style: AppTheme.bodySmall.copyWith(
                        color: isCorrect
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                      ),
                    ),
                    trailing: Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gambar jika ada
                            if (soal.gambarUrl != null &&
                                soal.gambarUrl!.isNotEmpty) ...[
                              Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey.withOpacity(0.1),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    soal.gambarUrl!,
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

                            // Pertanyaan
                            Text(
                              soal.pertanyaan,
                              style: AppTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),

                            // Semua opsi
                            ...List.generate(
                              soal.opsi.length,
                              (i) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: _getOptionColor(
                                      i,
                                      userAnswer,
                                      soal.jawabanBenar,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        child: Center(
                                          child: Text(
                                            String.fromCharCode(
                                                'A'.codeUnitAt(0) + i),
                                            style:
                                                AppTheme.bodyMedium.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: _getOptionColor(
                                                i,
                                                userAnswer,
                                                soal.jawabanBenar,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          soal.opsi[i],
                                          style: AppTheme.bodyMedium.copyWith(
                                            color: Colors.white,
                                            fontWeight: i == userAnswer ||
                                                    i == soal.jawabanBenar
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      if (i == userAnswer && !isCorrect)
                                        const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        )
                                      else if (i == soal.jawabanBenar)
                                        const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Tombol Action
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Kembali',
                    icon: Icons.arrow_back,
                    type: ButtonType.outlined,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppButton(
                    text: 'Bagikan Hasil',
                    icon: Icons.share,
                    onPressed: () {
                      _shareResult(
                        context,
                        evaluasi,
                        correctCount,
                        soalList.length,
                        score,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.subtitleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getResultColor(double score) {
    if (score >= 80) {
      return AppTheme.successColor;
    } else if (score >= 60) {
      return AppTheme.warningColor;
    } else {
      return AppTheme.errorColor;
    }
  }

  Color _getOptionColor(int optionIndex, int userAnswerIndex, int correctIndex) {
    if (optionIndex == correctIndex) {
      return AppTheme.successColor;
    } else if (optionIndex == userAnswerIndex && userAnswerIndex != correctIndex) {
      return AppTheme.errorColor;
    } else {
      return Colors.grey;
    }
  }

  void _shareResult(
    BuildContext context,
    Evaluasi evaluasi,
    int correctCount,
    int totalCount,
    double score,
  ) async {
    final String resultText = 'Hasil Evaluasi: ${evaluasi.judul}\n'
        'Skor: ${score.toStringAsFixed(0)}\n'
        'Jawaban Benar: $correctCount dari $totalCount\n'
        'Tanggal: ${DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now())}';

    try {
      await Clipboard.setData(ClipboardData(text: resultText));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hasil evaluasi telah disalin ke clipboard'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyalin hasil: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}