const { initializeFirebase } = require('../config/firebase');
initializeFirebase();
const admin = require('firebase-admin');
const db = admin.firestore();

module.exports = {
  // POST /api/block { targetUid }
  async blockUser(req, res) {
    try {
      const { uid } = req.user;
      const { targetUid } = req.body;
      if (!targetUid) return res.status(400).json({ error: 'Missing targetUid' });

      await db.collection('blockedUsers').doc(`${uid}_${targetUid}`).set({
        by: uid,
        target: targetUid,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      return res.json({ ok: true });
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  },

  // GET /api/block/list
  async getBlockedList(req, res) {
    try {
      const { uid } = req.user;
      const snap = await db.collection('blockedUsers').where('by', '==', uid).get();
      const items = snap.docs.map(d => d.data());
      return res.json(items);
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  },
};


