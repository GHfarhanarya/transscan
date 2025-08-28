import 'package:flutter/material.dart';
import 'product_detail_page.dart' as pdp;
import '../utils/page_transition.dart';

class ProductListPage extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final String searchQuery;

  const ProductListPage({
    Key? key,
    required this.products,
    required this.searchQuery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hasil Pencarian'),
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
      body: Column(
        children: [
          // Search Info
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey[600]),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hasil pencarian untuk "$searchQuery"',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${products.length} item',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // List Products
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      product['name'] ?? 'Unnamed Product',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Barcode: ${product['barcode'] ?? 'N/A'}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          DetailPageRoute(
                            page: pdp.ProductDetailPage(product: product),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Detail',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
