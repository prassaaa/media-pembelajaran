import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pembelajaran_app/config/constants.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/screens/home_screen.dart';
import 'package:pembelajaran_app/screens/materi/materi_screen.dart';
import 'package:pembelajaran_app/screens/materi/materi_detail_screen.dart';
import 'package:pembelajaran_app/screens/video/video_screen.dart';
import 'package:pembelajaran_app/screens/video/video_detail_screen.dart';
import 'package:pembelajaran_app/screens/evaluasi/evaluasi_screen.dart';
import 'package:pembelajaran_app/screens/evaluasi/evaluasi_detail_screen.dart';
import 'package:pembelajaran_app/screens/evaluasi/hasil_screen.dart';
import 'package:pembelajaran_app/screens/admin/admin_dashboard.dart';
import 'package:pembelajaran_app/screens/admin/admin_materi_screen.dart';
import 'package:pembelajaran_app/screens/admin/admin_materi_form.dart';
import 'package:pembelajaran_app/screens/admin/admin_video_screen.dart';
import 'package:pembelajaran_app/screens/admin/admin_video_form.dart';
import 'package:pembelajaran_app/screens/admin/admin_evaluasi_screen.dart';
import 'package:pembelajaran_app/screens/admin/admin_evaluasi_form.dart';
import 'package:pembelajaran_app/screens/admin/admin_soal_form.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseService().preloadVideos();
  // Setup admin password jika belum ada
  final FirebaseService firebaseService = FirebaseService();
  await firebaseService.setupAdminPassword();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppConstants.routeHome,
      routes: {
        // User Routes
        AppConstants.routeHome: (context) => const HomeScreen(),
        AppConstants.routeMateri: (context) => const MateriScreen(),
        AppConstants.routeMateriDetail: (context) => const MateriDetailScreen(),
        AppConstants.routeVideo: (context) => const VideoScreen(),
        AppConstants.routeVideoDetail: (context) => const VideoDetailScreen(),
        AppConstants.routeEvaluasi: (context) => const EvaluasiScreen(),
        AppConstants.routeEvaluasiDetail: (context) => const EvaluasiDetailScreen(),
        AppConstants.routeHasil: (context) => const HasilScreen(),
        
        // Admin Routes
        AppConstants.routeAdmin: (context) => const AdminDashboard(),
        AppConstants.routeAdminMateri: (context) => const AdminMateriScreen(),
        AppConstants.routeAdminMateriForm: (context) => const AdminMateriForm(),
        AppConstants.routeAdminVideo: (context) => const AdminVideoScreen(),
        AppConstants.routeAdminVideoForm: (context) => const AdminVideoForm(),
        AppConstants.routeAdminEvaluasi: (context) => const AdminEvaluasiScreen(),
        AppConstants.routeAdminEvaluasiForm: (context) => const AdminEvaluasiForm(),
        AppConstants.routeAdminSoalForm: (context) => const AdminSoalForm(),
      },
    );
  }
}