import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../services/user_service.dart';
import '../services/cloudinary_service.dart';
import '../main_tab_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0;
  bool _loading = false;

  XFile? _avatarFile;
  Uint8List? _avatarBytes;
  String? _avatarUrl;
  final _displayNameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  String? _gender; // 'male' | 'female' | 'other'
  final List<String> _interests = [];

  RangeValues _ageRange = const RangeValues(18, 35);
  String _preferredGender = 'any';
  double _maxDistance = 25;

  final _userService = UserService();
  final _cloudinary = CloudinaryService();

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _avatarFile = picked;
        _avatarBytes = bytes;
      });
    }
  }

  // Future<void> _uploadAvatarIfNeeded() async {
  //   if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
  //     print('✅ Avatar already uploaded: $_avatarUrl');
  //     return;
  //   }
  //   if (_avatarFile == null) {
  //     print('⚠️ No avatar file to upload');
  //     return;
  //   }
  //
  //   print('📤 Starting avatar upload...');
  //   //final url = await _cloudinary.uploadImageFromXFile(_avatarFile!);
  //
  //   if (url != null && url.isNotEmpty) {
  //     setState(() { _avatarUrl = url; });
  //     print('✅ Avatar uploaded successfully: $url');
  //   } else {
  //     print('❌ Avatar upload failed: url is null or empty');
  //     throw Exception('Không thể upload ảnh. Vui lòng thử lại.');
  //   }
  // }

  bool _validateCurrentStep() {
    if (_step == 0) {
      return _avatarFile != null || (_avatarUrl != null && _avatarUrl!.isNotEmpty);
    }
    if (_step == 1) {
      return _displayNameCtrl.text.trim().isNotEmpty && _gender != null;
    }
    if (_step == 2) {
      return _bioCtrl.text.trim().length >= 30;
    }
    if (_step == 3) {
      return _interests.isNotEmpty;
    }
    return true;
  }

  // Future<void> _submit() async {
  //   if (!_validateCurrentStep()) return;
  //   setState(() { _loading = true; });
  //   try {
  //     // Upload avatar trước và đảm bảo thành công
  //     // print('📤 Step 1: Uploading avatar...');
  //     // await _uploadAvatarIfNeeded();
  //
  //     // Kiểm tra lại avatar URL sau khi upload
  //     if (_avatarUrl == null || _avatarUrl!.isEmpty) {
  //       throw Exception('Chưa upload ảnh đại diện. Vui lòng chọn ảnh và thử lại.');
  //     }
  //
  //     print('✅ Step 2: Avatar URL validated: $_avatarUrl');
  //
  //     // Chuẩn bị payload
  //     final payload = {
  //       'avatar_url': _avatarUrl,
  //       'displayName': _displayNameCtrl.text.trim(),
  //       'bio': _bioCtrl.text.trim(),
  //       'gender': _gender,
  //       'interests': _interests,
  //       'preferences': {
  //         'preferredGender': _preferredGender,
  //         'minAge': _ageRange.start.round(),
  //         'maxAge': _ageRange.end.round(),
  //         'maxDistanceKm': _maxDistance.round(),
  //       },
  //     };
  //
  //     print('📤 Step 3: Sending complete-profile request with payload: ${payload.keys}');
  //     print('   - avatar_url: ${_avatarUrl != null ? "present" : "missing"}');
  //     print('   - displayName: ${payload['displayName']}');
  //     print('   - gender: ${payload['gender']}');
  //     print('   - bio length: ${payload['bio'].toString().length}');
  //     print('   - interests count: ${_interests.length}');
  //
  //     //final ok = await _userService.completeProfile(payload);
  //
  //     if (!mounted) return;
  //
  //     // if (ok) {
  //     //   print('✅ Profile completed successfully!');
  //     //   Navigator.pushAndRemoveUntil(
  //     //     context,
  //     //     MaterialPageRoute(builder: (_) => const MainTabScreen()),
  //     //         (route) => false,
  //     //   );
  //     // } else {
  //     //   print('❌ complete-profile returned false');
  //     //   ScaffoldMessenger.of(context).showSnackBar(
  //     //     const SnackBar(content: Text('Không thể lưu hồ sơ. Vui lòng thử lại.')),
  //     //   );
  //     // }
  //   } catch (e) {
  //     print('❌ Error in _submit: $e');
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Lỗi: ${e.toString()}')),
  //       );
  //     }
  //   } finally {
  //     if (mounted) setState(() { _loading = false; });
  //   }
  // }

  void _next() {
    if (!_validateCurrentStep()) return;
    setState(() { _step = (_step + 1).clamp(0, 4); });
  }

  void _back() {
    setState(() { _step = (_step - 1).clamp(0, 4); });
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildAvatarStep();
      case 1:
        return _buildBasicInfoStep();
      case 2:
        return _buildBioStep();
      case 3:
        return _buildInterestsStep();
      case 4:
        return _buildPreferencesStep();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoàn thiện hồ sơ'),
        leading: _step > 0 ? IconButton(onPressed: _back, icon: const Icon(Icons.arrow_back)) : null,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              LinearProgressIndicator(value: (_step + 1) / 5),
              const SizedBox(height: 16),
              Expanded(child: _buildStep()),
              const SizedBox(height: 8),
              // Row(
              //   children: [
              //     if (_step < 4)
              //       Expanded(
              //         child: ElevatedButton(
              //           onPressed: _loading ? null : _next,
              //           child: const Text('Tiếp tục'),
              //         ),
              //       )
              //     else
              //       Expanded(
              //         child: ElevatedButton(
              //            onPressed: _loading ? null : 0, //_submit,
              //           child: _loading ? const CircularProgressIndicator() : const Text('Hoàn tất'),
              //         ),
              //       ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ảnh đại diện', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Center(
          child: GestureDetector(
            onTap: _loading ? null : _pickAvatar,
            child: CircleAvatar(
              radius: 56,
              backgroundImage: _avatarBytes != null
                  ? MemoryImage(_avatarBytes!)
                  : (_avatarUrl != null ? NetworkImage(_avatarUrl!) : null),
              child: _avatarBytes == null && _avatarUrl == null
                  ? const Icon(Icons.camera_alt, size: 32)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Thông tin cơ bản', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _displayNameCtrl,
          decoration: const InputDecoration(labelText: 'Tên hiển thị'),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _gender,
          decoration: const InputDecoration(labelText: 'Giới tính'),
          items: const [
            DropdownMenuItem(value: 'male', child: Text('Nam')),
            DropdownMenuItem(value: 'female', child: Text('Nữ')),
            DropdownMenuItem(value: 'other', child: Text('Khác')),
          ],
          onChanged: (v) => setState(() => _gender = v),
        ),
      ],
    );
  }

  Widget _buildBioStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Giới thiệu ngắn (≥ 30 ký tự)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _bioCtrl,
          maxLines: 5,
          decoration: const InputDecoration(hintText: 'Viết một đoạn giới thiệu về bạn...'),
        ),
      ],
    );
  }

  Widget _buildInterestsStep() {
    const allInterests = <String>[
      'Music','Travel','Movies','Books','Cooking','Fitness','Gaming','Art','Tech','Outdoors'
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sở thích (chọn vài mục)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in allInterests)
              FilterChip(
                label: Text(item),
                selected: _interests.contains(item),
                onSelected: (sel) {
                  setState(() {
                    if (sel) {
                      _interests.add(item);
                    } else {
                      _interests.remove(item);
                    }
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreferencesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tùy chọn ghép đôi (không bắt buộc)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _preferredGender,
          decoration: const InputDecoration(labelText: 'Giới tính mong muốn'),
          items: const [
            DropdownMenuItem(value: 'any', child: Text('Bất kỳ')),
            DropdownMenuItem(value: 'male', child: Text('Nam')),
            DropdownMenuItem(value: 'female', child: Text('Nữ')),
          ],
          onChanged: (v) => setState(() => _preferredGender = v ?? 'any'),
        ),
        const SizedBox(height: 8),
        const Text('Độ tuổi'),
        RangeSlider(
          values: _ageRange,
          onChanged: (v) => setState(() => _ageRange = v),
          min: 18,
          max: 65,
          divisions: 47,
        ),
        const SizedBox(height: 8),
        const Text('Khoảng cách tối đa (km)'),
        Slider(
          value: _maxDistance,
          min: 1,
          max: 100,
          divisions: 99,
          label: _maxDistance.round().toString(),
          onChanged: (v) => setState(() => _maxDistance = v),
        ),
      ],
    );
  }
}