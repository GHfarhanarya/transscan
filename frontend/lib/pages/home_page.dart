
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:frontend/pages/settings.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart'; // <-- IMPORT FILE KONFIGURASI
import 'product_detail_page.dart';
import '../services/auth_service.dart';
import '../widgets/custom_navbar.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi untuk scan barcode dari kamera
  Future<void> scanBarcode() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);

      if (!mounted) return;

      if (barcodeScanRes == '-1') {
        // Jika scan dibatalkan oleh pengguna
        setState(() => _isLoading = false);
        return;
      }

      // Langsung fetch data dari server berdasarkan hasil scan
      await _fetchAndNavigate(barcodeScanRes, isBarcode: true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat scan: $e')),
      );
    }
  }

  // Fungsi untuk mencari produk dari input manual
  Future<void> _searchProduct() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Masukkan nama produk atau barcode')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    // Cek apakah input berupa angka (kemungkinan barcode) atau teks (nama produk)
    final bool isNumeric = double.tryParse(query) != null;

    await _fetchAndNavigate(query, isBarcode: isNumeric);
  }

  // Fungsi utama untuk mengambil data dari server dan navigasi
  Future<void> _fetchAndNavigate(String query,
      {required bool isBarcode}) async {
    String endpoint;
    // Tentukan endpoint berdasarkan tipe query
    if (isBarcode) {
      endpoint = '/product/search/barcode/$query';
    } else {
      endpoint = '/product/search/name/$query';
    }

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final String? token = await AuthService
          .getToken(); // Ambil token untuk otorisasi jika perlu

      final res = await http.get(
        url,
        headers: {
          // Beberapa endpoint mungkin tidak butuh token, tapi menyertakannya tidak masalah
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        final Map<String, dynamic> product = json.decode(res.body);

        // Navigasi ke halaman detail produk
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      } else {
        // Jika produk tidak ditemukan oleh server
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk tidak ditemukan di database.')),
        );
      }
    } catch (e) {
      // Jika terjadi error koneksi, dll.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal terhubung ke server: $e')),
      );
    } finally {
      // Pastikan loading indicator selalu berhenti
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                await AuthService.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    resizeToAvoidBottomInset:
      false, // pastikan aktif agar layout naik saat keyboard muncul
    appBar: AppBar(
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20)
          ),
          child: Image.asset(
            'assets/TransRetail.png',
            height: 10,
          ),
        ),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFD10000),
                Color(0xFFFF8585).withOpacity(0.8),
              ],
              stops: [
                0.5,
                1.0,
              ]
            ),
          ),
        ),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              } else if (value == 'logout') {
                _showLogoutDialog();
              }
            },
          ),
        ],
      ),
  bottomNavigationBar: const CustomNavbar(selectedIndex: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 24.0,
            bottom: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Section - 30% tinggi
              Flexible(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner, size: 40, color: Colors.red),
                      SizedBox(height: 8),
                      Text(
                        'Selamat Datang di TransMart Scanner',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Scan barcode produk untuk melihat informasi lengkap',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Scan Button - 15% tinggi
              Flexible(
                flex: 1,
                child: SizedBox(
                  height: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : scanBarcode,
                    icon: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(Icons.qr_code_scanner, size: 24),
                    label: Text(
                      _isLoading ? 'Memuat...' : 'Scan Barcode',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFDA2926),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Divider - 5% tinggi
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[400])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Atau',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[400])),
                ],
              ),
              SizedBox(height: 30),

              // Search Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.search, color: Color(0xFFF44336), size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Cari Produk',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Masukkan nama produk atau barcode',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 12),

                    // Search Input
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Contoh: Indomie atau 8999999037260',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          hintStyle: TextStyle(color: Colors.grey[500]),
                        ),
                        onSubmitted: (_) => _searchProduct(),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Search Button
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _searchProduct,
                        icon: _isLoading
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(Icons.search, size: 20),
                        label: Text(
                          _isLoading ? 'Mencari...' : 'Cari Produk',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[100],
                          foregroundColor: Colors.red[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20), // supaya bawah ada jarak
            ],
          ),
        ),
      ),
    );
  }
}
