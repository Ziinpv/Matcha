import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/chat_service.dart';

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

class Chat {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime timestamp;
  final String avatarUrl;
  final bool isOnline;
  final int unreadCount;
  final String? roomId; // roomId từ match
  final String? userId; // userId của người kia

  Chat({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.avatarUrl,
    this.isOnline = false,
    this.unreadCount = 0,
    this.roomId,
    this.userId,
  });
}

class ChatMessage {
  final String id;
  final String senderId;
  final String message;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.message,
    required this.timestamp,
    required this.isMe,
  });
}

class ChatScreen extends StatefulWidget {
  final Chat? selectedChat;

  const ChatScreen({super.key, this.selectedChat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<ChatMessage> _messages = [];
  List<Chat> _recentChats = [];
  StreamSubscription<QuerySnapshot>? _messagesSubscription;
  StreamSubscription<QuerySnapshot>? _chatListSubscription;
  bool _loading = true;
  bool _loadingChats = true;

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ';
    } else {
      return '${difference.inDays} ngày';
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.selectedChat != null) {
      _loadMessages();
      _setupRealtimeListener();
      _markAsRead(widget.selectedChat!.roomId!);
    } else {
      _loadRecentChats();
      _setupChatListRealtimeListener();
    }
  }

  @override
  void didUpdateWidget(ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload when navigating to a different chat
    if (widget.selectedChat != null && widget.selectedChat?.roomId != oldWidget.selectedChat?.roomId) {
      _messagesSubscription?.cancel();
      _loadMessages();
      _setupRealtimeListener();
      if (widget.selectedChat!.roomId != null) {
        _markAsRead(widget.selectedChat!.roomId!);
      }
    }
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _chatListSubscription?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  void _loadMessages() async {
    if (widget.selectedChat?.roomId == null) return;
    
    setState(() => _loading = true);
    try {
      final data = await _chatService.getMessages(widget.selectedChat!.roomId!);
      final currentUid = _auth.currentUser?.uid;
      
      setState(() {
        _messages = data.map((item) {
          DateTime? timestamp;
          if (item['createdAt'] != null) {
            if (item['createdAt'] is Map) {
              final ts = item['createdAt'] as Map<String, dynamic>;
              final seconds = ts['_seconds'] as int? ?? ts['seconds'] as int?;
              if (seconds != null) {
                timestamp = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
              }
            } else if (item['createdAt'] is String) {
              timestamp = DateTime.tryParse(item['createdAt'] as String);
            }
          }
          timestamp ??= DateTime.now();

          final fromUid = item['from']?.toString() ?? '';
          final isMe = fromUid == currentUid;

          return ChatMessage(
            id: item['id']?.toString() ?? '',
            senderId: fromUid,
            message: item['text']?.toString() ?? item['imageUrl']?.toString() ?? '',
            timestamp: timestamp,
            isMe: isMe,
          );
        }).toList();
        _loading = false;
      });
    } catch (e) {
      print('Error loading messages: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _loadRecentChats() async {
    setState(() => _loadingChats = true);
    try {
      final data = await _chatService.getRecentChats();
      
      setState(() {
        _recentChats = data.map((item) {
          DateTime? timestamp;
          if (item['timestamp'] != null) {
            if (item['timestamp'] is Map) {
              final ts = item['timestamp'] as Map<String, dynamic>;
              final seconds = ts['_seconds'] as int? ?? ts['seconds'] as int?;
              if (seconds != null) {
                timestamp = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
              }
            } else if (item['timestamp'] is String) {
              timestamp = DateTime.tryParse(item['timestamp'] as String);
            }
          }
          timestamp ??= DateTime.now();

          return Chat(
            id: item['id']?.toString() ?? item['roomId']?.toString() ?? '',
            name: item['name']?.toString() ?? 'Unknown',
            lastMessage: item['lastMessage']?.toString() ?? '',
            timestamp: timestamp,
            avatarUrl: item['avatarUrl']?.toString() ?? '',
            isOnline: false,
            unreadCount: (item['unreadCount'] as int?) ?? 0,
            roomId: item['roomId']?.toString(),
            userId: item['userId']?.toString(),
          );
        }).toList();
        _loadingChats = false;
      });
    } catch (e) {
      print('Error loading recent chats: $e');
      setState(() => _loadingChats = false);
    }
  }

  void _setupChatListRealtimeListener() {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null) return;

    // Listen to matches collection for new matches
    _chatListSubscription = _firestore
        .collection('matches')
        .where('users', arrayContains: currentUid)
        .snapshots()
        .listen((snapshot) {
      print('📨 Chat list updated: ${snapshot.docs.length} matches');
      // Reload recent chats when matches change
      _loadRecentChats();
    }, onError: (error) {
      print('❌ Chat list listener error: $error');
    });

    // Also listen to messages collection to update chat list when new messages arrive
    // This ensures the last message and unread count are updated in real-time
    _firestore
        .collection('messages')
        .where('to', isEqualTo: currentUid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        print('📨 New message received, updating chat list');
        _loadRecentChats();
      }
    }, onError: (error) {
      print('❌ Messages listener error for chat list: $error');
    });
  }

