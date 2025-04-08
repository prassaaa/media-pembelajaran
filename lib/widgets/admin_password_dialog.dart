import 'package:flutter/material.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';

class AdminPasswordDialog extends StatefulWidget {
  final Function(bool) onAuthenticated;

  const AdminPasswordDialog({
    Key? key,
    required this.onAuthenticated,
  }) : super(key: key);

  @override
  State<AdminPasswordDialog> createState() => _AdminPasswordDialogState();
}

class _AdminPasswordDialogState extends State<AdminPasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  bool _isError = false;
  String _errorMessage = '';
  bool _obscureText = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _verifyPassword() async {
    print('Verifikasi password dimulai');
    
    if (_passwordController.text.isEmpty) {
      setState(() {
        _isError = true;
        _errorMessage = 'Password tidak boleh kosong';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      print('Mencoba verifikasi dengan Firebase');
      // Tambahkan timeout untuk mencegah loading tak berakhir
      bool isValid = await _firebaseService.verifyAdminPassword(_passwordController.text)
          .timeout(Duration(seconds: 10), onTimeout: () {
        throw Exception('Koneksi timeout, silakan coba lagi');
      });
      
      print('Hasil verifikasi: $isValid');
      
      // Pastikan state loading diubah ke false terlebih dahulu
      setState(() {
        _isLoading = false;
      });
      
      if (isValid) {
        // Panggil callback dengan hasil autentikasi
        widget.onAuthenticated(true);
        // Tidak perlu Navigator.pop() di sini
      } else {
        setState(() {
          _isError = true;
          _errorMessage = 'Password salah';
        });
      }
    } catch (e) {
      print('Error selama verifikasi: $e');
      setState(() {
        _isError = true;
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.admin_panel_settings,
              size: 60,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Akses Admin',
              style: AppTheme.headingMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Masukkan password untuk mengakses fitur admin',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password Admin',
                hintText: 'Masukkan password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _isError ? _errorMessage : null,
              ),
              obscureText: _obscureText,
              onSubmitted: (_) => _verifyPassword(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Masuk'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}