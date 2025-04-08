// lib/services/cpanel_service.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CPanelService {
  // URL endpoint pada server cPanel Anda
  final String uploadUrl = 'https://pusakakediri.com/flutter_uploads/upload.php';

  Future<String?> uploadImage(File imageFile) async {
    try {
      // Membuat request multipart
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      
      // Menambahkan file gambar ke request
      request.files.add(await http.MultipartFile.fromPath(
        'image', // nama parameter yang diharapkan oleh script PHP
        imageFile.path,
      ));
      
      print('Sending image upload request to cPanel...');
      
      // Mengirim request dan menunggu respons
      var response = await request.send();
      
      // Membaca respons
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);
      
      // Memeriksa status upload
      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        print('Image uploaded successfully to cPanel');
        // Mengembalikan URL gambar yang diupload
        return jsonResponse['url'];
      } else {
        print('Failed to upload image to cPanel: ${jsonResponse['message']}');
        return null;
      }
    } catch (e) {
      print('Error uploading image to cPanel: $e');
      return null;
    }
  }
}