import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'dart:io';
import 'package:pembelajaran_app/services/cpanel_service.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CPanelService _cPanelService = CPanelService();

  // Collection references
  final CollectionReference _materiCollection = FirebaseFirestore.instance.collection('materi');
  final CollectionReference _videoCollection = FirebaseFirestore.instance.collection('video');
  final CollectionReference _evaluasiCollection = FirebaseFirestore.instance.collection('evaluasi');
  final CollectionReference _soalCollection = FirebaseFirestore.instance.collection('soal');

  // MATERI OPERATIONS
  // Get semua materi
  Stream<List<Materi>> getMateri() {
    return _materiCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Materi.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Get materi by ID
  Future<Materi> getMateriById(String id) async {
    DocumentSnapshot doc = await _materiCollection.doc(id).get();
    return Materi.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  // Tambah materi baru
  Future<void> addMateri(Materi materi, File? gambar) async {
    String gambarUrl = materi.gambarUrl;

    // Upload gambar jika ada
    if (gambar != null) {
      print('Uploading materi image to cPanel...');
      String? uploadedUrl = await _cPanelService.uploadImage(gambar);
      if (uploadedUrl != null) {
        print('Materi image uploaded successfully, URL: $uploadedUrl');
        gambarUrl = uploadedUrl;
      } else {
        print('Failed to upload materi image to cPanel');
      }
    }

    // Create materi with timestamp and image URL
    print('Saving materi with image URL: $gambarUrl');
    await _materiCollection.add({
      'judul': materi.judul,
      'deskripsi': materi.deskripsi,
      'gambarUrl': gambarUrl,
      'konten': materi.konten,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update materi
  Future<void> updateMateri(Materi materi, File? gambar) async {
    String gambarUrl = materi.gambarUrl;

    // Upload gambar baru jika ada
    if (gambar != null) {
      print('Updating materi image on cPanel...');
      String? uploadedUrl = await _cPanelService.uploadImage(gambar);
      if (uploadedUrl != null) {
        print('Materi image updated successfully, URL: $uploadedUrl');
        gambarUrl = uploadedUrl;
      } else {
        print('Failed to update materi image on cPanel');
      }
    }

    print('Updating materi with image URL: $gambarUrl');
    await _materiCollection.doc(materi.id).update({
      'judul': materi.judul,
      'deskripsi': materi.deskripsi,
      'gambarUrl': gambarUrl,
      'konten': materi.konten,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Hapus materi
  Future<void> deleteMateri(String id) async {
    await _materiCollection.doc(id).delete();
  }

  // VIDEO OPERATIONS
  // Get semua video
  Stream<List<Video>> getVideos() {
    return _videoCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Video.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Get video by ID
  Future<Video> getVideoById(String id) async {
    DocumentSnapshot doc = await _videoCollection.doc(id).get();
    return Video.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  // Tambah video baru
  Future<void> addVideo(Video video, File? thumbnail) async {
    String thumbnailUrl = video.thumbnailUrl;

    // Upload thumbnail jika ada
    if (thumbnail != null) {
      String? uploadedUrl = await _cPanelService.uploadImage(thumbnail);
      if (uploadedUrl != null) {
        thumbnailUrl = uploadedUrl;
      }
    }

    await _videoCollection.add({
      'judul': video.judul,
      'deskripsi': video.deskripsi,
      'youtubeUrl': video.youtubeUrl,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update video
  Future<void> updateVideo(Video video, File? thumbnail) async {
    String thumbnailUrl = video.thumbnailUrl;

    // Upload thumbnail baru jika ada
    if (thumbnail != null) {
      String? uploadedUrl = await _cPanelService.uploadImage(thumbnail);
      if (uploadedUrl != null) {
        thumbnailUrl = uploadedUrl;
      }
    }

    await _videoCollection.doc(video.id).update({
      'judul': video.judul,
      'deskripsi': video.deskripsi,
      'youtubeUrl': video.youtubeUrl,
      'thumbnailUrl': thumbnailUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Hapus video
  Future<void> deleteVideo(String id) async {
    await _videoCollection.doc(id).delete();
  }

  // EVALUASI OPERATIONS
  // Get semua evaluasi
  Stream<List<Evaluasi>> getEvaluasi() {
    return _evaluasiCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Evaluasi.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Get evaluasi by ID
  Future<Evaluasi> getEvaluasiById(String id) async {
    print("Getting evaluasi by ID: $id");
    DocumentSnapshot doc = await _evaluasiCollection.doc(id).get();
    if (!doc.exists) {
      print("Evaluasi with ID $id does not exist");
      throw Exception("Evaluasi tidak ditemukan");
    }
    
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    print("Raw evaluasi data: $data");
    
    Evaluasi evaluasi = Evaluasi.fromMap(data, doc.id);
    print("Evaluasi loaded: ${evaluasi.judul}, soalIds: ${evaluasi.soalIds}");
    return evaluasi;
  }

  // Tambah evaluasi baru
  Future<String> addEvaluasi(Evaluasi evaluasi) async {
    print("Adding new evaluasi: ${evaluasi.judul}");
    print("with soalIds: ${evaluasi.soalIds}");
    
    DocumentReference docRef = await _evaluasiCollection.add({
      'judul': evaluasi.judul,
      'deskripsi': evaluasi.deskripsi,
      'soalIds': evaluasi.soalIds,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    print("New evaluasi created with ID: ${docRef.id}");
    
    // Verify the data was saved correctly
    DocumentSnapshot verifyDoc = await docRef.get();
    Map<String, dynamic> data = verifyDoc.data() as Map<String, dynamic>;
    List<String> savedSoalIds = List<String>.from(data['soalIds'] ?? []);
    print("Verified saved soalIds: $savedSoalIds");
    
    return docRef.id;
  }

  // Update evaluasi
  Future<void> updateEvaluasi(Evaluasi evaluasi) async {
    print("Updating evaluasi with ID: ${evaluasi.id}");
    print("soalIds to update: ${evaluasi.soalIds}");
    
    try {
      await _evaluasiCollection.doc(evaluasi.id).update({
        'judul': evaluasi.judul,
        'deskripsi': evaluasi.deskripsi,
        'soalIds': evaluasi.soalIds,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print("Evaluasi updated successfully");
      
      // Verify that the update was successful
      DocumentSnapshot updatedDoc = await _evaluasiCollection.doc(evaluasi.id).get();
      Map<String, dynamic> data = updatedDoc.data() as Map<String, dynamic>;
      List<String> updatedSoalIds = List<String>.from(data['soalIds'] ?? []);
      print("Verified soalIds after update: $updatedSoalIds");
    } catch (e) {
      print("Error updating evaluasi: $e");
      throw e;
    }
  }

  // Hapus evaluasi
  Future<void> deleteEvaluasi(String id) async {
    print("Deleting evaluasi with ID: $id");
    
    // Get evaluasi untuk mendapatkan soalIds
    Evaluasi evaluasi = await getEvaluasiById(id);
    print("Found evaluasi with ${evaluasi.soalIds.length} soal to delete");
    
    // Hapus semua soal yang terkait
    for (String soalId in evaluasi.soalIds) {
      print("Deleting related soal: $soalId");
      try {
        await _soalCollection.doc(soalId).delete();
        print("Soal $soalId deleted successfully");
      } catch (e) {
        print("Error deleting soal $soalId: $e");
        // Continue with other deletions even if one fails
      }
    }
    
    // Hapus evaluasi
    await _evaluasiCollection.doc(id).delete();
    print("Evaluasi $id deleted successfully");
  }

  // SOAL OPERATIONS
  // Get soal by ID
  Future<Soal> getSoalById(String id) async {
    print("Getting soal by ID: $id");
    DocumentSnapshot doc = await _soalCollection.doc(id).get();
    
    if (!doc.exists) {
      print("Soal with ID $id does not exist");
      throw Exception("Soal tidak ditemukan");
    }
    
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    print("Raw soal data: $data");
    
    Soal soal = Soal.fromMap(data, doc.id);
    print("Soal loaded: ${soal.pertanyaan}");
    return soal;
  }

  // Get soal dari evaluasi
  Future<List<Soal>> getSoalFromEvaluasi(String evaluasiId) async {
    print("Getting soal from evaluasi with ID: $evaluasiId");
    
    Evaluasi evaluasi = await getEvaluasiById(evaluasiId);
    print("Jumlah soalIds dalam evaluasi: ${evaluasi.soalIds.length}");
    print("soalIds: ${evaluasi.soalIds}");
    
    List<Soal> soalList = [];
    
    for (String soalId in evaluasi.soalIds) {
      try {
        print("Loading soal with ID: $soalId");
        Soal soal = await getSoalById(soalId);
        soalList.add(soal);
        print("Added soal to list: ${soal.pertanyaan}");
      } catch (e) {
        print("Error loading soal $soalId: $e");
        // Continue with other soal even if one fails
      }
    }
    
    print("Total soal loaded: ${soalList.length}");
    return soalList;
  }

  // Tambah soal baru
  Future<String> addSoal(Soal soal, File? gambar) async {
    print("Adding new soal: ${soal.pertanyaan}");
    
    String gambarUrl = soal.gambarUrl ?? '';

    // Upload gambar jika ada
    if (gambar != null) {
      print("Uploading soal image");
      String? uploadedUrl = await _cPanelService.uploadImage(gambar);
      if (uploadedUrl != null) {
        gambarUrl = uploadedUrl;
        print("Image uploaded successfully: $gambarUrl");
      } else {
        print("Failed to upload image");
      }
    }

    // Create soal document
    DocumentReference docRef = await _soalCollection.add({
      'pertanyaan': soal.pertanyaan,
      'opsi': soal.opsi,
      'jawabanBenar': soal.jawabanBenar,
      'gambarUrl': gambarUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    print("New soal created with ID: ${docRef.id}");
    
    // Verify the soal was created correctly
    DocumentSnapshot verifyDoc = await docRef.get();
    Map<String, dynamic> data = verifyDoc.data() as Map<String, dynamic>;
    print("Verified soal data: $data");
    
    return docRef.id;
  }

  // Update soal
  Future<void> updateSoal(Soal soal, File? gambar) async {
    print("Updating soal with ID: ${soal.id}");
    
    String gambarUrl = soal.gambarUrl ?? '';

    // Upload gambar baru jika ada
    if (gambar != null) {
      print("Uploading new soal image");
      String? uploadedUrl = await _cPanelService.uploadImage(gambar);
      if (uploadedUrl != null) {
        gambarUrl = uploadedUrl;
        print("New image uploaded successfully: $gambarUrl");
      } else {
        print("Failed to upload new image");
      }
    }

    // Update soal document
    await _soalCollection.doc(soal.id).update({
      'pertanyaan': soal.pertanyaan,
      'opsi': soal.opsi,
      'jawabanBenar': soal.jawabanBenar,
      'gambarUrl': gambarUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    print("Soal updated successfully");
    
    // Verify the update was successful
    DocumentSnapshot updatedDoc = await _soalCollection.doc(soal.id).get();
    Map<String, dynamic> data = updatedDoc.data() as Map<String, dynamic>;
    print("Verified updated soal data: $data");
  }

  // Hapus soal
  Future<void> deleteSoal(String id) async {
    print("Deleting soal with ID: $id");
    await _soalCollection.doc(id).delete();
    print("Soal deleted successfully");
  }

  // Method baru: menambahkan soal ke evaluasi
  Future<void> addSoalToEvaluasi(String evaluasiId, String soalId) async {
    print("Adding soal $soalId to evaluasi $evaluasiId");
    
    try {
      // Get evaluasi saat ini
      Evaluasi evaluasi = await getEvaluasiById(evaluasiId);
      
      // Tambahkan soalId ke array soalIds jika belum ada
      List<String> updatedSoalIds = List<String>.from(evaluasi.soalIds);
      if (!updatedSoalIds.contains(soalId)) {
        updatedSoalIds.add(soalId);
        print("Added soalId to array: $soalId");
        
        // Update dokumen evaluasi
        await _evaluasiCollection.doc(evaluasiId).update({
          'soalIds': updatedSoalIds,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        print("Evaluasi updated with new soalId");
        
        // Verify the update
        DocumentSnapshot updatedDoc = await _evaluasiCollection.doc(evaluasiId).get();
        Map<String, dynamic> data = updatedDoc.data() as Map<String, dynamic>;
        List<String> verifiedSoalIds = List<String>.from(data['soalIds'] ?? []);
        print("Verified updated soalIds: $verifiedSoalIds");
      } else {
        print("SoalId already exists in evaluasi, no update needed");
      }
    } catch (e) {
      print("Error adding soal to evaluasi: $e");
      throw e;
    }
  }
  
  // Method baru: menghapus soal dari evaluasi
  Future<void> removeSoalFromEvaluasi(String evaluasiId, String soalId) async {
    print("Removing soal $soalId from evaluasi $evaluasiId");
    
    try {
      // Get evaluasi saat ini
      Evaluasi evaluasi = await getEvaluasiById(evaluasiId);
      
      // Hapus soalId dari array soalIds
      List<String> updatedSoalIds = List<String>.from(evaluasi.soalIds);
      updatedSoalIds.remove(soalId);
      print("Removed soalId from array: $soalId");
      
      // Update dokumen evaluasi
      await _evaluasiCollection.doc(evaluasiId).update({
        'soalIds': updatedSoalIds,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print("Evaluasi updated after removing soalId");
      
      // Verify the update
      DocumentSnapshot updatedDoc = await _evaluasiCollection.doc(evaluasiId).get();
      Map<String, dynamic> data = updatedDoc.data() as Map<String, dynamic>;
      List<String> verifiedSoalIds = List<String>.from(data['soalIds'] ?? []);
      print("Verified updated soalIds after removal: $verifiedSoalIds");
    } catch (e) {
      print("Error removing soal from evaluasi: $e");
      throw e;
    }
  }

  // Verifikasi password admin
  Future<bool> verifyAdminPassword(String password) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('settings').doc('admin').get();
      String storedPassword = (doc.data() as Map<String, dynamic>)['password'] ?? '';
      return password == storedPassword;
    } catch (e) {
      print('Error verifying admin password: $e');
      return false;
    }
  }

  // Set password admin (default jika belum ada)
  Future<void> setupAdminPassword() async {
    try {
      DocumentSnapshot doc = await _firestore.collection('settings').doc('admin').get();
      if (!doc.exists) {
        await _firestore.collection('settings').doc('admin').set({
          'password': 'admin123', // Default password
        });
      }
    } catch (e) {
      print('Error setting up admin password: $e');
    }
  }

  // Update password admin
  Future<void> updateAdminPassword(String newPassword) async {
    await _firestore.collection('settings').doc('admin').update({
      'password': newPassword,
    });
  }

  // Tambahkan method ini ke FirebaseService
  Future<void> preloadVideos() async {
    try {
      await _videoCollection.get();
      print('Video data preloaded');
    } catch (e) {
      print('Error preloading videos: $e');
    }
  }

  Future<void> preloadMateri() async {
    try {
      await _materiCollection.get();
      print('Materi data preloaded');
    } catch (e) {
      print('Error preloading materi: $e');
    }
  }
}