import 'package:flutter/material.dart';

class MatchBanner {
  static void show({
    required BuildContext context,
    required String name,
    required String avatarUrl,
  }) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: 60,
          left: 20,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: _MatchBannerCard(
              name: name,
              avatarUrl: avatarUrl,
              onClose: () => entry.remove(),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) entry.remove();
    });
  }
}

class _MatchBannerCard extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final VoidCallback onClose;

  const _MatchBannerCard({
    required this.name,
    required this.avatarUrl,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: avatarUrl.isNotEmpty
                ? NetworkImage(avatarUrl)
                : const AssetImage("assets/profilepic.jpg") as ImageProvider,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "🎉 Bạn và $name đã match!",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close, size: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