  Future<void> _markAsRead(String roomId) async {
    await _chatService.markAsRead(roomId);
  }

  void _setupRealtimeListener() {
    if (widget.selectedChat?.roomId == null) {
      print('⚠️ Cannot setup listener: roomId is null');
      return;
    }
    
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null) {
      print('⚠️ Cannot setup listener: currentUid is null');
      return;
    }

    print('🔔 Setting up realtime listener for roomId: ${widget.selectedChat!.roomId}');

    try {
      _messagesSubscription = _firestore
          .collection('messages')
          .where('roomId', isEqualTo: widget.selectedChat!.roomId)
          .orderBy('createdAt', descending: false)
          .snapshots()
          .listen(
            (snapshot) {
              print('📨 Received ${snapshot.docs.length} messages from Firestore');
              if (snapshot.docs.isEmpty) {
                print('⚠️ No messages found in snapshot');
                return;
              }

              setState(() {
                _messages = snapshot.docs.map((docSnap) {
                  final data = docSnap.data();
                  
                  DateTime? timestamp;
                  if (data['createdAt'] != null) {
                    if (data['createdAt'] is Timestamp) {
                      timestamp = (data['createdAt'] as Timestamp).toDate();
                    } else if (data['createdAt'] is Map) {
                      final ts = data['createdAt'] as Map<String, dynamic>;
                      final seconds = ts['_seconds'] as int? ?? ts['seconds'] as int?;
                      if (seconds != null) {
                        timestamp = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
                      }
                    }
                  }
                  timestamp ??= DateTime.now();

                  final fromUid = data['from']?.toString() ?? '';
                  final isMe = fromUid == currentUid;

                  return ChatMessage(
                    id: docSnap.id,
                    senderId: fromUid,
                    message: data['text']?.toString() ?? data['imageUrl']?.toString() ?? '',
                    timestamp: timestamp,
                    isMe: isMe,
                  );
                }).toList();
                
                // Sort by timestamp
                _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
              });
            },
            onError: (error) {
              print('❌ Firestore listener error: $error');
              // Try without orderBy if index is missing
              if (error.toString().contains('index')) {
                print('⚠️ Firestore index missing, trying without orderBy...');
                _setupRealtimeListenerWithoutOrderBy();
              }
            },
          );
    } catch (e) {
      print('❌ Error setting up listener: $e');
      // Fallback: try without orderBy
      _setupRealtimeListenerWithoutOrderBy();
    }
  }

  void _setupRealtimeListenerWithoutOrderBy() {
    if (widget.selectedChat?.roomId == null) return;
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null) return;

    print('🔔 Setting up listener without orderBy for roomId: ${widget.selectedChat!.roomId}');

    _messagesSubscription?.cancel();
    _messagesSubscription = _firestore
        .collection('messages')
        .where('roomId', isEqualTo: widget.selectedChat!.roomId)
        .snapshots()
        .listen(
          (snapshot) {
            print('📨 Received ${snapshot.docs.length} messages (no orderBy)');
            if (snapshot.docs.isEmpty) return;

            setState(() {
              _messages = snapshot.docs.map((docSnap) {
                final data = docSnap.data();
                
                DateTime? timestamp;
                if (data['createdAt'] != null) {
                  if (data['createdAt'] is Timestamp) {
                    timestamp = (data['createdAt'] as Timestamp).toDate();
                  } else if (data['createdAt'] is Map) {
                    final ts = data['createdAt'] as Map<String, dynamic>;
                    final seconds = ts['_seconds'] as int? ?? ts['seconds'] as int?;
                    if (seconds != null) {
                      timestamp = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
                    }
                  }
                }
                timestamp ??= DateTime.now();

                final fromUid = data['from']?.toString() ?? '';
                final isMe = fromUid == currentUid;

                return ChatMessage(
                  id: docSnap.id,
                  senderId: fromUid,
                  message: data['text']?.toString() ?? data['imageUrl']?.toString() ?? '',
                  timestamp: timestamp,
                  isMe: isMe,
                );
              }).toList();
              
              // Sort manually by timestamp
              _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
              
              // Mark as read when user views messages
              if (widget.selectedChat?.roomId != null) {
                _markAsRead(widget.selectedChat!.roomId!);
              }
            });
          },
          onError: (error) {
            print('❌ Firestore listener error (no orderBy): $error');
          },
        );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    if (widget.selectedChat?.roomId == null || widget.selectedChat?.userId == null) return;

    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null) return;

    // Optimistic update - thêm message vào UI ngay
    final tempMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUid,
      message: text,
      timestamp: DateTime.now(),
      isMe: true,
    );

    setState(() {
      _messages.add(tempMessage);
    });

    _messageController.clear();

    // Gửi lên backend
    try {
      print('🚀 Attempting to send message...');
      print('   roomId: ${widget.selectedChat!.roomId}');
      print('   userId: ${widget.selectedChat!.userId}');
      print('   text: $text');
      
      final result = await _chatService.sendMessage(
        roomId: widget.selectedChat!.roomId!,
        toUid: widget.selectedChat!.userId!,
        text: text,
      );
      
      if (result == null) {
        print('❌ Failed to send message - result is null');
        // Remove optimistic message if failed
        setState(() {
          _messages.removeWhere((msg) => msg.id == tempMessage.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể gửi tin nhắn. Vui lòng kiểm tra kết nối và thử lại.')),
        );
      } else {
        print('✅ Message sent successfully: $result');
        // Realtime listener sẽ tự động cập nhật khi message được lưu vào Firestore
      }
    } catch (e, stackTrace) {
      print('❌ Error sending message: $e');
      print('Stack trace: $stackTrace');
      // Remove optimistic message if failed
      setState(() {
        _messages.removeWhere((msg) => msg.id == tempMessage.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedChat != null) {
      return _buildChatDetail(widget.selectedChat!);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.pastelPink,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.chat_bubble, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Text(
              'Tin nhắn',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: _loadingChats
          ? const Center(child: CircularProgressIndicator())
          : _recentChats.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.1),
                                AppColors.secondary.withValues(alpha: 0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 60,
                            color: AppColors.primary.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Chưa có tin nhắn nào',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Kết đôi với ai đó để bắt đầu trò chuyện!',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRecentChats,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _recentChats.length,
                    itemBuilder: (context, index) {
                      final chat = _recentChats[index];
                      return _buildChatListItem(chat);
                    },
                  ),
                ),
    );
  }

  Widget _buildChatDetail(Chat chat) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.2),
                        AppColors.secondary.withValues(alpha: 0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: chat.avatarUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(chat.avatarUrl),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {},
                            )
                          : null,
                      color: chat.avatarUrl.isEmpty ? AppColors.primaryLight : null,
                    ),
                    child: chat.avatarUrl.isEmpty
                        ? const Icon(Icons.person, color: AppColors.primary)
                        : null,
                  ),
                ),
                if (chat.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    chat.isOnline ? 'Đang hoạt động' : 'Hoạt động ${_formatTime(chat.timestamp)} trước',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
              icon: const Icon(Icons.videocam_rounded, color: AppColors.primary, size: 24),
              onPressed: () {},
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.phone_rounded, color: AppColors.primary, size: 24),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: _loading && _messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(
                        child: Text(
                          'Chưa có tin nhắn nào.\nHãy bắt đầu cuộc trò chuyện!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return _buildMessageBubble(message);
                        },
                      ),
          ),
          // Message Input
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                // Quick actions
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.image_rounded, color: AppColors.primary, size: 24),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.gif_box_rounded, color: AppColors.primary, size: 24),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Text input
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Nhập tin nhắn...',
                              hintStyle: TextStyle(color: AppColors.textSecondary),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                            onSubmitted: (value) => _sendMessage(),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.emoji_emotions_rounded, color: AppColors.primary, size: 20),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Send button
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.pastelPink,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isMe) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    AppColors.secondary.withValues(alpha: 0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight,
                ),
                child: const Icon(Icons.person, color: AppColors.primary, size: 20),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: message.isMe 
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
                color: message.isMe ? null : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isMe ? 20 : 4),
                  bottomRight: Radius.circular(message.isMe ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: message.isMe 
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: message.isMe ? Colors.white : AppColors.textPrimary,
                      fontSize: 16,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: message.isMe ? Colors.white.withValues(alpha: 0.8) : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatListItem(Chat chat) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(selectedChat: chat),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.2),
                        AppColors.secondary.withValues(alpha: 0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: chat.avatarUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(chat.avatarUrl),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {},
                            )
                          : null,
                      color: chat.avatarUrl.isEmpty ? AppColors.primaryLight : null,
                    ),
                    child: chat.avatarUrl.isEmpty
                        ? const Icon(Icons.person, color: AppColors.primary, size: 28)
                        : null,
                  ),
                ),
                if (chat.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 3),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatChatTime(chat.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage.isEmpty ? 'Chưa có tin nhắn' : chat.lastMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            chat.unreadCount > 99 ? '99+' : chat.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatChatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
