import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config/api_config.dart';
import '../utils/page_transition.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_idController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Employee ID dan Password wajib diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'employee_id': _idController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      if (!mounted) return;

      // 🔹 Tambahkan debug print untuk cek respon dari server
      print("Login response status: ${response.statusCode}");
      print("Login response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseData['token']);
        await prefs.setString(
            'employee_id', responseData['user']['employee_id'] ?? "-");
        await prefs.setString(
            'name', responseData['user']['name'] ?? "Pengguna");
        await prefs.setString(
            'job_title', responseData['user']['job_title'] ?? "-");
        await prefs.setString('role', responseData['user']['role'] ?? "-");

        Navigator.pushReplacement(
          context,
          MainPageRoute(page: HomePage()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Login berhasil! Selamat datang ${responseData['user']['name']}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorData['message'] ?? 'Login gagal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false, // 🔹 ini bikin background tetap stay
      body: Stack(
        children: [
          /// ===== Background Vektor di bawah =====
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SvgPicture.asset(
                    'assets/vektor1.svg',
                    fit: BoxFit.fill,
                  ),
                  SvgPicture.asset(
                    'assets/vektor2.svg',
                    fit: BoxFit.fill,
                  ),
                ],
              ),
            ),
          ),

          /// ===== Logo TM di depan vektor =====
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Center(
              child: SvgPicture.asset(
                'assets/tm 1.svg',
                width: 160,
              ),
            ),
          ),

          /// ===== Konten Form Login =====
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 75),
                  SvgPicture.asset(
                    'assets/applogo.svg',
                    width: 135,
                    color: Color(0xFFE31837),
                  ),
                  const SizedBox(height: 50),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildTextField(
                    controller: _idController,
                    hint: 'Employee ID (contoh: EMP004)',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    hint: 'Password (format: DDMMYYYY)',
                    obscure: true,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 200,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE31837),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : Text(
                              'Masuk',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Belum punya akun? '),
                      GestureDetector(
                        onTap: () {
                          // navigasi ke halaman register
                        },
                        child: Text(
                          'Daftar',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 100), // biar ada jarak extra
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk field
  Widget _buildTextField({
    // required BuildContext context,
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.80, // % lebar layar
      height: MediaQuery.of(context).size.height * 0.07, // 7% tinggi layar
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
