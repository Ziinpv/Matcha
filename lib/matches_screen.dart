import 'package:flutter/material.dart';
import 'chat_screen.dart';

class Match {
  final String id;
  final String name;
  final int age;
  final String bio;
  final List<String> interests;
  final String avatarUrl;
  final DateTime timestamp;
  final bool isNew;
  final String matchType; // 'like' or 'superlike'
  final int compatibilityScore;

  Match({
    required this.id,
    required this.name,
    required this.age,
    required this.bio,
    required this.interests,
    required this.avatarUrl,
    required this.timestamp,
    this.isNew = false,
    this.matchType = 'like',
    this.compatibilityScore = 0,
  });
}

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({Key? key}) : super(key: key);

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<Match> _matches = [
    Match(
      id: '1',
      name: 'Linh',
      age: 25,
      bio: 'Yêu thích du lịch và khám phá những món ăn mới.',
      interests: ['Du lịch', 'Ẩm thực'],
      avatarUrl: 'assets/profilepic.jpg',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isNew: true,
      matchType: 'superlike',
      compatibilityScore: 92,
    ),
    Match(
      id: '2',
      name: 'Minh',
      age: 28,
      bio: 'Lập trình viên đam mê công nghệ.',
      interests: ['Công nghệ', 'Thể thao'],
      avatarUrl: 'assets/profilepic.jpg',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isNew: true,
      matchType: 'like',
      compatibilityScore: 87,
    ),
    Match(
      id: '3',
      name: 'Hương',
      age: 24,
      bio: 'Họa sĩ tự do, yêu thích thiên nhiên.',
      interests: ['Vẽ', 'Thiên nhiên'],
      avatarUrl: 'assets/profilepic.jpg',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isNew: false,
      matchType: 'like',
      compatibilityScore: 94,
    ),
    Match(
      id: '4',
      name: 'Tuấn',
      age: 27,
      bio: 'Nhiếp ảnh gia và travel blogger.',
      interests: ['Nhiếp ảnh', 'Du lịch'],
      avatarUrl: 'assets/profilepic.jpg',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isNew: false,
      matchType: 'superlike',
      compatibilityScore: 89,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inHours < 1) {
      return 'Vừa mới';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }

  List<Match> get newMatches => _matches.where((match) => match.isNew).toList();
  List<Match> get allMatches => _matches;

  void _startChat(Match match) {
    final chat = Chat(
      id: match.id,
      name: match.name,
      lastMessage: '',
      timestamp: DateTime.now(),
      avatarUrl: match.avatarUrl,
      isOnline: true,
      unreadCount: 0,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(selectedChat: chat),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Kết đôi', style: TextStyle(color: Colors.black)),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4B91).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${newMatches.length} mới',
              style: const TextStyle(
                color: Color(0xFFFF4B91),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF4B91),
          labelColor: const Color(0xFFFF4B91),
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flash_on, size: 18),
                  const SizedBox(width: 4),
                  Text('Mới (${newMatches.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.schedule, size: 18),
                  const SizedBox(width: 4),
                  Text('Tất cả (${allMatches.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // New Matches Tab
            _buildMatchesGrid(newMatches, isEmpty: newMatches.isEmpty),
            // All Matches Tab
            _buildMatchesGrid(allMatches, isEmpty: false),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchesGrid(List<Match> matches, {required bool isEmpty}) {
    if (isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
        ),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          return _buildMatchCard(matches[index]);
        },
      ),
    );
  }

  Widget _buildMatchCard(Match match) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with badges
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    image: DecorationImage(
                      image: AssetImage(match.avatarUrl),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {},
                    ),
                    color: Colors.grey[300],
                  ),
                ),
                // Match type badge
                if (match.matchType == 'superlike')
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                // New badge
                if (match.isNew)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4B91),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Mới',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Compatibility score
                if (match.compatibilityScore > 0)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${match.compatibilityScore}%',
                        style: const TextStyle(
                          color: Color(0xFFFF4B91),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Info section
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and age
                  Text(
                    '${match.name}, ${match.age}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Time
                  Text(
                    _formatTime(match.timestamp),
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Bio
                  Expanded(
                    child: Text(
                      match.bio,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Interests and Chat button
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 2,
                          children: match.interests.take(1).map((interest) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                interest,
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(width: 2),
                      GestureDetector(
                        onTap: () => _startChat(match),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF4B91),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.message,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border,
              size: 40,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Chưa có kết đôi mới',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tiếp tục khám phá để tìm thêm người phù hợp!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4B91),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              'Bắt đầu khám phá',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
