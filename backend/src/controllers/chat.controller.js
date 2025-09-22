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
      if (!roomId || (!text && !imageUrl)) return res.status(400).json({ error: 'Missing message content' });

      const message = {
        roomId,
        from: uid,
        to: toUid,
        text: text || '',
        imageUrl: imageUrl || '',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      };
      const ref = await db.collection('messages').add(message);

      // Send FCM notification
      if (toUid) {
        await sendFcmToUser(toUid, {
          notification: {
            title: 'New message',
            body: text ? text.slice(0, 120) : 'Image',
          },
          data: { roomId },
        });
      }

      return res.status(201).json({ id: ref.id, ...message });
    } catch (err) {
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
};


