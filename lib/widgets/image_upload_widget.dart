import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/services/imgbb_service.dart';

class ImageUploadWidget extends StatefulWidget {
  final String? initialImageUrl;
  final Function(File) onImageSelected;
  final double height;
  final String label;

  const ImageUploadWidget({
    Key? key,
    this.initialImageUrl,
    required this.onImageSelected,
    this.height = 200,
    this.label = 'Gambar',
  }) : super(key: key);

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  final ImgBBService _imgBBService = ImgBBService();
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final File? imageFile = await _imgBBService.pickImage();
      if (imageFile != null) {
        setState(() {
          _selectedImage = imageFile;
        });
        widget.onImageSelected(imageFile);
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTheme.subtitleMedium,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: widget.height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildImageContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildImageContent() {
    if (_selectedImage != null) {
      // Menampilkan gambar yang baru dipilih
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              _selectedImage!,
              fit: BoxFit.cover,
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  onPressed: _pickImage,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty) {
      // Menampilkan gambar dari URL yang sudah ada
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.initialImageUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(height: 8),
                      Text(
                        'Gagal memuat gambar',
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  onPressed: _pickImage,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Menampilkan placeholder
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              'Ketuk untuk memilih gambar',
              style: AppTheme.bodyMedium.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
  }
}