import 'package:cloud_firestore/cloud_firestore.dart';

class Materi {
  final String id;
  final String judul;
  final String deskripsi;
  final String gambarUrl;
  final String konten;
  final DateTime createdAt;
  final DateTime updatedAt;

  Materi({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.gambarUrl,
    required this.konten,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Materi.fromMap(Map<String, dynamic> map, String id) {
    return Materi(
      id: id,
      judul: map['judul'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      gambarUrl: map['gambarUrl'] ?? '',
      konten: map['konten'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'judul': judul,
      'deskripsi': deskripsi,
      'gambarUrl': gambarUrl,
      'konten': konten,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

// Model untuk Video Pembelajaran
class Video {
  final String id;
  final String judul;
  final String deskripsi;
  final String youtubeUrl;
  final String thumbnailUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Video({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.youtubeUrl,
    required this.thumbnailUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Video.fromMap(Map<String, dynamic> map, String id) {
    return Video(
      id: id,
      judul: map['judul'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      youtubeUrl: map['youtubeUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'judul': judul,
      'deskripsi': deskripsi,
      'youtubeUrl': youtubeUrl,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

// Model untuk Soal Evaluasi
class Soal {
  final String id;
  final String pertanyaan;
  final List<String> opsi;
  final int jawabanBenar;
  final String? gambarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Soal({
    required this.id,
    required this.pertanyaan,
    required this.opsi,
    required this.jawabanBenar,
    this.gambarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Soal.fromMap(Map<String, dynamic> map, String id) {
    return Soal(
      id: id,
      pertanyaan: map['pertanyaan'] ?? '',
      opsi: List<String>.from(map['opsi'] ?? []),
      jawabanBenar: map['jawabanBenar'] ?? 0,
      gambarUrl: map['gambarUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pertanyaan': pertanyaan,
      'opsi': opsi,
      'jawabanBenar': jawabanBenar,
      'gambarUrl': gambarUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

// Model untuk Evaluasi (Kumpulan Soal)
class Evaluasi {
  final String id;
  final String judul;
  final String deskripsi;
  final List<String> soalIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Evaluasi({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.soalIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Evaluasi.fromMap(Map<String, dynamic> map, String id) {
    return Evaluasi(
      id: id,
      judul: map['judul'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      soalIds: List<String>.from(map['soalIds'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'judul': judul,
      'deskripsi': deskripsi,
      'soalIds': soalIds,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}