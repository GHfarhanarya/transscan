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
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Color(0xFFD10000),
            Color(0xFFFF8585),
          ], stops: [
            0.5,
            1.0
          ])),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFFFFFFF)),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// ===== Product Image Section dengan Hero Animation =====
            Hero(
              tag: 'product-image-${widget.product['barcode']}',
              child: Container(
                height: MediaQuery.of(context).size.height * 0.35,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 25,
                      spreadRadius: 0,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: widget.product['image'] != null
                      ? Stack(
                          children: [
                            Image.network(
                              widget.product['image'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFE31837),
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.grey[100]!,
                                        Colors.grey[200]!,
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_not_supported,
                                          size: 60,
                                          color: Colors.grey[400],
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Gambar tidak tersedia',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Overlay gradient untuk effect
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.1),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFE31837).withOpacity(0.1),
                                Color(0xFFE31837).withOpacity(0.05),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFE31837).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    Icons.inventory_2,
                                    size: 80,
                                    color: Color(0xFFE31837),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Tidak ada gambar',
                                  style: TextStyle(
                                    color: Color(0xFFE31837),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ),

            SizedBox(height: 24),

            /// ===== Product Information Card =====
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 25,
                    spreadRadius: 0,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ===== Product Name =====
                  Text(
                    widget.product['item_name'] ??
                        widget.product['name'] ??
                        'Nama Produk',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),

                  SizedBox(height: 16),

                  /// ===== Barcode dengan style modern =====
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.qr_code,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          widget.product['barcode'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// ===== Item Code untuk admin/management =====
                  if (_canViewStock()) ...[
                    SizedBox(height: 12),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.inventory,
                            color: Colors.blue[600],
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Kode: ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            widget.product['item_code'] ?? '-',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 24),

                  /// ===== Price Section dengan design menarik =====
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFE31837).withOpacity(0.1),
                          Color(0xFFE31837).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Color(0xFFE31837).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.local_offer,
                              color: Color(0xFFE31837),
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Harga Produk',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE31837),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        /// ===== Current Price =====
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Rp ${_formatPrice(widget.product['harga_promo'] ?? widget.product['pricePromo'] ?? widget.product['normal_price'] ?? widget.product['priceNormal'])}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE31837),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 12),

                        /// ===== Normal Price Label with strikethrough if there's promo =====
                        Row(
                          children: [
                            Text(
                              'Harga Normal: ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Rp ${_formatPrice(widget.product['normal_price'] ?? 0)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                                decoration:
                                    (widget.product['harga_promo'] != null &&
                                            widget.product['normal_price'] !=
                                                null &&
                                            widget.product['normal_price'] !=
                                                widget.product['harga_promo'])
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  /// ===== Stock Information untuk admin/management =====
                  if (_canViewStock()) ...[
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getStockColor(widget.product['stock'] ?? 0)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getStockColor(widget.product['stock'] ?? 0)
                              .withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  _getStockColor(widget.product['stock'] ?? 0)
                                      .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.inventory_2,
                              color:
                                  _getStockColor(widget.product['stock'] ?? 0),
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stok Tersedia',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${widget.product['stock'] ?? 0} pcs',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _getStockColor(
                                      widget.product['stock'] ?? 0),
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color:
                                  _getStockColor(widget.product['stock'] ?? 0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getStockStatus(widget.product['stock'] ?? 0),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: 24),

            /// ===== Print Button dengan design modern =====
            Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE31837),
                    Color(0xFFD10000),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFE31837).withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                icon: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.print,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                label: Text(
                  'Cetak Label Harga',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                onPressed: () {
                  printTransmartLabel(widget.product);
                },
              ),
            ),

            SizedBox(height: 20),
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
  if (stock < 0) {
    return Colors.red.shade700;
  } else if (stock == 0) {
    return Colors.grey.shade600;
  } else if (stock < 21) {
    return Colors.orange.shade600; // warning
  } else {
    return Colors.green.shade700; // aman
  }
}

// Status stock untuk label
String _getStockStatus(int stock) {
  if (stock < 0) {
    return 'LOSS';
  } else if (stock == 0) {
    return 'HABIS';
  } else if (stock < 21) {
    return 'RENDAH';
  } else {
    return 'AMAN';
  }
}
