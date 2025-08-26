import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config/api_config.dart';
import '../utils/page_transition.dart';
import '../widgets/smooth_widgets.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _viewPassword = false;
  String? _idError;
  String? _passwordError;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Reset error messages
    setState(() {
      _idError = null;
      _passwordError = null;
    });

    // Validate fields
    bool hasError = false;

    if (_idController.text.trim().isEmpty) {
      setState(() {
        _idError = 'Employee ID wajib diisi';
      });
      hasError = true;
    }

    if (_passwordController.text.trim().isEmpty) {
      setState(() {
        _passwordError = 'Password wajib diisi';
      });
      hasError = true;
    }

    if (hasError) {
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
          SmoothLoginRoute(page: HomePage()),
        );
      } else {
        final errorData = json.decode(response.body);
        final message = errorData['message'] ?? 'Login gagal';

        setState(() {
          _idError = null;
          _passwordError =
              message; // Semua pesan error akan ditampilkan di bawah password
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Terjadi kesalahan koneksi. Silakan coba lagi.',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 4),
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
                    hint: 'Employee ID (contoh: EMP006)',
                    icon: Icons.person_outline,
                    errorText: _idError,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    obscure: !_viewPassword,
                    hint: 'Password (default: 123456)',
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _viewPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _viewPassword = !_viewPassword;
                        });
                      },
                    ),
                    errorText: _passwordError,
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFE31837),
                            Color(0xFFD10000),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFE31837).withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
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
                    width: 200,
                    height: 55,
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
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    IconData? icon,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.80,
          height: MediaQuery.of(context).size.height * 0.07,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null ? Colors.red : Colors.grey.shade300,
              width: errorText != null ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: errorText != null
                    ? Colors.red.withOpacity(0.1)
                    : Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: errorText != null
                    ? Colors.red.shade400
                    : Colors.grey.shade500,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              prefixIcon: icon != null
                  ? Icon(
                      icon,
                      color:
                          errorText != null ? Colors.red : Colors.grey.shade600,
                      size: 20,
                    )
                  : null,
              suffixIcon: suffixIcon,
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 6),
            child: Text(
              errorText,
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
