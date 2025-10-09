// lib/services/cloudinary_service.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  // Thay bằng thông tin Cloudinary của bạn:
  final String cloudName = 'ddria59vb';
  final String uploadPreset = 'dating_app';

  Future<String?> uploadImage(File imageFile) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamed = await request.send();
    final respStr = await streamed.stream.bytesToString();
    if (streamed.statusCode == 200 || streamed.statusCode == 201) {
      final Map data = json.decode(respStr);
      return data['secure_url'] as String?;
    } else {
      print('Cloudinary upload failed: $respStr');
      return null;
    }
  }
}
