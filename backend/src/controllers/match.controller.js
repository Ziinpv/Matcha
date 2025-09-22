const { initializeFirebase } = require('../config/firebase');
initializeFirebase();
const admin = require('firebase-admin');
const db = admin.firestore();

module.exports = {
  // POST /api/match/swipe { targetUid, action: 'like'|'dislike' }
  async swipe(req, res) {
    try {
      const { uid } = req.user;
      const { targetUid, action } = req.body;
      if (!targetUid || !['like', 'dislike'].includes(action)) {
        return res.status(400).json({ error: 'Invalid payload' });
      }

      await db
        .collection('matches')
        .doc(`${uid}_${targetUid}`)
        .set({
          from: uid,
          to: targetUid,
          action,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });

      return res.json({ ok: true });
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  },

  // POST /api/match/check { targetUid }
  async checkMatch(req, res) {
    try {
      const { uid } = req.user;
      const { targetUid } = req.body;
      if (!targetUid) return res.status(400).json({ error: 'Missing targetUid' });

      const a = await db.collection('matches').doc(`${uid}_${targetUid}`).get();
      const b = await db.collection('matches').doc(`${targetUid}_${uid}`).get();

      const isMutual = a.exists && a.data().action === 'like' && b.exists && b.data().action === 'like';

      if (isMutual) {
        const roomId = [uid, targetUid].sort().join('_');
        await db.collection('matches').doc(`room_${roomId}`).set({
          users: [uid, targetUid],
          roomId,
          matchedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
        return res.json({ matched: true, roomId });
      }

      return res.json({ matched: false });
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  },

  // GET /api/match/list
  async getMatches(req, res) {
    try {
      const { uid } = req.user;
      const snaps = await db.collection('matches').where('users', 'array-contains', uid).get();
      const items = snaps.docs.map(d => d.data());
      return res.json(items);
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  },
};


