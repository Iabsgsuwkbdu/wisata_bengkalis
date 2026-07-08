import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/favorites_provider.dart';
import '../services/auth_service.dart';
import '../widgets/glass_container.dart';
import 'login_screen.dart';

ImageProvider getAvatarImageProvider(String avatarStr) {
  if (avatarStr.startsWith('http://') || avatarStr.startsWith('https://')) {
    return NetworkImage(avatarStr);
  } else if (avatarStr.startsWith('data:image')) {
    try {
      final base64Content = avatarStr.split(',').last;
      return MemoryImage(base64Decode(base64Content));
    } catch (_) {}
  }
  
  try {
    return MemoryImage(base64Decode(avatarStr));
  } catch (_) {}

  return const NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&auto=format&fit=crop&q=80');
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FavoritesProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine level badge based on user points
    String levelBadge = 'Penjelajah Pemula';
    Color badgeColor = Colors.teal;
    if (provider.userPoints >= 1000) {
      levelBadge = 'Duta Wisata Bengkalis';
      badgeColor = Colors.purple;
    } else if (provider.userPoints >= 500) {
      levelBadge = 'Petualang Ulung';
      badgeColor = Colors.amber[800]!;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil Wisatawan',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
        child: Column(
          children: [
            // Profile Header Panel
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        backgroundImage: getAvatarImageProvider(provider.userAvatar),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: IconButton(
                            icon: const Icon(Icons.edit, size: 14, color: Colors.white),
                            onPressed: () => _showEditAvatarDialog(context, provider),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.userName,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    provider.userEmail,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Level Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: badgeColor.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.military_tech_rounded, color: badgeColor, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          levelBadge,
                          style: TextStyle(
                            color: badgeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Statistics Grid (Visits, Favorites, Points) using Glassmorphism
            Row(
              children: [
                Expanded(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(12),
                    opacity: isDark ? 0.05 : 0.4,
                    child: Column(
                      children: [
                        Text(
                          'Kunjungan',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          provider.visitedCount.toString(),
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(12),
                    opacity: isDark ? 0.05 : 0.4,
                    child: Column(
                      children: [
                        Text(
                          'Poin Wisata',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${provider.userPoints}',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(12),
                    opacity: isDark ? 0.05 : 0.4,
                    child: Column(
                      children: [
                        Text(
                          'Favorit',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          provider.favoriteIds.length.toString(),
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Settings & Actions Section
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161E31) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Ganti Nama
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.withOpacity(0.1),
                      child: const Icon(Icons.person_rounded, color: Colors.purple, size: 20),
                    ),
                    title: const Text('Ganti Nama Lengkap', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Ubah nama lengkap profil Anda', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showEditNameDialog(context, provider),
                  ),
                  const Divider(height: 1, thickness: 0.5),

                  // Ganti Email
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.withOpacity(0.1),
                      child: const Icon(Icons.alternate_email_rounded, color: Colors.teal, size: 20),
                    ),
                    title: const Text('Ganti E-mail', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Perbarui alamat email akun Anda', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showEditEmailDialog(context, provider),
                  ),
                  const Divider(height: 1, thickness: 0.5),

                  // Ganti Kata Sandi
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.withOpacity(0.1),
                      child: const Icon(Icons.lock_reset_rounded, color: Colors.orange, size: 20),
                    ),
                    title: const Text('Ganti Kata Sandi', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Ubah kata sandi akun Anda secara berkala', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showEditPasswordDialog(context, provider),
                  ),
                  const Divider(height: 1, thickness: 0.5),

                  // Dark Mode Switch
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: const Icon(Icons.dark_mode_rounded, color: Colors.blue, size: 20),
                    ),
                    title: const Text('Mode Gelap', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      isDark ? 'Mode Gelap Aktif' : 'Mode Terang Aktif',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    trailing: Switch(
                      value: provider.isDarkTheme,
                      onChanged: (value) => provider.toggleTheme(),
                    ),
                  ),
                  const Divider(height: 1, thickness: 0.5),

                  // Language Settings
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.withOpacity(0.1),
                      child: const Icon(Icons.language_rounded, color: Colors.green, size: 20),
                    ),
                    title: const Text('Bahasa Aplikasi', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Indonesia (Default)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Hanya tersedia bahasa Indonesia untuk versi ini.')),
                      );
                    },
                  ),
                  const Divider(height: 1, thickness: 0.5),

                  // About Bengkalis
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.amber.withOpacity(0.1),
                      child: const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 20),
                    ),
                    title: const Text('Tentang Pulau Bengkalis', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Sejarah & letak geografis wilayah', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showAboutBengkalisDialog(context),
                  ),
                  const Divider(height: 1, thickness: 0.5),

                  // Help & Feedback
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.redAccent.withOpacity(0.1),
                      child: const Icon(Icons.support_agent_rounded, color: Colors.redAccent, size: 20),
                    ),
                    title: const Text('Bantuan & Saran', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Hubungi admin pengembang', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mengalihkan ke Pusat Bantuan Dinas Pariwisata...')),
                      );
                    },
                  ),
                  const Divider(height: 1, thickness: 0.5),

                  // Logout Button
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      child: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                    ),
                    title: const Text(
                      'Keluar',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
                    ),
                    subtitle: const Text('Keluar dari akun Anda', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.red),
                    onTap: () => _handleLogout(context, provider),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Text(
              'Aplikasi Eksplorasi Wisata Bengkalis v1.0.0',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, FavoritesProvider provider) {
    final nameController = TextEditingController(text: provider.userName);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161E31) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Edit Nama Lengkap',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nama Lengkap',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  hintText: 'Masukkan nama lengkap Anda',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    final userKey = 'user_reg_${provider.userEmail}';
                    final userJson = prefs.getString(userKey);
                    if (userJson != null) {
                      final userMap = jsonDecode(userJson);
                      userMap['name'] = nameController.text.trim();
                      await prefs.setString(userKey, jsonEncode(userMap));
                    }
                  } catch (_) {}

                  await provider.updateUserProfile(
                    name: nameController.text.trim(),
                    email: provider.userEmail,
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Nama lengkap berhasil diperbarui.'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simpan'),
            )
          ],
        );
      },
    );
  }

  void _showEditAvatarDialog(BuildContext context, FavoritesProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ImagePicker picker = ImagePicker();
    String? tempBase64Data;

    showDialog(
      context: context,
      builder: (context) {
        String currentAvatar = provider.userAvatar;

        return StatefulBuilder(
          builder: (context, setState) {
            final imageProvider = tempBase64Data != null
                ? getAvatarImageProvider(tempBase64Data!)
                : getAvatarImageProvider(currentAvatar);

            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF161E31) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                'Ganti Foto Profil',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      backgroundImage: imageProvider,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final XFile? file = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 400,
                          maxHeight: 400,
                          imageQuality: 80,
                        );
                        if (file != null) {
                          final bytes = await file.readAsBytes();
                          final base64String = base64Encode(bytes);
                          setState(() {
                            tempBase64Data = 'data:image/png;base64,$base64String';
                          });
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal memilih gambar: $e'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.photo_library_rounded, size: 18),
                    label: const Text('Pilih Foto Baru'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pilih foto JPG/PNG dari galeri perangkat Anda. Foto akan secara otomatis dikompresi agar hemat memori.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: isDark ? Colors.white60 : Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                  ),
                ),
                ElevatedButton(
                  onPressed: tempBase64Data == null
                      ? null
                      : () {
                          provider.updateUserAvatar(tempBase64Data!);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Foto profil berhasil diunggah dan disimpan.'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditEmailDialog(BuildContext context, FavoritesProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emailController = TextEditingController(text: provider.userEmail);
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final authService = AuthService();
    bool obscurePassword = true;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF161E31) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                'Ganti E-mail',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'E-mail Baru',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined),
                        hintText: 'Masukkan email baru',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                    const SizedBox(height: 16),
                    Text(
                      'Kata Sandi Saat Ini',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outlined),
                        hintText: 'Masukkan kata sandi untuk konfirmasi',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kata sandi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          
                          setState(() {
                            isLoading = true;
                          });

                          final newEmail = emailController.text.trim();
                          final password = passwordController.text;
                          
                          final err = await authService.changeEmail(
                            provider.userEmail,
                            newEmail,
                            password,
                          );

                          if (!context.mounted) return;

                          setState(() {
                            isLoading = false;
                          });

                          if (err == null) {
                            await provider.updateUserProfile(
                              name: provider.userName,
                              email: newEmail,
                            );
                            
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Email berhasil diperbarui.'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(err),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditPasswordDialog(BuildContext context, FavoritesProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final authService = AuthService();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF161E31) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                'Ganti Kata Sandi',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kata Sandi Saat Ini',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: currentPasswordController,
                        obscureText: obscureCurrent,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          hintText: 'Masukkan kata sandi saat ini',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureCurrent = !obscureCurrent;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kata sandi saat ini tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Kata Sandi Baru',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: obscureNew,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_rounded),
                          hintText: 'Masukkan kata sandi baru',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureNew = !obscureNew;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kata sandi baru tidak boleh kosong';
                          }
                          if (value.length < 6) {
                            return 'Kata sandi minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Konfirmasi Kata Sandi Baru',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.enhanced_encryption_rounded),
                          hintText: 'Ulangi kata sandi baru',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureConfirm = !obscureConfirm;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Konfirmasi kata sandi tidak boleh kosong';
                          }
                          if (value != newPasswordController.text) {
                            return 'Konfirmasi kata sandi tidak cocok';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setState(() {
                            isLoading = true;
                          });

                          final currentPassword = currentPasswordController.text;
                          final newPassword = newPasswordController.text;

                          final err = await authService.changePassword(
                            provider.userEmail,
                            currentPassword,
                            newPassword,
                          );

                          if (!context.mounted) return;

                          setState(() {
                            isLoading = false;
                          });

                          if (err == null) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Kata sandi berhasil diperbarui.'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(err),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAboutBengkalisDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.account_balance_rounded, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Pulau Bengkalis'),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pulau Bengkalis adalah pulau utama yang menjadi pusat pemerintahan Kabupaten Bengkalis, Provinsi Riau, Indonesia. Terletak di pantai timur Sumatera dekat muara Sungai Siak, pulau ini berbatasan langsung dengan Selat Malaka.',
                  style: TextStyle(fontSize: 13, height: 1.5),
                ),
                SizedBox(height: 12),
                Text(
                  'Dikenal dengan julukan "Kota Terubuk" karena populasi ikan terubuk yang melegenda, Pulau Bengkalis memiliki kekayaan sejarah multikultural yang unik, menyatukan kebudayaan Melayu Riau, Tionghoa, dan peninggalan arsitektur kolonial Belanda.',
                  style: TextStyle(fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            )
          ],
        );
      },
    );
  }

  /// Menampilkan dialog konfirmasi dan menangani proses logout pengguna.
  void _handleLogout(BuildContext context, FavoritesProvider provider) {
    final authService = AuthService();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161E31) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Konfirmasi Keluar',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari akun Anda?',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Tutup dialog konfirmasi
                
                // Hapus sesi login
                await authService.logout();
                
                // Atur ulang data profil di FavoritesProvider ke default
                await provider.updateUserProfile(
                  name: 'Wisatawan Bengkalis',
                  email: 'wisatawan@bengkalis.go.id',
                );

                if (!context.mounted) return;

                // Tampilkan snackbar sukses
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Anda telah berhasil keluar.',
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                    backgroundColor: Colors.blueGrey,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );

                // Navigasikan kembali ke LoginScreen dan hapus tumpukan navigasi
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }
}
