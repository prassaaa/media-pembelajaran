import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';
import 'package:pembelajaran_app/widgets/app_button.dart';
import 'package:file_picker/file_picker.dart';

class AdminSoalForm extends StatefulWidget {
  const AdminSoalForm({Key? key}) : super(key: key);

  @override
  State<AdminSoalForm> createState() => _AdminSoalFormState();
}

class _AdminSoalFormState extends State<AdminSoalForm> {
  final FirebaseService _firebaseService = FirebaseService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _pertanyaanController = TextEditingController();
  final List<TextEditingController> _opsiControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  bool _isEditMode = false;
  bool _isLoading = false;
  String _soalId = '';
  int _jawabanBenar = 0;
  File? _gambarFile;
  String? _gambarUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Soal) {
      // Edit mode
      _isEditMode = true;
      _soalId = args.id;
      _pertanyaanController.text = args.pertanyaan;
      _jawabanBenar = args.jawabanBenar;
      _gambarUrl = args.gambarUrl;

      // Fill opsi controllers
      for (int i = 0; i < args.opsi.length && i < _opsiControllers.length; i++) {
        _opsiControllers[i].text = args.opsi[i];
      }
    }
  }

  @override
  void dispose() {
    _pertanyaanController.dispose();
    for (var controller in _opsiControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _gambarFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error memilih gambar: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _saveSoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final pertanyaan = _pertanyaanController.text;
      final List<String> opsi = _opsiControllers.map((c) => c.text).toList();

      if (_isEditMode) {
        // Update soal
        final Soal soal = Soal(
          id: _soalId,
          pertanyaan: pertanyaan,
          opsi: opsi,
          jawabanBenar: _jawabanBenar,
          gambarUrl: _gambarUrl,
          createdAt: DateTime.now(), // Will be ignored on update
          updatedAt: DateTime.now(),
        );

        await _firebaseService.updateSoal(soal, _gambarFile);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Soal berhasil diperbarui'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.pop(context, soal);
        }
      } else {
        // Add new soal
        final Soal soal = Soal(
          id: '',
          pertanyaan: pertanyaan,
          opsi: opsi,
          jawabanBenar: _jawabanBenar,
          gambarUrl: _gambarUrl,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final String soalId = await _firebaseService.addSoal(soal, _gambarFile);
        final Soal updatedSoal = Soal(
          id: soalId,
          pertanyaan: pertanyaan,
          opsi: opsi,
          jawabanBenar: _jawabanBenar,
          gambarUrl: _gambarUrl,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Soal berhasil ditambahkan'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.pop(context, updatedSoal);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Gagal ${_isEditMode ? 'memperbarui' : 'menambahkan'} soal: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Soal' : 'Tambah Soal'),
        centerTitle: true,
        backgroundColor: AppTheme.successColor,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.successColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isEditMode ? Icons.edit_note : Icons.quiz,
                            color: AppTheme.successColor,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _isEditMode
                                  ? 'Edit soal evaluasi'
                                  : 'Tambahkan soal baru untuk evaluasi',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.successColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Pertanyaan
                    Text(
                      'Pertanyaan',
                      style: AppTheme.subtitleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _pertanyaanController,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan pertanyaan',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pertanyaan tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Gambar Soal
                    Text(
                      'Gambar Soal (Opsional)',
                      style: AppTheme.subtitleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: _gambarFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _gambarFile!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : _gambarUrl != null && _gambarUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    _gambarUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 64,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.image,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Belum ada gambar',
                                        style: AppTheme.bodyMedium.copyWith(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Pilih Gambar',
                            icon: Icons.image,
                            type: ButtonType.outlined,
                            onPressed: _pickImage,
                          ),
                        ),
                        if (_gambarFile != null || (_gambarUrl != null && _gambarUrl!.isNotEmpty)) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppButton(
                              text: 'Hapus Gambar',
                              icon: Icons.delete,
                              type: ButtonType.outlined,
                              onPressed: () {
                                setState(() {
                                  _gambarFile = null;
                                  _gambarUrl = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Opsi Jawaban
                    Text(
                      'Opsi Jawaban',
                      style: AppTheme.subtitleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _opsiControllers.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Radio button
                              Radio<int>(
                                value: index,
                                groupValue: _jawabanBenar,
                                activeColor: AppTheme.successColor,
                                onChanged: (value) {
                                  setState(() {
                                    _jawabanBenar = value!;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              // Opsi field
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Opsi ${String.fromCharCode('A'.codeUnitAt(0) + index)}',
                                      style: AppTheme.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    TextFormField(
                                      controller: _opsiControllers[index],
                                      decoration: InputDecoration(
                                        hintText: 'Masukkan opsi ${String.fromCharCode('A'.codeUnitAt(0) + index)}',
                                        border: const OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Opsi tidak boleh kosong';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Info Jawaban Benar
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppTheme.successColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Jawaban benar: ${String.fromCharCode('A'.codeUnitAt(0) + _jawabanBenar)} - ${_opsiControllers[_jawabanBenar].text.isNotEmpty ? _opsiControllers[_jawabanBenar].text : "Belum diisi"}',
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Tombol Simpan
                    AppButton(
                      text: _isEditMode ? 'Perbarui Soal' : 'Simpan Soal',
                      icon: _isEditMode ? Icons.save : Icons.check,
                      onPressed: _saveSoal,
                      isLoading: _isLoading,
                      isFullWidth: true,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}