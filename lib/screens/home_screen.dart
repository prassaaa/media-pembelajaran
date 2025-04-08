import 'package:flutter/material.dart';
import 'package:pembelajaran_app/config/constants.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/widgets/admin_password_dialog.dart';
import 'package:pembelajaran_app/widgets/app_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _showAdminPasswordDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) { // Gunakan variabel dialogContext yang berbeda
      return AdminPasswordDialog(
        onAuthenticated: (isAuthenticated) {
          // Tutup dialog terlebih dahulu
          Navigator.pop(dialogContext);
          
          // Kemudian lakukan navigasi jika berhasil
          if (isAuthenticated) {
            Navigator.pushNamed(context, AppConstants.routeAdmin);
          }
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
                          // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Media Pembelajaran',
                              style: AppTheme.headingMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Belajar dengan mudah, kapan saja dan di mana saja',
                              style: AppTheme.bodyMedium.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.school,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ClipRect(
                    child: Container(
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: () => _showAdminPasswordDialog(context),
                        icon: const Icon(Icons.admin_panel_settings, size: 16),
                        label: const Text('Admin'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          side: BorderSide(color: Colors.white, width: 1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Menu Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Menu Utama',
                      style: AppTheme.headingMedium,
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: screenSize.width > 600 ? 3 : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildMenuCard(
                            context,
                            'Materi Pembelajaran',
                            Icons.book,
                            AppTheme.primaryColor,
                            () => Navigator.pushNamed(
                              context,
                              AppConstants.routeMateri,
                            ),
                          ),
                          _buildMenuCard(
                            context,
                            'Video Pembelajaran',
                            Icons.video_library,
                            AppTheme.accentColor,
                            () => Navigator.pushNamed(
                              context,
                              AppConstants.routeVideo,
                            ),
                          ),
                          _buildMenuCard(
                            context,
                            'Evaluasi Pembelajaran',
                            Icons.assignment,
                            AppTheme.successColor,
                            () => Navigator.pushNamed(
                              context,
                              AppConstants.routeEvaluasi,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.white,
              child: Column(
                children: [
                  Text(
                    '© ${DateTime.now().year} Media Pembelajaran',
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Versi ${AppConstants.appVersion}',
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.grey.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
              ),
              child: Icon(
                icon,
                size: 40,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTheme.subtitleLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}