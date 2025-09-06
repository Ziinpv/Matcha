import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _step = 0;
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _bioController = TextEditingController();
  List<File> _images = [];
  final picker = ImagePicker();
  final List<String> _hobbies = [
    'Du lịch', 'Âm nhạc', 'Nấu ăn', 'Nhiếp ảnh', 'Khiêu vũ', 'Gym', 'Cà phê', 'Rượu vang', 'Thiên nhiên',
    'Phim ảnh', 'Thể thao', 'Đọc sách', 'Vẽ', 'Yoga', 'Game', 'Bia', 'Thú cưng', 'Công nghệ',
  ];
  List<String> _selectedHobbies = [];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFieldChanged);
    _ageController.addListener(_onFieldChanged);
    _bioController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _ageController.removeListener(_onFieldChanged);
    _bioController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_images.length >= 5) return;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () async {
                Navigator.of(context).pop();
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _images.add(File(pickedFile.path));
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () async {
                Navigator.of(context).pop();
                final pickedFile = await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    _images.add(File(pickedFile.path));
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _nextStep() {
    if (_step < 4) {
      setState(() {
        _step++;
      });
    }
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() {
        _step--;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _finish() {
    // Handle registration complete
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _step == index ? Color(0xFFFF4B91) : Color(0xFFE0E0E0),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildNameStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        const Text('Bạn tên là gì?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
        const SizedBox(height: 32),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Nhập tên của bạn',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildAgeStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        const Text('Bạn bao nhiêu tuổi?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
        const SizedBox(height: 32),
        TextField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Nhập tuổi của bạn',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildImageStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const Text('Hãy tải lên những bức ảnh đẹp nhất của bạn.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        SizedBox(
          height: 220,
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: _images.length < 5 ? _images.length + 1 : 5,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              if (index < _images.length) {
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(_images[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 20, color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFDEFF3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFFF4B91)),
                    ),
                    child: const Center(
                      child: Icon(Icons.add, size: 36, color: Color(0xFFFF4B91)),
                    ),
                  ),
                );
              }
            },
          ),
        ),
        const SizedBox(height: 8),
        const Text('Thêm tối đa 5 ảnh', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        // Add Skip button
        TextButton(
          onPressed: () {
            setState(() {
              _step++;
            });
          },
          child: const Text(
            'Bỏ qua',
            style: TextStyle(
              color: Color(0xFFFF4B91),
              fontWeight: FontWeight.bold,
              fontSize: 16,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBioStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        const Text('Hãy giới thiệu về bản thân.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        const SizedBox(height: 32),
        TextField(
          controller: _bioController,
          maxLines: 4,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'Giới thiệu bản thân',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildHobbyStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const Text('Sở thích của bạn là gì?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _hobbies.map((hobby) {
            final selected = _selectedHobbies.contains(hobby);
            return ChoiceChip(
              label: Text(hobby),
              selected: selected,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _selectedHobbies.add(hobby);
                  } else {
                    _selectedHobbies.remove(hobby);
                  }
                });
              },
              selectedColor: Color(0xFFFF4B91),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text('Chọn ít nhất 1 sở thích', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _buildNameStep();
      case 1:
        return _buildAgeStep();
      case 2:
        return _buildImageStep();
      case 3:
        return _buildBioStep();
      case 4:
        return _buildHobbyStep();
      default:
        return Container();
    }
  }

  Widget _buildBottomButton() {
    final isLast = _step == 4;
    // Allow next if images is not empty or if on image step (step==2) to allow skip
    final isEnabled = (
      (_step == 0 && _nameController.text.isNotEmpty) ||
      (_step == 1 && _ageController.text.isNotEmpty) ||
      (_step == 2 /*&& _images.isNotEmpty*/) || // always enable on image step
      (_step == 3 && _bioController.text.isNotEmpty) ||
      (_step == 4 && _selectedHobbies.isNotEmpty)
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: isEnabled ? (isLast ? _finish : _nextStep) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled
                ? const Color(0xFFFF4B91)
                : Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(isLast ? 'Hoàn thành' : 'Tiếp theo', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDEFF3),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _prevStep,
                  ),
                  Expanded(child: _buildStepIndicator()),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                child: _buildStepContent(),
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }
}
