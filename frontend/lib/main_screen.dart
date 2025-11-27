import 'package:dating_app/services/like_service.dart';
import 'package:dating_app/widgets/match_banner.dart';
import 'package:dating_app/widgets/match_popup_fullscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'notification_screen.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class AppColors {
  static const Color primary = Color(0xFFFF4B91);
  static const Color primaryLight = Color(0xFFFFE4F1);
  static const Color secondary = Color(0xFF6C5CE7);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFE17055);
  static const Color pastelPink = Color(0xFFFF4B91);
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

int? _calculateAge(DateTime? birthdate) {
  if (birthdate == null) return null;
  final now = DateTime.now();
  int age = now.year - birthdate.year;
  if (now.month < birthdate.month ||
      (now.month == birthdate.month && now.day < birthdate.day)) {
    age--;
  }
  return age;
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  List<UserModel> _users = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  double _cardOffsetX = 0;
  double _cardRotation = 0;
  bool _showLike = false;
  bool _showDislike = false;
  bool _showStar = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      final allUsers = await _userService.getAllCompletedUsers();

      // Lấy toàn bộ user đã quẹt
      final swiped = await LikeService().getAllSwipedUsers(currentUserId);

      // Lọc user chưa quẹt + khác mình
      final filtered = allUsers.where((u) =>
      u.uid != currentUserId &&
          !swiped.contains(u.uid)
      ).toList();

      setState(() {
        _users = filtered;
        _isLoading = false;
      });
    } catch (e) {
      print("Lỗi load users: $e");
      setState(() => _isLoading = false);
    }
  }

  void _showFullMatchPopup(String matchedUserId) async {
    final otherUser = await _userService.getUserById(matchedUserId);
    final currentUser = await _userService.getUserById(
        FirebaseAuth.instance.currentUser!.uid);

    if (!mounted) return;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return MatchPopupFullScreen(
          myAvatar: currentUser?.avatarUrl ?? "",
          otherAvatar: otherUser?.avatarUrl ?? "",
          otherName: otherUser?.name ?? "Người lạ",
          onChat: () {
            Navigator.pop(context);
            // TODO: mở màn hình chat
          },
          onContinue: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }


  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _animateCard(
      double endOffset, double endRotation, VoidCallback onCompleted) {
    _animController.removeListener(() {});
    _animController.removeStatusListener((_) {});

    final offsetAnim = Tween<double>(begin: _cardOffsetX, end: endOffset).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    final rotationAnim =
    Tween<double>(begin: _cardRotation, end: endRotation).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.reset();
    _animController.forward();

    _animController.addListener(() {
      setState(() {
        _cardOffsetX = offsetAnim.value;
        _cardRotation = rotationAnim.value;
      });
    });

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onCompleted();
      }
    });
  }

  void _resetCard() {
    setState(() {
      _cardOffsetX = 0;
      _cardRotation = 0;
      _showLike = false;
      _showDislike = false;
      _showStar = false;
    });
  }

  void _onLike() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final targetId = _currentUser!.uid;

    // 🔥 GỌI API MỚI
    final result = await LikeService().likeUserWithResult(uid, targetId);

    if (result.isMatch) {
      _showFullMatchPopup(result.matchedUserId!);
    }

    setState(() => _showLike = true);
    _animateCard(500, 0.3, _nextUser);
  }



  void _onDislike() async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final targetId = _currentUser!.uid;

    await LikeService().dislikeUser(currentUserId, targetId);

    setState(() => _showDislike = true);
    _animateCard(-500, -0.3, _nextUser);
  }


  void _onStar() {
    setState(() => _showStar = true);
    _animateCard(0, 0, () {});
    Future.delayed(const Duration(milliseconds: 500), () {
      _nextUser();
    });
  }

  void _nextUser() async {
    await _loadUsers(); // 🔥 reload danh sách user chưa quẹt

    setState(() {
      _resetCard();

      if (_users.isNotEmpty) {
        _currentIndex = 0;  // Load lại list → bắt đầu từ user đầu tiên
      }
    });
  }


  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _cardOffsetX += details.delta.dx;
      _cardRotation = _cardOffsetX / 600;
      _showLike = _cardOffsetX > 80;
      _showDislike = _cardOffsetX < -80;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_cardOffsetX > 120) {
      _onLike();
    } else if (_cardOffsetX < -120) {
      _onDislike();
    } else {
      _animateCard(0, 0, () {});
    }
  }

  UserModel? get _currentUser =>
      _users.isEmpty ? null : _users[_currentIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _users.isEmpty
                  ? const Center(child: Text("Không có người dùng nào"))
                  : Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 380),
                  margin: const EdgeInsets.all(16),
                  child: _UserCard(
                    user: _currentUser!,
                    offsetX: _cardOffsetX,
                    rotation: _cardRotation,
                    showLike: _showLike,
                    showDislike: _showDislike,
                    showStar: _showStar,
                    onTap: _showProfileSummary,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                  ),
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.pastelPink,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          const Text(
            'Matcha',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      ),
      actions: [
        _AppBarIcon(
          icon: Icons.notifications_outlined,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationScreen()),
          ),
        ),
        _AppBarIcon(
          icon: Icons.settings_outlined,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CircleButton(
                icon: Icons.close_rounded,
                color: Colors.white,
                iconColor: AppColors.error,
                onTap: _onDislike,
                size: 64,
              ),
              _CircleButton(
                icon: Icons.star_rounded,
                color: AppColors.warning,
                iconColor: Colors.white,
                onTap: _onStar,
                size: 56,
              ),
              _CircleButton(
                icon: Icons.favorite_rounded,
                color: AppColors.success,
                iconColor: Colors.white,
                onTap: _onLike,
                size: 64,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 🔥 NÚT RESET Ở ĐÂY
          ElevatedButton.icon(
            onPressed: () async {
              await LikeService().resetUserData(uid);
              await _loadUsers();

              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Đã reset dữ liệu test!"))
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Reset dữ liệu test"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showProfileSummary() {
    if (_currentUser == null) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _ProfileDialog(user: _currentUser!),
    );
  }
}

// ==============================
// WIDGET COMPONENTS (giữ nguyên UI cũ)
// ==============================
class _UserCard extends StatelessWidget {
  final UserModel user;
  final double offsetX;
  final double rotation;
  final bool showLike;
  final bool showDislike;
  final bool showStar;
  final VoidCallback onTap;
  final Function(DragUpdateDetails) onPanUpdate;
  final Function(DragEndDetails) onPanEnd;

  const _UserCard({
    required this.user,
    required this.offsetX,
    required this.rotation,
    required this.showLike,
    required this.showDislike,
    required this.showStar,
    required this.onTap,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  @override
  Widget build(BuildContext context) {
    final age = _calculateAge(user.birthdate);

    return GestureDetector(
      onTap: onTap,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: Transform.translate(
        offset: Offset(offsetX, 0),
        child: Transform.rotate(
          angle: rotation,
          child: Stack(
            children: [
              Card(
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 12,
                margin: EdgeInsets.zero,
                shadowColor: AppColors.primary.withOpacity(0.2),
                child: Container(
                  width: double.infinity,
                  height: 520,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            image: DecorationImage(
                              image: user.avatarUrl != null &&
                                  user.avatarUrl!.isNotEmpty
                                  ? NetworkImage(user.avatarUrl!)
                                  : const AssetImage('assets/profilepic.jpg')
                              as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 20,
                        right: 16,
                        child: _UserInfoSection(user: user, age: age),
                      ),
                      if (showLike)
                        Positioned(
                          top: 40,
                          right: 30,
                          child: _SwipeIndicator(label: 'LIKE', color: Colors.green),
                        ),
                      if (showDislike)
                        Positioned(
                          top: 40,
                          left: 30,
                          child: _SwipeIndicator(label: 'NOPE', color: Colors.red),
                        ),
                      if (showStar)
                        Center(
                          child: AnimatedScale(
                            scale: showStar ? 1.2 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: const Icon(Icons.star, color: Colors.yellow, size: 80),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserInfoSection extends StatelessWidget {
  final UserModel user;
  final int? age;

  const _UserInfoSection({required this.user, this.age});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.name ?? 'Ẩn danh',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 1),
                                  blurRadius: 2)
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        age != null ? '$age' : '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: AppColors.primary, size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          user.location?.isNotEmpty == true
                              ? user.location!
                              : 'Đang cập nhật vị trí...',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const _CompatibilityBadge(),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: (user.interests ?? [])
              .map((interest) => _HobbyChip(label: interest))
              .toList(),
        ),
      ],
    );
  }
}

class _CompatibilityBadge extends StatelessWidget {
  const _CompatibilityBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite, color: Colors.white, size: 14),
          SizedBox(width: 3),
          Text('92%',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _HobbyChip extends StatelessWidget {
  final String label;
  const _HobbyChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 1))
        ],
      ),
      child: Text(
        label,
        style:
        const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SwipeIndicator extends StatelessWidget {
  final String label;
  final Color color;

  const _SwipeIndicator({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 3),
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.9),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 2,
            shadows: [Shadow(color: Colors.black.withOpacity(0.2), offset: const Offset(0, 1), blurRadius: 2)],
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;
  final double size;

  const _CircleButton({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
    this.size = 60,
  });

  @override
  State<_CircleButton> createState() => _CircleButtonState();
}

class _CircleButtonState extends State<_CircleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: widget.color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Icon(widget.icon, color: widget.iconColor, size: widget.size * 0.4),
            ),
          );
        },
      ),
    );
  }
}

