import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'product_detail_page.dart' as pdp;
import '../utils/page_transition.dart';

class ProductListPage extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final String searchQuery;

  const ProductListPage({
    Key? key,
    required this.products,
    required this.searchQuery,
  }) : super(key: key);

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
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

  bool _canViewSensitiveInfo() {
    return userRole == 'admin' || userRole == 'management';
  }

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
                    'Hasil pencarian untuk "${widget.searchQuery}"',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${widget.products.length} item',
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
              itemCount: widget.products.length,
              itemBuilder: (context, index) {
                final product = widget.products[index];
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      product['item_name'] ?? 'Unnamed Product',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        // Tampilkan item_code hanya untuk admin dan management
                        if (_canViewSensitiveInfo())
                          Row(
                            children: [
                              Icon(Icons.qr_code, size: 16, color: Colors.grey[600]),
                              SizedBox(width: 4),
                              Text(
                                'Kode: ${product['item_code'] ?? 'N/A'}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        if (product['variants_count'] != null && product['variants_count'] > 1)
                          Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(Icons.inventory_2_outlined, 
                                     size: 16, 
                                     color: Colors.blue[700]),
                                SizedBox(width: 4),
                                Text(
                                  '${product['variants_count']} varian',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                // Tampilkan stok hanya untuk admin dan management
                                if (_canViewSensitiveInfo())
                                  Text(
                                    ' • Total stok: ${product['stock'] ?? 0}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
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
