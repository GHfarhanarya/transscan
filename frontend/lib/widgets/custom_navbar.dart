import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../pages/settings.dart';
import '../pages/home_page.dart';
import '../pages/product_detail_page.dart';
import '../utils/page_transition.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';
import '../config/api_config.dart';


class CustomNavbar extends StatefulWidget {
  final int selectedIndex;
  const CustomNavbar({Key? key, this.selectedIndex = 0}) : super(key: key);

  @override
  State<CustomNavbar> createState() => _CustomNavbarState();
}

class _CustomNavbarState extends State<CustomNavbar> {
  bool _isLoading = false;

  Future<void> scanBarcode() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Warna garis
        'Batal',   // Tombol cancel
        true,      // Flash aktif
        ScanMode.BARCODE,
      );

      if (!mounted) return; // Pastikan widget masih aktif
      if (barcodeScanRes == '-1') return;

      // Sama seperti home_page: ambil token dan fetch data
      final String? token = await AuthService.getToken();
      final url = Uri.parse('${ApiConfig.baseUrl}/product/search/barcode/$barcodeScanRes');
      final res = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> product = json.decode(res.body);

        // Navigasi ke halaman detail produk
        Navigator.push(
          context,
          DetailPageRoute(
            page: ProductDetailPage(product: product),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFD10000),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home
          IconButton(
            icon: Icon(
              Icons.home,
              color: widget.selectedIndex == 0 ? Color(0xFFFFFFFF) : Color(0xFFFF9088),
              size: widget.selectedIndex == 0 ? 36 : 28,
            ),
            onPressed: () {
              if (widget.selectedIndex != 0) {
                Navigator.pushAndRemoveUntil(
                  context,
                  SettingsSlideRoute(page: HomePage(), isFromRight: false),
                  (route) => false,
                );
              }
            },
          ),

          // Tombol Scan QR
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.qr_code_scanner,
                color: Color(0xFFD10000),
                size: 32,
              ),
              onPressed: scanBarcode,
            ),
          ),

          // Settings
          IconButton(
            icon: Icon(
              Icons.person,
              color: widget.selectedIndex == 2 ? Color(0xFFFFFFFF) : Color(0xFFFF9088),
              size: widget.selectedIndex == 2 ? 36 : 28,
            ),
            onPressed: () {
              if (widget.selectedIndex != 2) {
                Navigator.push(
                  context,
                  SettingsSlideRoute(page: const SettingsPage(), isFromRight: true),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
