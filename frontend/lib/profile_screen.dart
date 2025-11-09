// lib/screens/profile_screen.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/cloudinary_service.dart';
import '../services/media_service.dart';
import '../models/media_model.dart';
import '../models/user_model.dart';
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
  final UserService _userService = UserService();

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
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _loading = true);
    try {
      final user = await _userService.getUserById(_uid);

      if (user != null) {
        _nameCtrl.text = user.name ?? '';
        _bioCtrl.text = user.bio ?? '';
        _locationCtrl.text = user.location ?? '';
        _interestsCtrl.text = user.interests?.join(', ') ?? '';
        _gender = user.gender?.isNotEmpty == true ? user.gender : null;
        _avatarUrl = user.avatarUrl?.isNotEmpty == true ? user.avatarUrl : null;
        _birthdate = user.birthdate;
      } else {
        // Nếu user chưa tồn tại → tạo mới
        final current = FirebaseAuth.instance.currentUser;
        await _userService.createUser(
          UserModel(
            uid: _uid,
            email: _email,
            name: current?.displayName ?? '',
            avatarUrl: current?.photoURL ?? '',
            location: '',
            bio: '',
            interests: [],
            gender: '',
            profileCompleted: false,
            createdAt: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi tải hồ sơ: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ===============================
  // 📸 Upload avatar + lưu media
  // ===============================
  Future<void> _pickImageAndUpload() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
      );
      if (picked == null) return;
      setState(() => _uploadingImage = true);

      final file = File(picked.path);
      final url = await _cloudinary.uploadImage(file);

      if (url != null) {
        setState(() => _avatarUrl = url);

        final mediaId = FirebaseFirestore.instance.collection('media').doc().id;
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
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi upload: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
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
    if (picked != null) setState(() => _birthdate = picked);
  }

  // ===============================
  // 💾 Lưu và hoàn thiện hồ sơ
  // ===============================
  Future<void> _saveProfile() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên')));
      return;
    }

    setState(() => _loading = true);

    try {
      final interestsList = _interestsCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final update = {
        'name': name,
        'bio': _bioCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'interests': interestsList,
        'gender': _gender ?? '',
        'avatar_url': _avatarUrl ?? '',
      };
      if (_birthdate != null) {
        update['birthdate'] = _birthdate as Object; // lưu DateTime trực tiếp
      }

      // Kiểm tra hồ sơ đầy đủ → set profile_completed = true
      final bool hasCompleteProfile =
          name.isNotEmpty &&
              _gender != null &&
              _gender!.isNotEmpty &&
              _birthdate != null &&
              interestsList.isNotEmpty &&
              _locationCtrl.text.trim().isNotEmpty;

      if (hasCompleteProfile) {
        update['profile_completed'] = true;
      }

      await _userService.updateUser(_uid, update);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              hasCompleteProfile ? 'Hồ sơ đã hoàn thiện!' : 'Đã lưu hồ sơ.'),
        ),
      );

      setState(() => _isEditing = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi lưu hồ sơ: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ===============================
  // Avatar + UI
  // ===============================
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
                setState(() => _isEditing = true);
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
            _buildProfileForm(),
            const SizedBox(height: 20),
            _buildSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          _buildAvatar(),
          const SizedBox(height: 12),
          Text(_email, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Tên hiển thị'),
            enabled: _isEditing,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: const InputDecoration(labelText: 'Giới tính'),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Nam')),
              DropdownMenuItem(value: 'female', child: Text('Nữ')),
              DropdownMenuItem(value: 'other', child: Text('Khác')),
            ],
            onChanged: _isEditing ? (v) => setState(() => _gender = v) : null,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _isEditing ? _chooseBirthDate : null,
            child: AbsorbPointer(
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Ngày sinh'),
                controller: TextEditingController(
                    text: _birthdate != null
                        ? '${_birthdate!.day}/${_birthdate!.month}/${_birthdate!.year}'
                        : ''),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _bioCtrl,
            decoration: const InputDecoration(labelText: 'Giới thiệu ngắn'),
            maxLines: 3,
            enabled: _isEditing,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _locationCtrl,
            decoration: const InputDecoration(labelText: 'Địa điểm'),
            enabled: _isEditing,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _interestsCtrl,
            decoration: const InputDecoration(
                labelText: 'Sở thích (ngăn cách bằng dấu ,)'),
            enabled: _isEditing,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cài đặt nhanh',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
          ),
        ],
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
