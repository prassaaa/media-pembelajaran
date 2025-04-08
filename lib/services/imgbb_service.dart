import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class ImgBBService {
  final String apiKey = "06b78a5de23b8e1dfc3ff24ad8d7d2b0"; // Ganti dengan API key Anda
  final Dio _dio = Dio();
  final ImagePicker _picker = ImagePicker();

  // Mengambil gambar dari galeri
  Future<File?> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Kompresi untuk menghemat bandwidth
    );
    
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Upload gambar ke ImgBB
  Future<String?> uploadImage(File imageFile) async {
    try {
      // Membuat form data
      FormData formData = FormData.fromMap({
        'key': apiKey,
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'upload.jpg',
        ),
      });

      // Upload gambar
      Response response = await _dio.post(
        'https://api.imgbb.com/1/upload',
        data: formData,
      );

      // Periksa response
      if (response.statusCode == 200 && response.data['success'] == true) {
        // Mengembalikan URL gambar
        return response.data['data']['url'];
      } else {
        print('Error uploading image: ${response.data}');
        return null;
      }
    } catch (e) {
      print('Exception during image upload: $e');
      return null;
    }
  }
}