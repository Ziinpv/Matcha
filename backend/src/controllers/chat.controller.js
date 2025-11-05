const { initializeFirebase } = require('../config/firebase');
initializeFirebase();
const admin = require('firebase-admin');
const db = admin.firestore();

async function sendFcmToUser(targetUid, payload) {
  try {
    const tokenSnap = await db.collection('users').doc(targetUid).get();
    const fcmToken = tokenSnap.exists ? tokenSnap.data().fcmToken : null;
    if (!fcmToken) return;
    await admin.messaging().send({ token: fcmToken, notification: payload.notification, data: payload.data || {} });
  } catch (_) {}
}

module.exports = {
  // POST /api/chat/send { roomId, toUid, text, imageUrl }
  async sendMessage(req, res) {
    try {
      const { uid } = req.user;
      const { roomId, toUid, text, imageUrl } = req.body;
      
      console.log('📨 Received sendMessage request:', {
        uid,
        roomId,
        toUid,
        text: text ? text.substring(0, 50) : null,
        imageUrl: imageUrl ? 'present' : null,
      });

      if (!roomId || (!text && !imageUrl)) {
        console.log('❌ Missing message content');
        return res.status(400).json({ error: 'Missing message content' });
      }

      const message = {
        roomId,
        from: uid,
        to: toUid,
        text: text || '',
        imageUrl: imageUrl || '',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        isRead: false, // Tin nhắn mới chưa được đọc
        seen: false, // Alias cho isRead
      };

      console.log('💾 Saving message to Firestore...');
      const ref = await db.collection('messages').add(message);
      console.log('✅ Message saved with ID:', ref.id);

      // Send FCM notification
      if (toUid) {
        try {
          await sendFcmToUser(toUid, {
            notification: {
              title: 'New message',
              body: text ? text.slice(0, 120) : 'Image',
            },
            data: { roomId },
          });
          console.log('📱 FCM notification sent');
        } catch (fcmErr) {
          console.log('⚠️ FCM notification failed (non-critical):', fcmErr.message);
        }
      }

      const response = { id: ref.id, ...message };
      console.log('✅ Sending response:', { ...response, createdAt: 'serverTimestamp' });
      return res.status(201).json(response);
    } catch (err) {
      console.error('❌ Error in sendMessage:', err);
      return res.status(500).json({ error: err.message });
    }
  },

  // GET /api/chat/:matchId
  async getMessages(req, res) {
    try {
      const { matchId } = req.params;
      const snap = await db
        .collection('messages')
        .where('roomId', '==', matchId)
        .orderBy('createdAt', 'asc')
        .limit(200)
        .get();
      const items = snap.docs.map(d => ({ id: d.id, ...d.data() }));
      return res.json(items);
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  },

  // GET /api/chat/list - Lấy danh sách recent chats
  async getRecentChats(req, res) {
    try {
      const { uid } = req.user;
      
      // Lấy tất cả match rooms mà user này tham gia
      const matchRoomsSnap = await db.collection('matches')
        .where('users', 'array-contains', uid)
        .get();

      const recentChats = [];

      for (const roomDoc of matchRoomsSnap.docs) {
        const roomData = roomDoc.data();
        const roomId = roomData.roomId;
        
        if (!roomId) continue;

        // Lấy user kia trong room
        const users = roomData.users || [];
        const otherUserId = users.find(id => id !== uid);
        
        if (!otherUserId) continue;

        // Lấy thông tin user kia
        const otherUserDoc = await db.collection('users').doc(otherUserId).get();
        if (!otherUserDoc.exists) continue;
        
        const otherUserData = otherUserDoc.data();

        // Lấy tin nhắn cuối cùng trong room
        const lastMessageSnap = await db.collection('messages')
          .where('roomId', '==', roomId)
          .orderBy('createdAt', 'desc')
          .limit(1)
          .get();

        let lastMessage = '';
        let lastMessageTime = roomData.matchedAt || null;
        let unreadCount = 0;

        if (!lastMessageSnap.empty) {
          const lastMsgData = lastMessageSnap.docs[0].data();
          lastMessage = lastMsgData.text || lastMsgData.imageUrl ? '📷 Hình ảnh' : '';
          lastMessageTime = lastMsgData.createdAt || lastMessageTime;
          
          // Đếm số tin nhắn chưa đọc (từ người kia gửi)
          const unreadSnap = await db.collection('messages')
            .where('roomId', '==', roomId)
            .where('from', '==', otherUserId)
            .where('isRead', '==', false)
            .get();
          
          unreadCount = unreadSnap.size;
        }

        recentChats.push({
          id: roomId,
          roomId: roomId,
          userId: otherUserId,
          name: otherUserData.name || otherUserData.displayName || 'Unknown',
          avatarUrl: otherUserData.avatar_url || otherUserData.avatarUrl || '',
          lastMessage: lastMessage,
          timestamp: lastMessageTime,
          unreadCount: unreadCount,
          matchedAt: roomData.matchedAt,
        });
      }

      // Sắp xếp theo thời gian tin nhắn cuối (mới nhất trước)
      recentChats.sort((a, b) => {
        const timeA = a.timestamp?._seconds || a.timestamp?.seconds || 0;
        const timeB = b.timestamp?._seconds || b.timestamp?.seconds || 0;
        return timeB - timeA;
      });

      return res.json(recentChats);
    } catch (err) {
      console.error('❌ Error in getRecentChats:', err);
      return res.status(500).json({ error: err.message });
    }
  },

  // POST /api/chat/mark-read - Đánh dấu tin nhắn đã đọc
  async markAsRead(req, res) {
    try {
      const { uid } = req.user;
      const { roomId } = req.body;
      
      if (!roomId) {
        return res.status(400).json({ error: 'Missing roomId' });
      }

      // Đánh dấu tất cả tin nhắn từ người kia trong room là đã đọc
      const messagesSnap = await db.collection('messages')
        .where('roomId', '==', roomId)
        .where('from', '!=', uid) // Chỉ đánh dấu tin nhắn từ người kia
        .where('isRead', '==', false)
        .get();

      const batch = db.batch();
      messagesSnap.docs.forEach(doc => {
        batch.update(doc.ref, {
          isRead: true,
          seen: true,
          readAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      });

      await batch.commit();

      return res.json({ ok: true, markedCount: messagesSnap.size });
    } catch (err) {
      console.error('❌ Error in markAsRead:', err);
      return res.status(500).json({ error: err.message });
    }
  },
};


