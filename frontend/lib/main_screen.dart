import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'notification_screen.dart';

// Color scheme constants
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

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  double _cardOffsetX = 0;
  double _cardRotation = 0;
  bool _showLike = false;
  bool _showDislike = false;
  bool _showStar = false;
  late AnimationController _animController;
  late Animation<double> _animOffsetX;
  late Animation<double> _animRotation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _animOffsetX = Tween<double>(begin: 0, end: 0).animate(_animController);
    _animRotation = Tween<double>(begin: 0, end: 0).animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _animateCard(double endOffset, double endRotation, VoidCallback onCompleted) {
    _animOffsetX = Tween<double>(begin: _cardOffsetX, end: endOffset).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animRotation = Tween<double>(begin: _cardRotation, end: endRotation).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.reset();
    _animController.forward();
    _animController.addListener(() {
      setState(() {
        _cardOffsetX = _animOffsetX.value;
        _cardRotation = _animRotation.value;
      });
    });
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onCompleted();
        _resetCard();
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

  void _onLike() {
    setState(() { _showLike = true; });
    _animateCard(500, 0.3, () {});
  }

  void _onDislike() {
    setState(() { _showDislike = true; });
    _animateCard(-500, -0.3, () {});
  }

  void _onStar() {
    setState(() { _showStar = true; });
    _animateCard(0, 0, () {
      Future.delayed(const Duration(milliseconds: 500), _resetCard);
    });
  }

  void _showProfileSummary() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage('assets/profilepic.jpg'),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Linh, 25', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Color(0xFFFF4B91), size: 18),
                          SizedBox(width: 4),
                          Text('2km từ bạn', style: TextStyle(fontSize: 14, color: Colors.black54)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Giới thiệu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              const Text(
                'Yêu thích du lịch và khám phá những món ăn mới. Thích xem phim và nghe nhạc indie.',
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 18),
              const Text('Sở thích', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _ProfileHobbyChip(label: 'Du lịch'),
                  _ProfileHobbyChip(label: 'Âm thực'),
                  _ProfileHobbyChip(label: 'Phim ảnh'),
                  _ProfileHobbyChip(label: 'Âm nhạc'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.primary, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );
            },
          ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined, color: AppColors.primary, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            ),
          ),
        ],
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main Card Area
            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 380),
                  margin: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: _showProfileSummary,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: Transform.translate(
                      offset: Offset(_cardOffsetX, 0),
                      child: Transform.rotate(
                        angle: _cardRotation,
                        child: Stack(
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                              elevation: 12,
                              margin: EdgeInsets.zero,
                              shadowColor: AppColors.primary.withValues(alpha: 0.2),
                              child: Container(
                                width: double.infinity,
                                height: 520,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFF667eea),
                                      Color(0xFF764ba2),
                                    ],
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    // Background pattern
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(28),
                                  image: DecorationImage(
                                    image: const AssetImage('assets/profilepic.jpg'),
                                    onError: (exception, stackTrace) {},
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                      ),
                                    ),
                                    // Gradient overlay
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(28),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withValues(alpha: 0.3),
                                              Colors.black.withValues(alpha: 0.7),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Content
                                    Positioned(
                                      left: 16,
                                      bottom: 20,
                                      right: 16,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Name, age and compatibility score
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
                                                            'Linh',
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 24,
                                                              fontWeight: FontWeight.bold,
                                                              shadows: [
                                                                Shadow(
                                                                  color: Colors.black.withValues(alpha: 0.3),
                                                                  offset: const Offset(0, 1),
                                                                  blurRadius: 2,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 6),
                                                        Text(
                                                          '25',
                                                          style: TextStyle(
                                                            color: Colors.white.withValues(alpha: 0.9),
                                                            fontSize: 20,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.location_on,
                                                          color: AppColors.primary,
                                                          size: 16,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Flexible(
                                                          child: Text(
                                                            '2km từ bạn',
                                                            style: TextStyle(
                                                              color: Colors.white.withValues(alpha: 0.9),
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
                                              // Compatibility score badge
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  borderRadius: BorderRadius.circular(16),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppColors.primary.withValues(alpha: 0.3),
                                                      blurRadius: 6,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.favorite,
                                                      color: Colors.white,
                                                      size: 14,
                                                    ),
                                                    const SizedBox(width: 3),
                                                    const Text(
                                                      '92%',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          // Hobbies
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            children: const [
                                              _HobbyChip(label: 'Du lịch'),
                                              _HobbyChip(label: 'Âm thực'),
                                              _HobbyChip(label: 'Phim ảnh'),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_showLike)
                                      Positioned(
                                        top: 40,
                                        right: 30,
                                        child: AnimatedOpacity(
                                          opacity: _showLike ? 1 : 0,
                                          duration: const Duration(milliseconds: 200),
                                          child: _ActionLabel(label: 'LIKE', color: Colors.green),
                                        ),
                                      ),
                                    if (_showDislike)
                                      Positioned(
                                        top: 40,
                                        left: 30,
                                        child: AnimatedOpacity(
                                          opacity: _showDislike ? 1 : 0,
                                          duration: const Duration(milliseconds: 200),
                                          child: _ActionLabel(label: 'NOPE', color: Colors.red),
                                        ),
                                      ),
                                    if (_showStar)
                                      Center(
                                        child: AnimatedScale(
                                          scale: _showStar ? 1.2 : 0.0,
                                          duration: const Duration(milliseconds: 300),
                                          child: Icon(Icons.star, color: Colors.yellow, size: 80),
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
                  ),
                ),
              ),
            ),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
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
            ),
          ],
        ),
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
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
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

class _CircleButtonState extends State<_CircleButton> with SingleTickerProviderStateMixin {
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
            BoxShadow(
                    color: widget.color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
              child: Icon(
                widget.icon,
                color: widget.iconColor,
                size: widget.size * 0.4,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _ActionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 3),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 24,
          letterSpacing: 2,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.2),
              offset: const Offset(0, 1),
              blurRadius: 2,
            ),
          ],
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
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
