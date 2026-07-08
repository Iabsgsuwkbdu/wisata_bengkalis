import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/favorites_provider.dart';
import '../widgets/glass_container.dart';
import 'register_screen.dart';
import 'main_navigation.dart';

/// Halaman masuk (Login) dengan desain modern glassmorphism.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Menangani aksi login
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      // Panggil service login lokal
      final user = await _authService.login(email, password);
      
      if (!mounted) return;

      if (user != null) {
        // Sinkronisasi data ke FavoritesProvider agar UI profil diperbarui
        await Provider.of<FavoritesProvider>(context, listen: false)
            .updateUserProfile(name: user.name, email: user.email);

        if (!mounted) return;

        // Tampilkan Snackbar sukses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Selamat datang kembali, ${user.name}!',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        // Arahkan ke Halaman Utama Navigasi
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      } else {
        // Tampilkan Snackbar gagal jika email/password salah
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Masuk Gagal: Email atau Kata Sandi salah.',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Terjadi kesalahan: $e',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          // Latar belakang gradasi gelap navy / terang soft
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF0A0F1D), // darkBg
                        const Color(0xFF111827),
                        const Color(0xFF0F172A),
                      ]
                    : [
                        const Color(0xFFE0F2FE),
                        const Color(0xFFF1F5F9),
                        const Color(0xFFFFFFFF),
                      ],
              ),
            ),
          ),

          // Dekorasi bentuk bulat abstrak artistik
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0B63E5).withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00D1FF).withOpacity(0.06),
              ),
            ),
          ),

          // Area konten form login
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Badge Logo
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF0B63E5).withOpacity(0.12),
                            border: Border.all(
                              color: const Color(0xFF0B63E5).withOpacity(0.24),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.explore_rounded,
                            size: 48,
                            color: Color(0xFF0B63E5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Selamat Datang',
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Masuk untuk menjelajahi keindahan Bengkalis',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Formulir dengan Glassmorphism
                    GlassContainer(
                      opacity: isDark ? 0.04 : 0.6,
                      blur: 20,
                      borderRadius: BorderRadius.circular(24),
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Input Email
                            Text(
                              'Email',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.inter(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Masukkan email Anda',
                                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email tidak boleh kosong';
                                }
                                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                if (!emailRegex.hasMatch(value.trim())) {
                                  return 'Format email tidak valid';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Input Password
                            Text(
                              'Kata Sandi',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: GoogleFonts.inter(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Masukkan kata sandi Anda',
                                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                                prefixIcon: const Icon(Icons.lock_outlined, size: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Kata sandi tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            // Tombol Masuk
                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0B63E5),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Masuk',
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Navigasi ke halaman registrasi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Belum punya akun? ',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const RegisterScreen()),
                            );
                          },
                          child: Text(
                            'Daftar Sekarang',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0B63E5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}