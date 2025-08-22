import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../widgets/custom_navbar.dart';
import '../utils/page_transition.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String? userRole;
  
  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('role');
    });
  }

  bool _canViewStock() {
    return userRole == 'admin' || userRole == 'management';
  }

  // Fungsi Print/cetak
  Future<void> printTransmartLabel(Map<String, dynamic> product) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(80 * PdfPageFormat.mm,
            50 * PdfPageFormat.mm), // ukuran label 8x5 cm
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 1),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // HEADER MERAH (brand Transmart)
                pw.Container(
                  color: PdfColors.red,
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    "TRANSMART",
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),

                pw.SizedBox(height: 4),

                // Nama Produk
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 6),
                  child: pw.Text(
                    product['item_name'] ?? "Nama Produk",
                    maxLines: 2,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),

                pw.Spacer(),

                // Harga Promo
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 6),
                  child: pw.Text(
                    "Rp ${_formatPrice(product['harga_promo'])}",
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red,
                    ),
                  ),
                ),

                // Harga Normal Dicoret (kalau ada promo)
                if (product['normal_price'] != product['harga_promo'])
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6),
                    child: pw.Text(
                      "Rp ${_formatPrice(product['normal_price'])}",
                      style: pw.TextStyle(
                        fontSize: 12,
                        decoration: pw.TextDecoration.lineThrough,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ),

                pw.SizedBox(height: 6),

                // Barcode
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 6),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        "Barcode: ${product['barcode'] ?? '-'}",
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 4),
              ],
            ),
          );
        },
      ),
    );

    // Print atau Preview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFD10000)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  blurRadius: 6,
                )
              ]),
          child: Image.asset('assets/TransRetail.png'),
          height: 26,
        ),
        centerTitle: false,
      ),
      bottomNavigationBar: CustomNavbar(selectedIndex: 1),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04,
            vertical: MediaQuery.of(context).size.height * 0.02),
        child: Column(
          children: [
            // Product Image Section
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.32,
              color: Colors.white,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.28,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
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
                  child: widget.product['image'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.product['image'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        )
                      : Icon(
                          Icons.inventory_2,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            // Product Information Section
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Detail Product Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Product Name
                          Text(
                            widget.product['item_name'] ?? 'Nama Produk',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8),
                          // Item Code
                          // Text(
                          //   'Kode: ${widget.product['item_code'] ?? '-'}',
                          //   style: TextStyle(
                          //     fontSize: 14,
                          //     color: Colors.grey[600],
                          //   ),
                          // ),

                           if (_canViewStock())
                            Row(
                              children: [
                                Text(
                                  'Kode item: ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '${widget.product['item_code'] ?? '-'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: 4),

                          // Barcode
                          Text(
                            widget.product['barcode'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 20),
                          // Price Section
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Rp ${_formatPrice(widget.product['harga_promo'] ?? widget.product['normal_price'])}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              SizedBox(width: 10),
                              if (widget.product['harga_promo'] != null && 
                                  widget.product['normal_price'] != null &&
                                  widget.product['normal_price'] != widget.product['harga_promo'])
                                Text(
                                  'Rp ${_formatPrice(widget.product['normal_price'])}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[500],
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 8),
                          // Normal Price Label
                          Text(
                            'Harga Normal: Rp ${_formatPrice(widget.product['normal_price'] ?? 0)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 16),
                          // Stock Information - only for admin and management
                          if (_canViewStock())
                            Row(
                              children: [
                                Text(
                                  'Stock: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _getStockColor(widget.product['stock']),
                                  ),
                                ),
                                Text(
                                  '${widget.product['stock']} pcs',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _getStockColor(widget.product['stock']),
                                  ),
                                ),
                              ],
                            )
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    // Tombol Cetak/Print
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.1),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFD10000),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: Size(double.infinity, 48),
                          elevation: 2,
                        ),
                        icon: Icon(Icons.print, size: 24),
                        label: Text('Cetak/Print',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          printTransmartLabel(widget.product);
                        },
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  } // Akhir dari build
} // Akhir dari class ProductDetailPage

// Format harga Indonesia
String _formatPrice(dynamic price) {
  if (price == null) return '0,00';
  
  try {
    String strPrice = double.parse(price.toString()).toStringAsFixed(2);
    List<String> parts = strPrice.split('.');

    // Tambahkan titik setiap 3 digit dari belakang
    String integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );

    // Ganti titik desimal jadi koma
    return '$integerPart,${parts[1]}';
  } catch (e) {
    print('Error formatting price: $price');
    return '0,00';
  }
}

// Warna stock
Color _getStockColor(int stock) {
  if (stock < 20) {
    return Colors.red.shade700; // kritis
  } else if (stock < 50) {
    return Colors.orange.shade600; // warning
  } else {
    return Colors.green.shade700; // aman
  }
}
