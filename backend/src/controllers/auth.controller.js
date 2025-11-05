const { initializeFirebase } = require('../config/firebase');
const { signJwt } = require('../utils/jwt');

initializeFirebase();
const admin = require('firebase-admin');
const db = admin.firestore();

module.exports = {
  // POST /api/auth/register
  async register(req, res) {
    try {
      const { email, password, name, avatarUrl, additionalData } = req.body;
      if (!email || !password) return res.status(400).json({ error: 'Missing email or password' });

      const userRecord = await admin.auth().createUser({ email, password, displayName: name, photoURL: avatarUrl });

      const userDoc = {
        uid: userRecord.uid,
        email,
        name: name || '',
        avatarUrl: avatarUrl || '',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        ...additionalData,
      };
      await db.collection('users').doc(userRecord.uid).set(userDoc, { merge: true });

      const token = signJwt({ uid: userRecord.uid, email });
      return res.status(201).json({ token, user: userDoc });
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  },

  // POST /api/auth/login
  async login(req, res) {
    try {
      const { uid, email } = req.body;
      // In mobile apps, client typically authenticates via Firebase Auth SDK to get UID
      // Here we accept uid/email from client after Firebase Auth sign-in, then issue our JWT.
      if (!uid || !email) return res.status(400).json({ error: 'Missing uid or email' });

      const userSnap = await db.collection('users').doc(uid).get();
      if (!userSnap.exists) return res.status(404).json({ error: 'User not found' });
      const token = signJwt({ uid, email });
      return res.json({ token });
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  },
};


