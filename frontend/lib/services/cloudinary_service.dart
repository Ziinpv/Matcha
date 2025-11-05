// lib/services/cloudinary_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CloudinaryService {
  final String cloudName = 'ddria59vb';
  final String uploadPreset = 'dating_app';

  // Upload ảnh lên Cloudinary - sử dụng MultipartRequest cho cả web và mobile
  // để đảm bảo filename được sanitize đúng cách
  Future<String?> uploadImage(Uint8List imageBytes, {String? filename}) async {
    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      // Sanitize filename: loại bỏ ký tự đặc biệt gây lỗi Cloudinary
      final sanitizedFileName = _sanitizeFileName(filename);
      
      print('📤 Uploading to Cloudinary:');
      print('   - Original filename: ${filename ?? "N/A"}');
      print('   - Sanitized filename: $sanitizedFileName');
      print('   - Cloud name: $cloudName');
      print('   - Upload preset: $uploadPreset');
      print('   - Platform: ${kIsWeb ? "web" : "mobile"}');
      
      // Sử dụng MultipartRequest cho cả web và mobile để kiểm soát filename
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: sanitizedFileName,
        ));

      print('📡 Sending multipart request...');
      final streamedResponse = await request.send();
      final respStr = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
        final data = json.decode(respStr);
        final secureUrl = data['secure_url'] as String?;
        if (secureUrl != null && secureUrl.isNotEmpty) {
          print('✅ Upload success: $secureUrl');
          return secureUrl;
        } else {
          print('❌ Upload response missing secure_url');
          print('   Response: $data');
          return null;
        }
      } else {
        print('❌ Upload failed (${streamedResponse.statusCode})');
        print('   Response body: $respStr');
        
        // Parse error message từ Cloudinary
        try {
          final errorData = json.decode(respStr) as Map<String, dynamic>;
          if (errorData.containsKey('error')) {
            final error = errorData['error'];
            if (error is Map && error.containsKey('message')) {
              print('❌ Cloudinary error message: ${error['message']}');
            } else {
              print('❌ Cloudinary error: $error');
            }
          }
        } catch (parseError) {
          print('⚠️ Could not parse error response: $parseError');
        }
        
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ Cloudinary upload error: $e');
      print('   Stack trace: $stackTrace');
      return null;
    }
  }

  // Sanitize filename để loại bỏ ký tự đặc biệt
  String _sanitizeFileName(String? filename) {
    if (filename == null || filename.isEmpty) {
      return 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    }
    
    // Loại bỏ đường dẫn nếu có
    String name = filename.split('/').last.split('\\').last;
    
    // Loại bỏ ký tự đặc biệt: /, \, :, và các ký tự không phải alphanumeric, dash, dot, underscore
    name = name
        .replaceAll(RegExp(r'[\/\\:]'), '_')  // Thay /, \, : bằng _
        .replaceAll(RegExp(r'[^\w\-\.]'), '_') // Thay ký tự đặc biệt khác bằng _
        .replaceAll(RegExp(r'_+'), '_')        // Gộp nhiều _ liên tiếp thành 1
        .replaceAll(RegExp(r'^_+|_+$'), '');  // Loại bỏ _ ở đầu và cuối
    
    // Đảm bảo có extension
    if (!name.contains('.')) {
      name = '${name}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    }
    
    // Đảm bảo tên file không quá dài (Cloudinary có giới hạn)
    if (name.length > 100) {
      final extension = name.split('.').last;
      name = '${name.substring(0, 90)}_${DateTime.now().millisecondsSinceEpoch}.$extension';
    }
    
    return name;
  }

  // Helper method để upload từ XFile (tương thích với image_picker)
  Future<String?> uploadImageFromXFile(XFile xFile) async {
    print('📥 Starting upload from XFile: "${xFile.name}"');
    try {
      final bytes = await xFile.readAsBytes();
      print('   File size: ${bytes.length} bytes');
      
      // Upload với filename gốc, sanitize sẽ được xử lý trong uploadImage
      final result = await uploadImage(bytes, filename: xFile.name);
      
      if (result != null) {
        print('✅ Upload from XFile successful');
      } else {
        print('❌ Upload from XFile failed');
      }
      
      return result;
    } catch (e, stackTrace) {
      print('❌ Error in uploadImageFromXFile: $e');
      print('   Stack trace: $stackTrace');
      return null;
    }
  }
}
