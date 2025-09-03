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
  final Function(int)? onIndexChanged;
  
  const CustomNavbar({
    Key? key, 
    this.selectedIndex = 0,
    this.onIndexChanged,
  }) : super(key: key);

  @override
  State<CustomNavbar> createState() => _CustomNavbarState();
}

class _CustomNavbarState extends State<CustomNavbar> {
  void _navigateToPage(BuildContext context, int index) {
    if (widget.onIndexChanged != null) {
      widget.onIndexChanged!(index);
    } else {
      // Fallback ke navigation biasa jika tidak ada callback
      switch (index) {
        case 0:
          Navigator.pushAndRemoveUntil(
            context,
            SettingsSlideRoute(page: HomePage(), isFromRight: false),
            (route) => false,
          );
          break;
        case 2:
          Navigator.push(
            context,
            SettingsSlideRoute(
                page: const SettingsPage(), isFromRight: true),
          );
          break;
      }
    }
  }

  Future<void> scanBarcode() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Warna garis
        'Batal', // Tombol cancel
        true, // Flash aktif
        ScanMode.BARCODE,
      );

      if (!mounted) return; // Pastikan widget masih aktif
      if (barcodeScanRes == '-1') return;

      // Sama seperti home_page: ambil token dan fetch data
      final String? token = await AuthService.getToken();
      final url = Uri.parse(
          '${ApiConfig.baseUrl}/product/search/barcode/$barcodeScanRes');
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFFD10000),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home
          _buildNavItem(
            icon: Icons.home,
            label: 'Home',
            index: 0,
            isSelected: widget.selectedIndex == 0,
            onTap: () {
              if (widget.selectedIndex != 0) {
                _navigateToPage(context, 0);
              }
            },
          ),

          // Tombol Scan QR
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
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
          _buildNavItem(
            icon: Icons.person,
            label: 'Profile',
            index: 2,
            isSelected: widget.selectedIndex == 2,
            onTap: () {
              if (widget.selectedIndex != 2) {
                _navigateToPage(context, 2);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Color(0xFFFF9088),
                size: isSelected ? 28 : 24,
              ),
            ),
            SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected ? Colors.white : Color(0xFFFF9088),
                fontSize: isSelected ? 12 : 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
