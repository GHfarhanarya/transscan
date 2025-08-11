import 'package:flutter/material.dart';
import '../config/api_config.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'TRANSRETAIL',
          style: TextStyle(
            color: Colors.blue[700],
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Product Image Section
          Container(
            width: double.infinity,
            height: 300,
            color: Colors.white,
            child: Center(
              child: Container(
                width: 200,
                height: 250,
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
                child: product['image'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product['image'],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.inventory_2,
                              size: 80,
                              color: Colors.grey[400],
                            );
                          },
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

          // Product Information Section
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product['name'] ?? 'Nama Produk',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Barcode
                  Text(
                    product['barcode'] ?? '',
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
                        'Rp ${_formatPrice(product['pricePromo'])}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(width: 10),
                      if (product['priceNormal'] != product['pricePromo'])
                        Text(
                          'Rp ${_formatPrice(product['priceNormal'])}',
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
                    'Harga Normal: Rp ${_formatPrice(product['priceNormal'])}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Stock Information
                  Row(
                    children: [
                      Text(
                        'Stock: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${product['stock']} pcs',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  Spacer(),

                  // Bottom Section with Logo and Scan Button
                  Column(
                    children: [
                      // TransMart Logo
                      Text(
                        'TRANSmart',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Scan Button
                      Container(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          icon: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.qr_code_scanner,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                          label: Text(
                            'Scan Lagi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(dynamic price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
