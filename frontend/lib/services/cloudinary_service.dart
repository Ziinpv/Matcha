// lib/services/cloudinary_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName = 'ddria59vb';
  final String uploadPreset = 'dating_app';

  Future<String?> uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(respStr);
        print('✅ Uploaded to Cloudinary: ${data['secure_url']}');
        return data['secure_url'];
      } else {
        print('❌ Upload failed (${response.statusCode}): $respStr');
        return null;
      }
    } catch (e) {
      print('⚠️ Cloudinary upload error: $e');
      return null;
    }
  }
}
