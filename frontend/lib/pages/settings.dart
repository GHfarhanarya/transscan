import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../widgets/custom_navbar.dart';
import '../pages/personal_info_page.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMsg;
  String userName = "Pengguna";
  String employeeId = "-";
  String jobTitle = "-";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? "Pengguna";
      employeeId = prefs.getString('employee_id') ?? "-";
      jobTitle = prefs.getString('job_title') ?? "-";
      userData = {
        'name': userName,
        'employee_id': employeeId,
        'job_title': jobTitle,
      };
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
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.07,
      margin: const EdgeInsets.only(bottom: 10),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(12), boxShadow: [
        BoxShadow(
          color: Colors.grey.shade300,
          blurRadius: 4,
          offset: Offset(2, 2),
        )
      ]),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey,
          minimumSize: const Size(double.infinity, 50),
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300)),
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
      appBar: AppBar(
        title: const Text("Profile"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD10000), Color(0xFFFF8585)],
              stops: const [0.6, 1.0],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBar: CustomNavbar(selectedIndex: 2),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFE5E5), Color(0xFFFFF5F5)],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              children: [
                const SizedBox(height: 30),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD10000),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  jobTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                // Card Menu
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 12),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person_outline, color: Color(0xFFD10000)),
                          title: const Text('ID Karyawan',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            employeeId,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.lock_outline,
                              color: Color(0xFFD10000)),
                          title: const Text("Ganti password",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          onTap: _showChangePasswordDialog,
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.logout,
                              color: Color(0xFFD10000)),
                          title: const Text("Keluar",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          onTap: _showLogoutDialog,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Image.asset('assets/Transmart.png', height: 30),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
