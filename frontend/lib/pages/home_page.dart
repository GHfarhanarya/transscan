import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product_detail_page.dart';

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

  Future<void> scanBarcode() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);

      if (!mounted) return;

      // Untuk testing: tampilkan data dummy baik saat scan berhasil maupun dibatalkan
      if (barcodeScanRes == '-1') {
        // Jika dibatalkan, tetap tampilkan data dummy
        await _showDummyProduct();
      } else {
        // Jika ada hasil scan, coba fetch data real, jika gagal tampilkan dummy
        await _fetchProductAndNavigate(barcodeScanRes);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat scan: $e')),
      );
    }
  }

  Future<void> _showDummyProduct() async {
    // Daftar data dummy untuk testing
    List<Map<String, dynamic>> dummyProducts = [
      {
        'name': 'Le Minerale 600ml',
        'barcode': '8124354388',
        'priceNormal': 3000,
        'pricePromo': 2800,
        'stock': 125
      },
      {
        'name': 'Aqua 600ml',
        'barcode': '8996001600115',
        'priceNormal': 2500,
        'pricePromo': 2200,
        'stock': 89
      },
      {
        'name': 'Indomie Goreng',
        'barcode': '8999999037260',
        'priceNormal': 3500,
        'pricePromo': 3200,
        'stock': 156
      },
      {
        'name': 'Teh Botol Sosro 350ml',
        'barcode': '8999999501013',
        'priceNormal': 4000,
        'pricePromo': 3500,
        'stock': 78
      }
    ];

    // Pilih produk secara random
    final random = DateTime.now().millisecond % dummyProducts.length;
    Map<String, dynamic> selectedProduct = dummyProducts[random];

    // Simulasi loading
    await Future.delayed(Duration(milliseconds: 500));

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(product: selectedProduct),
      ),
    );
  }

  Future<void> _searchProduct() async {
    if (_searchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Masukkan nama produk atau barcode')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      String query = _searchController.text.trim().toLowerCase();

      // Untuk testing: tampilkan dummy product untuk berbagai query
      if (query.contains('le minerale') ||
          query.contains('minerale') ||
          query.contains('8124354388') ||
          query.contains('aqua') ||
          query.contains('8996001600115') ||
          query.contains('indomie') ||
          query.contains('8999999037260') ||
          query.contains('teh botol') ||
          query.contains('sosro') ||
          query.contains('8999999501013') ||
          query.contains('air mineral') ||
          query.contains('mie instan')) {
        await _showDummyProduct();
      } else {
        // Coba fetch dari API, jika gagal tampilkan dummy juga
        await _fetchProductAndNavigate(_searchController.text.trim());
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat mencari: $e')),
      );
    }
  }

  Future<void> _fetchProductAndNavigate(String query) async {
    try {
      var url = Uri.parse('http://192.168.137.1:3000/product/$query');
      var res = await http.get(url);

      if (!mounted) return;

      if (res.statusCode == 200) {
        Map<String, dynamic> product = json.decode(res.body);
        setState(() => _isLoading = false);

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      } else {
        // Jika produk tidak ditemukan, tampilkan data dummy untuk testing
        await _showDummyProduct();
      }
    } catch (e) {
      // Jika terjadi error (misal server tidak aktif), tampilkan data dummy
      await _showDummyProduct();
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
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
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
      appBar: AppBar(
        title: Text('TransMart Scanner'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (context) => [
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
              if (value == 'logout') {
                _showLogoutDialog();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            // Welcome Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 48,
                    color: Colors.red,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Selamat Datang di TransMart Scanner',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Scan barcode produk untuk melihat informasi lengkap',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Scan Button
            Container(
              height: 60,
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
                    : Icon(Icons.qr_code_scanner, size: 28),
                label: Text(
                  _isLoading ? 'Memuat...' : 'Scan Barcode',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ),
            SizedBox(height: 30),

            // Divider with "Atau" text
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
                    color: Colors.black.withOpacity(0.1),
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
                      Icon(Icons.search, color: Colors.red, size: 24),
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
                        hintText:
                            'Coba: Le Minerale, Aqua, Indomie, atau Teh Botol',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        hintStyle: TextStyle(color: Colors.grey[500]),
                      ),
                      onSubmitted: (_) => _searchProduct(),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Search Button
                  Container(
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
          ],
        ),
      ),
    );
  }
}
