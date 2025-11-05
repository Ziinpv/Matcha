// lib/screens/profile_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';
import '../services/cloudinary_service.dart';
import '../services/media_service.dart';
import '../models/media_model.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final CloudinaryService _cloudinary = CloudinaryService();
  final MediaService _mediaService = MediaService();

  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _interestsCtrl = TextEditingController();

  String? _gender;
  DateTime? _birthdate;
  String? _avatarUrl;
  bool _isEditing = false;
  bool _loading = false;
  bool _uploadingImage = false;

  final _picker = ImagePicker();

  String get _uid => FirebaseAuth.instance.currentUser!.uid;
  String get _email => FirebaseAuth.instance.currentUser!.email ?? '';

  @override
  void initState() {
    super.initState();
    _loadUserDoc();
  }

  Future<void> _loadUserDoc() async {
    setState(() => _loading = true);
    try {
      final doc = FirebaseFirestore.instance.collection('users').doc(_uid);
      final snap = await doc.get();
      if (snap.exists) {
        final data = snap.data()!;
        _nameCtrl.text = data['name'] ?? '';
        _bioCtrl.text = data['bio'] ?? '';
        _locationCtrl.text = data['location'] ?? '';
        if (data['interests'] != null && data['interests'] is List) {
          _interestsCtrl.text = (data['interests'] as List)
              .map((e) => e.toString())
              .join(', ');
        }
        _gender = (data['gender'] as String?)?.isNotEmpty == true
            ? data['gender']
            : null;
        _avatarUrl = (data['avatar_url'] as String?)?.isNotEmpty == true
            ? data['avatar_url']
            : null;
        if (data['birthdate'] != null && data['birthdate'] is Timestamp) {
          _birthdate = (data['birthdate'] as Timestamp).toDate();
        }
      } else {
        final user = FirebaseAuth.instance.currentUser;
        await doc.set({
          'user_id': _uid,
          'email': _email,
          'name': user?.displayName ?? '',
          'avatar_url': user?.photoURL ?? '',
          'location': '',
          'bio': '',
          'interests': [],
          'gender': '',
          'created_at': FieldValue.serverTimestamp(),
          'role': 'user',
        }, SetOptions(merge: true));
        _nameCtrl.text = user?.displayName ?? '';
        _avatarUrl = user?.photoURL;
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Lỗi load profile: $e")));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // ===============================
  // 📸 Upload avatar + Lưu media
  // ===============================
  Future<void> _pickImageAndUpload() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
      );
      if (picked == null) return;
      setState(() => _uploadingImage = true);

      final url = await _cloudinary.uploadImageFromXFile(picked);

      if (url != null) {
        setState(() => _avatarUrl = url);

        // 🔹 Lưu vào Firestore collection "media"
        final mediaId =
            FirebaseFirestore.instance.collection('media').doc().id;
        final media = MediaModel(
          mediaId: mediaId,
          userId: _uid,
          url: url,
          type: 'image',
          uploadedAt: DateTime.now(),
        );
        await _mediaService.addMedia(media);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload ảnh thành công')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload ảnh thất bại')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi upload: $e')));
    } finally {
      setState(() => _uploadingImage = false);
    }
  }

  Future<void> _chooseBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthdate ?? DateTime(now.year - 20),
      firstDate: DateTime(now.year - 90),
      lastDate: DateTime(now.year - 13),
    );
    if (picked != null) {
      setState(() => _birthdate = picked);
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập tên')));
      return;
    }

    setState(() => _loading = true);
    try {
      final doc = FirebaseFirestore.instance.collection('users').doc(_uid);

      final interestsList = _interestsCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final Map<String, dynamic> update = {
        'name': name,
        'bio': _bioCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'interests': interestsList,
        'gender': _gender ?? '',
        'avatar_url': _avatarUrl ?? '',
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (_birthdate != null) {
        update['birthdate'] = Timestamp.fromDate(_birthdate!);
      }

      await doc.set(update, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã lưu hồ sơ thành công")),
        );
      }

      setState(() => _isEditing = false);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi lưu hồ sơ: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildAvatar() {
    final avatar = _avatarUrl;
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 56,
          backgroundColor: Colors.grey[200],
          backgroundImage:
          avatar != null && avatar.isNotEmpty ? NetworkImage(avatar) : null,
          child: avatar == null || avatar.isEmpty
              ? const Icon(Icons.person, size: 56, color: Colors.grey)
              : null,
        ),
        if (_isEditing)
          Positioned(
            right: 0,
            bottom: 0,
            child: InkWell(
              onTap: _uploadingImage ? null : _pickImageAndUpload,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: _uploadingImage
                    ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.camera_alt, size: 18),
              ),
            ),
          )
      ],
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    _interestsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title:
        const Text('Hồ sơ của tôi', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit,
                color: Colors.black),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  _buildAvatar(),
                  const SizedBox(height: 12),
                  Text(_email, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      controller: _nameCtrl,
                      enabled: _isEditing,
                      decoration:
                      const InputDecoration(labelText: 'Họ và tên'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _gender,
                            decoration: const InputDecoration(
                                labelText: 'Giới tính'),
                            items: const [
                              DropdownMenuItem(
                                  value: 'male', child: Text('Nam')),
                              DropdownMenuItem(
                                  value: 'female', child: Text('Nữ')),
                              DropdownMenuItem(
                                  value: 'other', child: Text('Khác')),
                            ],
                            onChanged: _isEditing
                                ? (v) => setState(() => _gender = v)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: _isEditing ? _chooseBirthDate : null,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                  labelText: 'Ngày sinh'),
                              child: Text(
                                _birthdate != null
                                    ? '${_birthdate!.day}/${_birthdate!.month}/${_birthdate!.year}'
                                    : '-',
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      controller: _locationCtrl,
                      enabled: _isEditing,
                      decoration:
                      const InputDecoration(labelText: 'Địa chỉ'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      controller: _interestsCtrl,
                      enabled: _isEditing,
                      decoration: const InputDecoration(
                        labelText: 'Sở thích (ngăn cách bằng dấu phẩy)',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      controller: _bioCtrl,
                      enabled: _isEditing,
                      maxLines: 3,
                      decoration:
                      const InputDecoration(labelText: 'Giới thiệu'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_isEditing)
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton.icon(
                        onPressed: _saveProfile,
                        icon: const Icon(Icons.save),
                        label: const Text('Lưu hồ sơ'),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cài đặt nhanh',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _SettingsItem(
                      icon: Icons.settings,
                      title: 'Cài đặt chi tiết',
                      onTap: () {}),
                  _SettingsItem(
                      icon: Icons.shield,
                      title: 'An toàn & Bảo mật',
                      onTap: () {}),
                  _SettingsItem(
                    icon: Icons.logout,
                    title: 'Đăng xuất',
                    textColor: Colors.red,
                    onTap: () async {
                      await _authService.disconnect();
                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                              (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? textColor;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.black87),
      title: Text(title,
          style: TextStyle(
              color: textColor ?? Colors.black87,
              fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
