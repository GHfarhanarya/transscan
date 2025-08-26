import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class HybridScannerService {
  static final TextRecognizer _textRecognizer = GoogleMlKit.vision.textRecognizer();
  static final BarcodeScanner _barcodeScanner = GoogleMlKit.vision.barcodeScanner();

  /// Hybrid scanning method: Try barcode first, then OCR if barcode fails
  static Future<Map<String, dynamic>?> performHybridScan() async {
    try {
      // Step 1: Try barcode scanning first
      print('🔍 Starting hybrid scan - attempting barcode first...');
      
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 
        'Cancel', 
        true, 
        ScanMode.BARCODE
      );

      if (barcodeScanRes != '-1' && barcodeScanRes.isNotEmpty) {
        print('✅ Barcode detected: $barcodeScanRes');
        
        // Try to find product by barcode
        var barcodeResult = await _searchProductByBarcode(barcodeScanRes);
        if (barcodeResult != null) {
          return {
            'success': true,
            'method': 'barcode',
            'data': barcodeResult,
            'query': barcodeScanRes
          };
        }
        
        print('⚠️ Product not found with barcode, falling back to OCR...');
      } else {
        print('⚠️ No barcode detected, falling back to OCR...');
      }

      // Step 2: If barcode fails, use OCR to read text from package
      print('📸 Starting OCR text recognition...');
      var ocrResult = await _performOCRScan();
      
      if (ocrResult != null) {
        return {
          'success': true,
          'method': 'ocr',
          'data': ocrResult['product'],
          'query': ocrResult['text'],
          'confidence': ocrResult['confidence']
        };
      }

      return {
        'success': false,
        'method': 'hybrid',
        'message': 'Tidak dapat menemukan produk dengan barcode maupun OCR'
      };

    } catch (e) {
      print('❌ Error in hybrid scan: $e');
      return {
        'success': false,
        'method': 'hybrid',
        'message': 'Terjadi kesalahan saat scanning: $e'
      };
    }
  }

  /// Search product by barcode
  static Future<Map<String, dynamic>?> _searchProductByBarcode(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/products/barcode/$barcode'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      return null;
    } catch (e) {
      print('Error searching by barcode: $e');
      return null;
    }
  }

  /// Perform OCR scanning using camera
  static Future<Map<String, dynamic>?> _performOCRScan() async {
    try {
      // Take a photo using camera
      String imagePath = await _captureImage();
      if (imagePath.isEmpty) return null;

      // Process image with ML Kit
      final inputImage = InputImage.fromFilePath(imagePath);
      
      // Extract text from image
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      if (recognizedText.text.isEmpty) {
        print('No text detected in image');
        return null;
      }

      print('📝 Text detected: ${recognizedText.text}');

      // Search for products based on extracted text
      var productResult = await _searchProductByText(recognizedText.text);
      
      // Clean up image file
      try {
        await File(imagePath).delete();
      } catch (e) {
        print('Could not delete temp image: $e');
      }

      return productResult;

    } catch (e) {
      print('Error in OCR scan: $e');
      return null;
    }
  }

  /// Capture image using camera
  static Future<String> _captureImage() async {
    try {
      // Use barcode scanner to capture image (fallback method)
      String result = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.DEFAULT, // This allows general camera capture
      );
      
      // For now, we'll use a placeholder - in real implementation,
      // you might want to implement a custom camera interface
      return result != '-1' ? result : '';
      
    } catch (e) {
      print('Error capturing image: $e');
      return '';
    }
  }

  /// Search products by extracted text using fuzzy matching
  static Future<Map<String, dynamic>?> _searchProductByText(String extractedText) async {
    try {
      // Clean and prepare text for searching
      List<String> keywords = _extractKeywords(extractedText);
      
      print('🔍 Searching with keywords: $keywords');

      // Try each keyword combination
      for (String keyword in keywords) {
        if (keyword.length >= 3) { // Only search for meaningful keywords
          var result = await _searchProductByKeyword(keyword);
          if (result != null) {
            return {
              'product': result,
              'text': extractedText,
              'keyword': keyword,
              'confidence': _calculateConfidence(keyword, extractedText)
            };
          }
        }
      }

      return null;
    } catch (e) {
      print('Error searching by text: $e');
      return null;
    }
  }

  /// Extract meaningful keywords from OCR text
  static List<String> _extractKeywords(String text) {
    // Clean text
    String cleanText = text
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Remove special characters
        .replaceAll(RegExp(r'\s+'), ' ') // Replace multiple spaces
        .trim()
        .toLowerCase();

    List<String> words = cleanText.split(' ');
    List<String> keywords = [];

    // Filter out common words and short words
    Set<String> stopWords = {
      'the', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with',
      'by', 'dari', 'dan', 'atau', 'yang', 'ini', 'itu', 'untuk', 'dengan',
      'kg', 'gr', 'ml', 'liter', 'pcs', 'buah', 'kemasan', 'berat', 'netto'
    };

    for (String word in words) {
      if (word.length >= 3 && !stopWords.contains(word)) {
        keywords.add(word);
      }
    }

    // Also try combinations of 2-3 words
    for (int i = 0; i < words.length - 1; i++) {
      String combination = '${words[i]} ${words[i + 1]}';
      if (combination.length >= 6) {
        keywords.add(combination);
      }
    }

    return keywords;
  }

  /// Search product by individual keyword
  static Future<Map<String, dynamic>?> _searchProductByKeyword(String keyword) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/products/search/${Uri.encodeComponent(keyword)}'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['product'] != null) {
          return data;
        }
      }
      return null;
    } catch (e) {
      print('Error searching by keyword: $e');
      return null;
    }
  }

  /// Calculate confidence score for OCR match
  static double _calculateConfidence(String keyword, String fullText) {
    double confidence = 0.5; // Base confidence

    // Increase confidence based on keyword length
    if (keyword.length >= 5) confidence += 0.2;
    if (keyword.length >= 8) confidence += 0.1;

    // Increase confidence if keyword appears multiple times
    int occurrences = fullText.toLowerCase().split(keyword.toLowerCase()).length - 1;
    if (occurrences > 1) confidence += 0.1;

    // Increase confidence for brand-like keywords (uppercase in original)
    if (keyword == keyword.toUpperCase() && keyword.length >= 3) {
      confidence += 0.1;
    }

    return confidence.clamp(0.0, 1.0);
  }

  /// Dispose resources
  static void dispose() {
    _textRecognizer.close();
    _barcodeScanner.close();
  }
}
