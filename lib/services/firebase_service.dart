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
    DocumentSnapshot doc = await _evaluasiCollection.doc(id).get();
    return Evaluasi.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  // Tambah evaluasi baru
  Future<String> addEvaluasi(Evaluasi evaluasi) async {
    DocumentReference docRef = await _evaluasiCollection.add({
      'judul': evaluasi.judul,
      'deskripsi': evaluasi.deskripsi,
      'soalIds': evaluasi.soalIds,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // Update evaluasi
  Future<void> updateEvaluasi(Evaluasi evaluasi) async {
    await _evaluasiCollection.doc(evaluasi.id).update({
      'judul': evaluasi.judul,
      'deskripsi': evaluasi.deskripsi,
      'soalIds': evaluasi.soalIds,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Hapus evaluasi
  Future<void> deleteEvaluasi(String id) async {
    // Get evaluasi untuk mendapatkan soalIds
    Evaluasi evaluasi = await getEvaluasiById(id);
    
    // Hapus semua soal yang terkait
    for (String soalId in evaluasi.soalIds) {
      await _soalCollection.doc(soalId).delete();
    }
    
    // Hapus evaluasi
    await _evaluasiCollection.doc(id).delete();
  }

  // SOAL OPERATIONS
  // Get soal by ID
  Future<Soal> getSoalById(String id) async {
    DocumentSnapshot doc = await _soalCollection.doc(id).get();
    return Soal.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  // Get soal dari evaluasi
  Future<List<Soal>> getSoalFromEvaluasi(String evaluasiId) async {
    Evaluasi evaluasi = await getEvaluasiById(evaluasiId);
    List<Soal> soalList = [];
    
    for (String soalId in evaluasi.soalIds) {
      Soal soal = await getSoalById(soalId);
      soalList.add(soal);
    }
    
    return soalList;
  }

  // Tambah soal baru
  Future<String> addSoal(Soal soal, File? gambar) async {
    String gambarUrl = soal.gambarUrl ?? '';

    // Upload gambar jika ada
    if (gambar != null) {
      String? uploadedUrl = await _cPanelService.uploadImage(gambar);
      if (uploadedUrl != null) {
        gambarUrl = uploadedUrl;
      }
    }

    DocumentReference docRef = await _soalCollection.add({
      'pertanyaan': soal.pertanyaan,
      'opsi': soal.opsi,
      'jawabanBenar': soal.jawabanBenar,
      'gambarUrl': gambarUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // Update soal
  Future<void> updateSoal(Soal soal, File? gambar) async {
    String gambarUrl = soal.gambarUrl ?? '';

    // Upload gambar baru jika ada
    if (gambar != null) {
      String? uploadedUrl = await _cPanelService.uploadImage(gambar);
      if (uploadedUrl != null) {
        gambarUrl = uploadedUrl;
      }
    }

    await _soalCollection.doc(soal.id).update({
      'pertanyaan': soal.pertanyaan,
      'opsi': soal.opsi,
      'jawabanBenar': soal.jawabanBenar,
      'gambarUrl': gambarUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Hapus soal
  Future<void> deleteSoal(String id) async {
    await _soalCollection.doc(id).delete();
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