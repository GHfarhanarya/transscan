import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String userName = "Pengguna";

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? "Pengguna";
    });
  }

  Future<void> _showChangePasswordDialog() async {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ganti Password"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: oldPassController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password Lama"),
                ),
                TextField(
                  controller: newPassController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password Baru"),
                ),
                TextField(
                  controller: confirmPassController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: "Konfirmasi Password"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Simpan"),
              onPressed: () async {
                if (newPassController.text != confirmPassController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password baru tidak cocok")),
                  );
                  return;
                }

                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('token') ?? "";

                final response = await http.post(
                  Uri.parse('${ApiConfig.baseUrl}/change-password'),
                  headers: {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer $token",
                  },
                  body: jsonEncode({
                    "oldPassword": oldPassController.text,
                    "newPassword": newPassController.text,
                  }),
                );

                if (response.statusCode == 200) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password berhasil diubah")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text("Gagal mengubah password: ${response.body}")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDA2926),
              foregroundColor: Colors.white,
            ),
            child: const Text("Keluar"),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context,
      {required String label, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: onTap,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFFDA2926),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              userName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildMenuButton(
              context,
              label: "Detail akun",
              onTap: () {
                // Nanti bisa diisi navigasi ke detail akun
              },
            ),
            _buildMenuButton(
              context,
              label: "Ganti password",
              onTap: _showChangePasswordDialog,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showLogoutDialog,
              icon: const Icon(Icons.logout),
              label: const Text("Keluar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDA2926),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const Spacer(),
            Image.asset('assets/Transmart.png', height: 30),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
