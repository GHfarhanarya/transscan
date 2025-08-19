import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({Key? key}) : super(key: key);

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final url = Uri.parse('${ApiConfig.baseUrl}/user/profile');
      final res = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        setState(() {
          userData = json.decode(res.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMsg = 'Gagal mengambil data user';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Pribadi'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFFD10000), const Color(0xFFFF8585)],
              stops: const [0.6, 1.0],
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMsg != null
                ? Center(child: Text(errorMsg!))
                : Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Avatar
                                CircleAvatar(
                                  radius: 44,
                                  backgroundColor: Colors.red[100],
                                  child: Icon(Icons.person, size: 56, color: Colors.red[700]),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  userData?['name'] ?? '-',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFD10000),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  userData?['role'] ?? '-',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Card Data
                                Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
                                    child: Column(
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.badge, color: Color(0xFFD10000)),
                                          title: const Text('ID Pegawai', style: TextStyle(fontWeight: FontWeight.w600)),
                                          subtitle: Text(userData?['employee_id'] ?? '-'),
                                        ),
                                        const Divider(),
                                        ListTile(
                                          leading: const Icon(Icons.cake, color: Color(0xFFD10000)),
                                          title: const Text('Tanggal Lahir', style: TextStyle(fontWeight: FontWeight.w600)),
                                          subtitle: Text(userData?['birth_date'] ?? '-'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '© 2025 Transscan. All rights reserved.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
