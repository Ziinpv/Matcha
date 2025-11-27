// lib/widgets/match_popup_fullscreen.dart

import 'package:flutter/material.dart';

class MatchPopupFullScreen extends StatefulWidget {
  final String myAvatar;
  final String otherAvatar;
  final String otherName;
  final VoidCallback onChat;
  final VoidCallback onContinue;

  const MatchPopupFullScreen({
    Key? key,
    required this.myAvatar,
    required this.otherAvatar,
    required this.otherName,
    required this.onChat,
    required this.onContinue,
  }) : super(key: key);

  @override
  _MatchPopupFullScreenState createState() => _MatchPopupFullScreenState();
}

class _MatchPopupFullScreenState extends State<MatchPopupFullScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scale1;
  late Animation<double> _scale2;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _scale1 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _scale2 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0, curve: Curves.elasticOut)),
    );

    _fadeIn = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.85),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _scale1,
                  child: const Text(
                    "🎉 It's a Match! 🎉",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                ScaleTransition(
                  scale: _scale2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _avatar(widget.myAvatar),
                      const SizedBox(width: 20),
                      _avatar(widget.otherAvatar),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                FadeTransition(
                  opacity: _fadeIn,
                  child: Text(
                    "Bạn và ${widget.otherName} đã thích nhau!",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                FadeTransition(
                  opacity: _fadeIn,
                  child: Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: widget.onChat,
                        child: const Text("Bắt đầu trò chuyện"),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: widget.onContinue,
                        child: const Text(
                          "Tiếp tục khám phá",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          // nút X đóng popup
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              onPressed: widget.onContinue,
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
            ),
          )
        ],
      ),
    );
  }

  Widget _avatar(String url) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        image: DecorationImage(
          image: url.isNotEmpty
              ? NetworkImage(url)
              : const AssetImage("assets/profilepic.jpg") as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
