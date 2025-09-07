import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _distance = 20.0;
  RangeValues _ageRange = const RangeValues(22, 35);
  bool _matchesNotification = true;
  bool _messagesNotification = true;
  bool _likesNotification = false;
  bool _marketingNotification = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Cài đặt', style: TextStyle(color: Colors.black)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
            const SizedBox(height: 16),
            // Discovery Filters Section
            _buildSection(
              title: 'Bộ lọc khám phá',
              icon: Icons.location_on,
              child: Column(
                children: [
                  // Distance Filter
                  _buildSliderSetting(
                    title: 'Khoảng cách tối đa',
                    value: _distance,
                    min: 1.0,
                    max: 100.0,
                    divisions: 99,
                    label: '${_distance.round()}km',
                    onChanged: (value) {
                      setState(() {
                        _distance = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  // Age Range Filter
                  _buildRangeSliderSetting(
                    title: 'Độ tuổi',
                    values: _ageRange,
                    min: 18.0,
                    max: 65.0,
                    divisions: 47,
                    label: '${_ageRange.start.round()} - ${_ageRange.end.round()} tuổi',
                    onChanged: (values) {
                      setState(() {
                        _ageRange = values;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Notifications Section
            _buildSection(
              title: 'Thông báo',
              icon: Icons.notifications,
              child: Column(
                children: [
                  _buildSwitchSetting(
                    title: 'Kết đôi mới',
                    subtitle: 'Nhận thông báo khi có kết đôi',
                    value: _matchesNotification,
                    onChanged: (value) {
                      setState(() {
                        _matchesNotification = value;
                      });
                    },
                  ),
                  _buildSwitchSetting(
                    title: 'Tin nhắn',
                    subtitle: 'Nhận thông báo tin nhắn mới',
                    value: _messagesNotification,
                    onChanged: (value) {
                      setState(() {
                        _messagesNotification = value;
                      });
                    },
                  ),
                  _buildSwitchSetting(
                    title: 'Lượt thích',
                    subtitle: 'Nhận thông báo khi được thích',
                    value: _likesNotification,
                    onChanged: (value) {
                      setState(() {
                        _likesNotification = value;
                      });
                    },
                  ),
                  _buildSwitchSetting(
                    title: 'Khuyến mãi',
                    subtitle: 'Nhận email về ưu đãi',
                    value: _marketingNotification,
                    onChanged: (value) {
                      setState(() {
                        _marketingNotification = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Privacy & Safety Section
            _buildSection(
              title: 'Quyền riêng tư & An toàn',
              icon: Icons.shield,
              child: Column(
                children: [
                  _buildMenuSetting(
                    title: 'Chặn & Báo cáo',
                    onTap: () {},
                  ),
                  _buildMenuSetting(
                    title: 'Kiểm soát hiển thị hồ sơ',
                    onTap: () {},
                  ),
                  _buildMenuSetting(
                    title: 'Dữ liệu cá nhân',
                    onTap: () {},
                  ),
                  _buildMenuSetting(
                    title: 'Điều khoản sử dụng',
                    onTap: () {},
                  ),
                  _buildMenuSetting(
                    title: 'Chính sách bảo mật',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Account Management Section
            _buildSection(
              title: 'Quản lý tài khoản',
              icon: Icons.person,
              child: Column(
                children: [
                  _buildMenuSetting(
                    title: 'Thay đổi mật khẩu',
                    onTap: () {},
                  ),
                  _buildMenuSetting(
                    title: 'Kết nối mạng xã hội',
                    onTap: () {},
                  ),
                  _buildMenuSetting(
                    title: 'Tạm ẩn hồ sơ',
                    onTap: () {},
                  ),
                  _buildMenuSetting(
                    title: 'Xóa tài khoản',
                    textColor: Colors.red,
                    onTap: () {
                      _showDeleteAccountDialog();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Support Section
            _buildSection(
              title: 'Hỗ trợ',
              icon: Icons.help,
              child: Column(
                children: [
                  _buildMenuSetting(
                    title: 'Trung tâm trợ giúp',
                    onTap: () {},
                  ),
                  _buildMenuSetting(
                    title: 'Liên hệ hỗ trợ',
                    onTap: () {},
                  ),
                  _buildMenuSetting(
                    title: 'Phản hồi',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // App Info Section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Matcha v1.0.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2025 Matcha Dating App',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFFF4B91), size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFFFF4B91),
            thumbColor: const Color(0xFFFF4B91),
            overlayColor: const Color(0xFFFF4B91).withOpacity(0.2),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${min.round()}${title.contains('cách') ? 'km' : ''}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            Text(
              '${max.round()}${title.contains('cách') ? 'km' : ''}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRangeSliderSetting({
    required String title,
    required RangeValues values,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<RangeValues> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFFFF4B91),
            thumbColor: const Color(0xFFFF4B91),
            overlayColor: const Color(0xFFFF4B91).withOpacity(0.2),
          ),
          child: RangeSlider(
            values: values,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${min.round()}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            Text(
              '${max.round()}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwitchSetting({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFFF4B91),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSetting({
    required String title,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor ?? Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa tài khoản'),
          content: const Text(
            'Bạn có chắc chắn muốn xóa tài khoản? Hành động này không thể hoàn tác.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Handle account deletion
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tính năng sẽ được cập nhật trong phiên bản tới'),
                  ),
                );
              },
              child: const Text(
                'Xóa',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
