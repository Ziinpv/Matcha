// lib/onboarding_screen.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/user_service.dart';
import '../services/cloudinary_service.dart';
import '../services/media_service.dart';
import '../models/media_model.dart';
import 'main_tab_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final UserService _userService = UserService();
  final CloudinaryService _cloudinary = CloudinaryService();
  final MediaService _mediaService = MediaService();
  final ImagePicker _picker = ImagePicker();

  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Controllers
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _interestsCtrl = TextEditingController();

  // Form data
  String? _gender;
  DateTime? _birthdate;
  String? _avatarUrl;
  bool _uploadingImage = false;
  bool _saving = false;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    _interestsCtrl.dispose();
    super.dispose();
  }

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

  bool _canProceedToNext() {
    switch (_currentStep) {
      case 0: // Thông tin cơ bản
        return _nameCtrl.text.trim().isNotEmpty &&
            _gender != null &&
            _gender!.isNotEmpty &&
            _birthdate != null;
      case 1: // Địa điểm
        return _locationCtrl.text.trim().isNotEmpty;
      case 2: // Sở thích
        return _interestsCtrl.text.trim().isNotEmpty;
      case 3: // Giới thiệu & Avatar (tùy chọn)
        return true;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (!_canProceedToNext()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
    );
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() => _saving = true);

    try {
      final interestsList = _interestsCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final update = {
        'name': _nameCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'interests': interestsList,
        'gender': _gender ?? '',
        'avatar_url': _avatarUrl ?? '',
        'profile_completed': true, // Đã hoàn thiện qua onboarding
      };

      if (_birthdate != null) {
        update['birthdate'] = Timestamp.fromDate(_birthdate!);
      }

      await _userService.updateUser(_uid, update);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainTabScreen(initialIndex: 0)),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi lưu hồ sơ: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDEFF3),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? const Color(0xFFFF4B91)
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  _buildStep1BasicInfo(),
                  _buildStep2Location(),
                  _buildStep3Interests(),
                  _buildStep4BioAndAvatar(),
                ],
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFFFF4B91)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Quay lại',
                          style: TextStyle(
                            color: Color(0xFFFF4B91),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: _currentStep == 0 ? 1 : 1,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4B91),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _currentStep < 3 ? 'Tiếp theo' : 'Hoàn thành',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 1: Thông tin cơ bản
  Widget _buildStep1BasicInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Thông tin cơ bản',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy cho chúng tôi biết một chút về bạn',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 32),

          // Tên
          const Text(
            'Họ và tên *',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              hintText: 'Nhập họ và tên của bạn',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Giới tính
          const Text(
            'Giới tính *',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            hint: const Text('Chọn giới tính'),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Nam')),
              DropdownMenuItem(value: 'female', child: Text('Nữ')),
              DropdownMenuItem(value: 'other', child: Text('Khác')),
            ],
            onChanged: (v) => setState(() => _gender = v),
          ),

          const SizedBox(height: 24),

          // Ngày sinh
          const Text(
            'Ngày sinh *',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _chooseBirthDate,
            child: AbsorbPointer(
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Chọn ngày sinh',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                controller: TextEditingController(
                  text: _birthdate != null
                      ? '${_birthdate!.day}/${_birthdate!.month}/${_birthdate!.year}'
                      : '',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Step 2: Địa điểm
  Widget _buildStep2Location() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Địa điểm',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bạn đang ở đâu?',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Thành phố / Tỉnh *',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _locationCtrl,
            decoration: InputDecoration(
              hintText: 'Ví dụ: Hà Nội, TP. Hồ Chí Minh',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.location_on),
            ),
          ),
        ],
      ),
    );
  }

  // Step 3: Sở thích
  Widget _buildStep3Interests() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Sở thích',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bạn thích làm gì?',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Sở thích của bạn *',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _interestsCtrl,
            decoration: InputDecoration(
              hintText: 'Ví dụ: Du lịch, Ẩm thực, Thể thao, Phim ảnh',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.favorite),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          const Text(
            'Lưu ý: Ngăn cách các sở thích bằng dấu phẩy (,)',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }

  // Step 4: Giới thiệu & Avatar
  Widget _buildStep4BioAndAvatar() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Hoàn thiện hồ sơ',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Thêm ảnh đại diện và giới thiệu về bản thân',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 32),

          // Avatar
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      _avatarUrl != null && _avatarUrl!.isNotEmpty
                          ? NetworkImage(_avatarUrl!)
                          : null,
                  child: _avatarUrl == null || _avatarUrl!.isEmpty
                      ? const Icon(Icons.person, size: 60, color: Colors.grey)
                      : null,
                ),
                InkWell(
                  onTap: _uploadingImage ? null : _pickImageAndUpload,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF4B91),
                      shape: BoxShape.circle,
                    ),
                    child: _uploadingImage
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Bio
          const Text(
            'Giới thiệu về bản thân',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _bioCtrl,
            decoration: InputDecoration(
              hintText: 'Viết một vài dòng về bản thân bạn...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            maxLines: 5,
          ),
        ],
      ),
    );
  }
}

