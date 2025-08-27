import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../widgets/custom_navbar.dart';
import '../utils/page_transition.dart';
import 'home_page.dart';

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
    bool showOldPass = false;
    bool showNewPass = false;
    bool showConfirmPass = false;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.grey[50]!,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// ===== Header =====
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFE31837),
                            Color(0xFFD10000),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.lock_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Ganti Password',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// ===== Form Content =====
                    Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          /// ===== Old Password =====
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: TextField(
                              controller: oldPassController,
                              obscureText: !showOldPass,
                              style: TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                hintText: 'Password Lama',
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: Color(0xFFE31837),
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    showOldPass
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      showOldPass = !showOldPass;
                                    });
                                  },
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 16),

                          /// ===== New Password =====
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: TextField(
                              controller: newPassController,
                              obscureText: !showNewPass,
                              style: TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                hintText: 'Password Baru',
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                prefixIcon: Icon(
                                  Icons.lock_reset,
                                  color: Color(0xFFE31837),
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    showNewPass
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      showNewPass = !showNewPass;
                                    });
                                  },
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 16),

                          /// ===== Confirm Password =====
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: TextField(
                              controller: confirmPassController,
                              obscureText: !showConfirmPass,
                              style: TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                hintText: 'Konfirmasi Password',
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                prefixIcon: Icon(
                                  Icons.check_circle_outline,
                                  color: Color(0xFFE31837),
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    showConfirmPass
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      showConfirmPass = !showConfirmPass;
                                    });
                                  },
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 24),

                          /// ===== Action Buttons =====
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[200],
                                      foregroundColor: Colors.grey[700],
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Batal',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFE31837),
                                        Color(0xFFD10000),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Color(0xFFE31837).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () async {
                                            if (newPassController.text !=
                                                confirmPassController.text) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    children: [
                                                      Icon(Icons.error,
                                                          color: Colors.white),
                                                      SizedBox(width: 8),
                                                      Text(
                                                          "Password baru tidak cocok"),
                                                    ],
                                                  ),
                                                  backgroundColor: Colors.red,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            setState(() {
                                              isLoading = true;
                                            });

                                            try {
                                              final prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              final token =
                                                  prefs.getString('token') ??
                                                      "";

                                              final response = await http.post(
                                                Uri.parse(
                                                    '${ApiConfig.baseUrl}/change-password'),
                                                headers: {
                                                  "Content-Type":
                                                      "application/json",
                                                  "Authorization":
                                                      "Bearer $token",
                                                },
                                                body: jsonEncode({
                                                  "oldPassword":
                                                      oldPassController.text,
                                                  "newPassword":
                                                      newPassController.text,
                                                }),
                                              );

                                              if (response.statusCode == 200) {
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Row(
                                                      children: [
                                                        Icon(Icons.check_circle,
                                                            color:
                                                                Colors.white),
                                                        SizedBox(width: 8),
                                                        Text(
                                                            "Password berhasil diubah"),
                                                      ],
                                                    ),
                                                    backgroundColor:
                                                        Colors.green,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Row(
                                                      children: [
                                                        Icon(Icons.error,
                                                            color:
                                                                Colors.white),
                                                        SizedBox(width: 8),
                                                        Expanded(
                                                          child: Text(
                                                              "Gagal mengubah password: ${response.body}"),
                                                        ),
                                                      ],
                                                    ),
                                                    backgroundColor: Colors.red,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    children: [
                                                      Icon(Icons.error,
                                                          color: Colors.white),
                                                      SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                            "Terjadi kesalahan: $e"),
                                                      ),
                                                    ],
                                                  ),
                                                  backgroundColor: Colors.red,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                              );
                                            } finally {
                                              setState(() {
                                                isLoading = false;
                                              });
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: isLoading
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            'Simpan',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey[50]!,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// ===== Header =====
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE31837),
                      Color(0xFFD10000),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Konfirmasi Logout',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              /// ===== Content =====
              Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange[600],
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Apakah Anda yakin ingin keluar?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Anda perlu login kembali untuk mengakses aplikasi.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    /// ===== Action Buttons =====
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                foregroundColor: Colors.grey[700],
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Batal',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFE31837)!,
                                  Color(0xFFD10000)!,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.clear();
                                  Navigator.pushReplacementNamed(
                                      context, '/login');
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.error,
                                              color: Colors.white),
                                          SizedBox(width: 8),
                                          Text("Terjadi kesalahan saat logout"),
                                        ],
                                      ),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Keluar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          "Profil Saya",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE31837),
                Color(0xFFD10000),
              ],
            ),
          ),
        ),
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                SettingsSlideRoute(page: HomePage(), isFromRight: false),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: CustomNavbar(selectedIndex: 2),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            /// ===== Profile Header Card =====
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE31837),
                    Color(0xFFD10000),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFE31837).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  /// ===== Avatar =====
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE31837),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  /// ===== User Name =====
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),

                  SizedBox(height: 8),

                  /// ===== Job Title =====
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      jobTitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  /// ===== Employee ID =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.badge_outlined,
                        color: Colors.white.withOpacity(0.8),
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'ID: $employeeId',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 25),

            /// ===== Menu Section =====
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengaturan Akun',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF565656),
                    ),
                  ),

                  SizedBox(height: 20),

                  /// ===== Change Password Menu =====
                  _buildModernMenuItem(
                    icon: Icons.lock_outline,
                    title: 'Ganti Password',
                    subtitle: 'Ubah password untuk keamanan akun',
                    iconColor: Colors.blue,
                    onTap: _showChangePasswordDialog,
                  ),

                  SizedBox(height: 16),

                  /// ===== Logout Menu =====
                  _buildModernMenuItem(
                    icon: Icons.logout_rounded,
                    title: 'Keluar',
                    subtitle: 'Logout dari aplikasi',
                    iconColor: Colors.red,
                    onTap: _showLogoutDialog,
                  ),
                ],
              ),
            ),
            // SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildModernMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
