import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';
import 'matches_screen.dart';
import 'settings_screen.dart';
import 'notification_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
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
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Matcha', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              elevation: 8,
                              margin: EdgeInsets.zero,
                              child: Container(
                                width: double.infinity,
                                height: 480,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  image: DecorationImage(
                                    image: const AssetImage('assets/profilepic.jpg'),
                                    onError: (exception, stackTrace) {},
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 16,
                                      bottom: 24,
                                      right: 16,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: const [
                                              Text('Linh', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                              SizedBox(width: 8),
                                              Text('25', style: TextStyle(color: Colors.white, fontSize: 20)),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 8,
                                            children: const [
                                              _HobbyChip(label: 'Du lịch'),
                                              _HobbyChip(label: 'Âm thực'),
                                              _HobbyChip(label: 'Phim ảnh'),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: const [
                                              Icon(Icons.location_on, color: Color(0xFFFF4B91), size: 18),
                                              SizedBox(width: 4),
                                              Text('2km', style: TextStyle(color: Colors.white)),
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
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CircleButton(
                    icon: Icons.close,
                    color: Colors.white,
                    iconColor: Colors.black,
                    onTap: _onDislike,
                  ),
                  _CircleButton(
                    icon: Icons.star,
                    color: Color(0xFF1877F3),
                    iconColor: Colors.white,
                    onTap: _onStar,
                  ),
                  _CircleButton(
                    icon: Icons.favorite,
                    color: Color(0xFF22C55E),
                    iconColor: Colors.white,
                    onTap: _onLike,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          
          // Navigate to different screens based on index
          switch (index) {
            case 0:
              // Stay on current screen (Discovery/Main)
              break;
            case 1:
              // Navigate to Matches
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MatchesScreen()),
              );
              break;
            case 2:
              // Navigate to Chat
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
              break;
            case 3:
              // Navigate to Profile
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
              break;
          }
        },
        selectedItemColor: const Color(0xFFFF4B91),
        unselectedItemColor: Colors.black,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Khám phá',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flash_on),
            label: 'Kết đôi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Tin nhắn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Hồ sơ',
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 0.5),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.color, required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 32),
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 3),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          letterSpacing: 2,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE0E0E0), width: 1),
      ),
      child: Text(label, style: const TextStyle(color: Colors.black87, fontSize: 13)),
    );
  }
}
