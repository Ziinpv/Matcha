// lib/utils/hash_util.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';

String hashPassword(String password, {String? salt}) {
  // Bạn có thể thêm salt ổn định (user-specific) để tăng an toàn
  final toHash = (salt ?? '') + password;
  final bytes = utf8.encode(toHash);
  final digest = sha256.convert(bytes);
  return digest.toString(); // hex string
}
