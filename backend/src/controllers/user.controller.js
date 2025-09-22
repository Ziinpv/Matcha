const { initializeFirebase } = require('../config/firebase');
initializeFirebase();
const admin = require('firebase-admin');
const db = admin.firestore();

module.exports = {
  async getProfile(req, res) {
    try {
      const { id } = req.params;
      const snap = await db.collection('users').doc(id).get();
      if (!snap.exists) return res.status(404).json({ error: 'User not found' });
      return res.json(snap.data());
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  },

  async updateProfile(req, res) {
    try {
      const { id } = req.params;
      if (req.user.uid !== id) return res.status(403).json({ error: 'Forbidden' });
      const updates = { ...req.body, updatedAt: admin.firestore.FieldValue.serverTimestamp() };
      await db.collection('users').doc(id).set(updates, { merge: true });
      const fresh = await db.collection('users').doc(id).get();
      return res.json(fresh.data());
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  },
};


