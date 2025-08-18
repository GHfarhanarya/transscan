import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

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
      // Ganti endpoint sesuai API user info kamu
      final url = Uri.parse('${ApiConfig.baseUrl}/user/profile');
      final res = await http.get(url);
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
        backgroundColor: const Color(0xFFDA2926),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMsg != null
              ? Center(child: Text(errorMsg!))
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nama: ${userData?['name'] ?? '-'}', style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 12),
                      Text('Email: ${userData?['email'] ?? '-'}', style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 12),
                      Text('No. HP: ${userData?['phone'] ?? '-'}', style: const TextStyle(fontSize: 18)),
                      // Tambahkan field lain sesuai kebutuhan
                    ],
                  ),
                ),
    );
  }
}
