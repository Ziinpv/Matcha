import 'dart:math';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserCard extends StatefulWidget {
  final UserModel user;

  const UserCard({Key? key, required this.user}) : super(key: key);

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _positionX = 0;
  double _rotation = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _positionX += details.delta.dx;
      _rotation = 0.002 * _positionX;
      _isDragging = true;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (_positionX.abs() > screenWidth * 0.3) {
      final isRight = _positionX > 0;
      _swipeCard(isRight);
    } else {
      setState(() {
        _positionX = 0;
        _rotation = 0;
        _isDragging = false;
      });
    }
  }

  void _swipeCard(bool isRight) {
    final screenWidth = MediaQuery.of(context).size.width;
    setState(() {
      _positionX = isRight ? screenWidth : -screenWidth;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      // TODO: Gọi logic like/dislike sau này nếu cần
      setState(() {
        _positionX = 0;
        _rotation = 0;
        _isDragging = false;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Hàm tính tuổi từ ngày sinh
  int? get age {
    if (widget.user.birthdate == null) return null;
    final now = DateTime.now();
    int years = now.year - widget.user.birthdate!.year;
    if (now.month < widget.user.birthdate!.month ||
        (now.month == widget.user.birthdate!.month &&
            now.day < widget.user.birthdate!.day)) {
      years--;
    }
    return years;
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final imageUrl = user.avatarUrl?.isNotEmpty == true
        ? user.avatarUrl!
        : 'https://cdn-icons-png.flaticon.com/512/847/847969.png';

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      left: _positionX,
      top: _isDragging ? 10 : 0,
      right: -_positionX,
      child: Transform.rotate(
        angle: _rotation,
        child: Center(
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Ảnh đại diện
                Image.network(
                  imageUrl,
                  height: 550,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

                // Gradient mờ dưới ảnh
                Container(
                  height: 550,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black54],
                    ),
                  ),
                ),

                // Thông tin người dùng
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${user.name ?? "Ẩn danh"}, ${age ?? '?'}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.bio ?? "Không có mô tả.",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: (user.interests ?? [])
                            .map((interest) => Chip(
                          backgroundColor: Colors.white24,
                          label: Text(
                            interest,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ))
                            .toList(),
                      ),
                    ],
                  ),
                ),

                // Nút hành động ❤️ ❌ ⭐
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _actionButton(Icons.close, Colors.redAccent, () => _swipeCard(false)),
                      _actionButton(Icons.star, Colors.amber, () {}),
                      _actionButton(Icons.favorite, Colors.greenAccent, () => _swipeCard(true)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.white,
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}
