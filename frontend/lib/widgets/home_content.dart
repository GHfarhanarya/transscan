import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/api_config.dart';
import '../services/auth_service.dart';
import '../pages/product_detail_page.dart';
import '../utils/page_transition.dart';

class HomeContent extends StatefulWidget {
  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String? _searchError;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Method scan barcode dan search (sama seperti di HomePage)
  Future<void> scanBarcode() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);

      if (!mounted) return;

      if (barcodeScanRes == '-1') {
        setState(() => _isLoading = false);
        return;
      }

      await _fetchAndNavigate(barcodeScanRes, isBarcode: true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorSnackBar('Gagal melakukan scan. Pastikan kamera dapat mengakses kode barcode.');
    }
  }

  Future<void> _searchProduct() async {
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

    final bool isNumeric = double.tryParse(query) != null;
    await _fetchAndNavigate(query, isBarcode: isNumeric);
  }

  Future<void> _fetchAndNavigate(String query, {required bool isBarcode}) async {
    try {
      final String? token = await AuthService.getToken();
      final String endpoint = isBarcode
          ? '/product/search/barcode/$query'
          : '/product/search/name/$query';
      
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> product = json.decode(response.body);
        Navigator.push(
          context,
          DetailPageRoute(page: ProductDetailPage(product: product)),
        );
      } else {
        _showErrorSnackBar('Produk tidak ditemukan. Silakan coba dengan nama atau kode barcode yang lain.');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Gagal terhubung ke server. Periksa koneksi internet Anda.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: SvgPicture.asset(
            'assets/tm 1.svg',
            width: 90,
            color: Color(0xFFE31837),
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
                
                SizedBox(height: isKeyboardVisible ? 8 : 16),

                // Scan Button
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE31837), Color(0xFFD10000)],
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
                      _isLoading ? 'Memuat...' : 'Scan Barcode',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                                color: _searchError != null ? Colors.red : Colors.grey[300]!,
                                width: _searchError != null ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: _searchError != null ? [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ] : null,
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Masukkan nama produk atau barcode',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            _searchController.clear();
                                            _searchError = null;
                                          });
                                        },
                                      )
                                    : null,
                              ),
                              onChanged: (value) {
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
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _searchError!,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
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
                
                SizedBox(height: isKeyboardVisible ? 8 : 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
