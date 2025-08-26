import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'product_detail_page.dart' as pdp;
import '../services/auth_service.dart';
import '../services/hybrid_scanner_service.dart';
import '../widgets/custom_navbar.dart';
import '../utils/page_transition.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String? _searchError;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi untuk hybrid scan (barcode + OCR)
  Future<void> scanBarcode() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Gunakan hybrid scanner service
      final result = await HybridScannerService.performHybridScan();

      if (!mounted) return;

      if (result != null && result['success']) {
        // Navigate ke detail page dengan data produk
        Navigator.push(
          context,
          DetailPageRoute(
            page: pdp.ProductDetailPage(
              product: {
                'item_name': result['data']['item_name'],
                'item_code': result['data']['item_code'] ?? '',
                'barcode': result['data']['barcode'] ?? '',
                'normal_price': result['data']['normal_price'],
                'harga_promo': result['data']['harga_promo'],
                'stock': result['data']['stock'] ?? 0,
                'image': result['data']['image'],
              },
            ),
          ),
        );

        // Show success message with method used
        String methodText = result['method'] == 'barcode' 
            ? 'Barcode berhasil dideteksi' 
            : 'Teks pada kemasan berhasil dibaca';
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  result['method'] == 'barcode' 
                      ? Icons.qr_code_scanner 
                      : Icons.text_fields, 
                  color: Colors.white, 
                  size: 20
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        methodText,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      if (result['method'] == 'ocr') 
                        Text(
                          'Confidence: ${(result['confidence'] * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12, 
                            color: Colors.white.withOpacity(0.8)
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.search_off, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Produk tidak ditemukan',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Coba posisikan kamera lebih dekat atau pastikan kemasan terlihat jelas',
                        style: TextStyle(
                          fontSize: 12, 
                          color: Colors.white.withOpacity(0.8)
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Terjadi kesalahan saat scanning. Pastikan izin kamera sudah diberikan.',
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

  // Fungsi untuk mencari produk dari input manual
  Future<void> _searchProduct() async {
    // Reset error
    setState(() {
      _searchError = null;
    });

    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchError = 'Silakan masukkan nama produk atau kode barcode';
      });
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
          DetailPageRoute(
            page: pdp.ProductDetailPage(product: product),
          ),
        );
      } else {
        // Jika produk tidak ditemukan oleh server
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.search_off, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Produk tidak ditemukan. Silakan coba dengan nama atau kode barcode yang lain.',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.grey[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Jika terjadi error koneksi, dll.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Gagal terhubung ke server. Periksa koneksi internet Anda.',
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
                  ExitPageRoute(page: LoginPage()),
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
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
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
              stops: [0.5, 1.0],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavbar(selectedIndex: 0),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: isKeyboardVisible ? 8.0 : 24.0,
            bottom: isKeyboardVisible ? 4.0 : 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Section
                Container(
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
                        'Scan barcode atau baca teks kemasan untuk informasi produk',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isKeyboardVisible ? 8 : 16),

                // Scan Button
                Container(
                  height: 60,
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
                        color: Color(0xFFE31837).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
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
                      _isLoading ? 'Memuat...' : 'Smart Scan',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),

                SizedBox(height: isKeyboardVisible ? 8 : 16),

                // Divider
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

                SizedBox(height: isKeyboardVisible ? 16 : 30),

                // Search Section
                Container(
                  padding: EdgeInsets.all(isKeyboardVisible ? 12 : 20),
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
                          Icon(Icons.search,
                              color: Color(0xFFF44336), size: 24),
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
                        'Ketik nama produk atau scan kode barcode untuk mencari informasi produk',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 12),

                      // Search Input
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _searchError != null
                                    ? Colors.red
                                    : Colors.grey[300]!,
                                width: _searchError != null ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: _searchError != null
                                  ? [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.1),
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Cari berdasarkan nama produk atau kode barcode...',
                                hintStyle: TextStyle(
                                  color: _searchError != null
                                      ? Colors.red.shade400
                                      : Colors.grey[500],
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: _searchError != null
                                      ? Colors.red
                                      : Colors.grey[600],
                                  size: 20,
                                ),
                              ),
                              onSubmitted: (_) => _searchProduct(),
                              onChanged: (_) {
                                if (_searchError != null) {
                                  setState(() {
                                    _searchError = null;
                                  });
                                }
                              },
                            ),
                          ),
                          if (_searchError != null)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 12.0, top: 6),
                              child: Text(
                                _searchError!,
                                style: TextStyle(
                                  color: Colors.red.shade600,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
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

                SizedBox(
                  height: isKeyboardVisible ? 8 : 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