class _AppBarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _AppBarIcon({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.primary, size: 24),
        onPressed: onPressed,
      ),
    );
  }
}

class _ProfileDialog extends StatelessWidget {
  final UserModel user;

  const _ProfileDialog({required this.user});

  @override
  Widget build(BuildContext context) {
    final age = _calculateAge(user.birthdate);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: user.avatarUrl != null &&
                        user.avatarUrl!.isNotEmpty
                        ? NetworkImage(user.avatarUrl!)
                        : const AssetImage('assets/profilepic.jpg')
                    as ImageProvider,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.name ?? 'Ẩn danh'}${age != null ? ', $age' : ''}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: AppColors.primary, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            user.location?.isNotEmpty == true
                                ? user.location!
                                : 'Đang cập nhật vị trí...',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Giới thiệu',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              Text(
                user.bio?.isNotEmpty == true
                    ? user.bio!
                    : 'Người này chưa viết gì cả.',
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 18),
              const Text('Sở thích',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (user.interests?.isNotEmpty == true
                    ? user.interests!
                    : ['Du lịch', 'Ẩm thực', 'Phim ảnh', 'Âm nhạc'])
                    .map((hobby) => _ProfileHobbyChip(label: hobby))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHobbyChip extends StatelessWidget {
  final String label;
  const _ProfileHobbyChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
