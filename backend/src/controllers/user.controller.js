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

  // GET /api/user/profile-status
  async getProfileStatus(req, res) {
    try {
      const uid = req.user?.uid;
      if (!uid) return res.status(401).json({ error: 'Unauthorized' });

      const snap = await db.collection('users').doc(uid).get();
      if (!snap.exists) {
        return res.json({ profileComplete: false });
      }
      const data = snap.data() || {};

      const avatar = data.avatar_url || data.avatarUrl;
      const displayName = data.name || data.displayName;
      const bio = typeof data.bio === 'string' ? data.bio : '';
      const gender = data.gender;
      const interests = Array.isArray(data.interests) ? data.interests : [];

      const profileComplete = Boolean(
        avatar && displayName && gender && bio && bio.trim().length >= 30 && interests.length > 0
      );

      return res.json({ profileComplete });
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  },

  // POST /api/user/complete-profile
  async completeProfile(req, res) {
    try {
      const uid = req.user?.uid;
      if (!uid) {
        console.log('❌ completeProfile: Unauthorized - no uid');
        return res.status(401).json({ error: 'Unauthorized' });
      }

      console.log('📥 completeProfile request from uid:', uid);
      console.log('📥 Request body:', JSON.stringify(req.body, null, 2));

      const {
        avatar_url,
        avatarUrl,
        displayName,
        name,
        bio,
        gender,
        interests,
        preferences,
      } = req.body || {};

      const resolvedAvatar = avatar_url || avatarUrl;
      const resolvedName = name || displayName;
      const interestsArr = Array.isArray(interests) ? interests : [];

      // Validate từng field với thông báo lỗi rõ ràng
      const missingFields = [];
      if (!resolvedAvatar || resolvedAvatar.trim() === '') {
        missingFields.push('avatar_url');
      }
      if (!resolvedName || resolvedName.trim() === '') {
        missingFields.push('displayName');
      }
      if (!gender || gender.trim() === '') {
        missingFields.push('gender');
      }
      if (!bio || typeof bio !== 'string' || bio.trim() === '') {
        missingFields.push('bio');
      }
      if (interestsArr.length === 0) {
        missingFields.push('interests');
      }

      if (missingFields.length > 0) {
        console.log('❌ Missing required fields:', missingFields);
        return res.status(400).json({ 
          error: 'Missing required fields',
          missingFields: missingFields,
          message: `Thiếu các trường bắt buộc: ${missingFields.join(', ')}`
        });
      }

      // Validate bio length
      if (typeof bio !== 'string' || bio.trim().length < 30) {
        console.log('❌ Bio validation failed. Length:', bio.trim().length);
        return res.status(400).json({ 
          error: 'Invalid bio',
          message: 'Bio phải có ít nhất 30 ký tự',
          currentLength: bio.trim().length
        });
      }

      // Validate avatar URL format (should be a valid URL)
      try {
        const avatarUrlObj = new URL(resolvedAvatar);
        if (!avatarUrlObj.protocol.startsWith('http')) {
          throw new Error('Invalid protocol');
        }
      } catch (urlError) {
        console.log('❌ Invalid avatar URL format:', resolvedAvatar);
        return res.status(400).json({ 
          error: 'Invalid avatar_url',
          message: 'URL ảnh đại diện không hợp lệ',
          providedUrl: resolvedAvatar
        });
      }

      // Validate displayName không chứa ký tự đặc biệt nguy hiểm
      if (resolvedName.includes('/') || resolvedName.includes('\\') || resolvedName.includes(':')) {
        console.log('❌ Invalid displayName contains special characters:', resolvedName);
        return res.status(400).json({ 
          error: 'Invalid displayName',
          message: 'Tên hiển thị không được chứa ký tự đặc biệt (/, \\, :)',
          providedName: resolvedName
        });
      }

      console.log('✅ Validation passed. Saving profile...');
      console.log('   - avatar_url:', resolvedAvatar.substring(0, 50) + '...');
      console.log('   - displayName:', resolvedName);
      console.log('   - gender:', gender);
      console.log('   - bio length:', bio.trim().length);
      console.log('   - interests count:', interestsArr.length);

      const payload = {
        avatar_url: resolvedAvatar,
        name: resolvedName,
        gender,
        bio: bio.trim(),
        interests: interestsArr,
        preferences: preferences || null,
        profileComplete: true,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      await db.collection('users').doc(uid).set(payload, { merge: true });
      const fresh = await db.collection('users').doc(uid).get();
      
      console.log('✅ Profile saved successfully for uid:', uid);
      return res.json({ ok: true, user: fresh.data() });
    } catch (err) {
      console.error('❌ Error in completeProfile:', err);
      console.error('   Stack:', err.stack);
      return res.status(500).json({ 
        error: 'Internal server error',
        message: err.message 
      });
    }
  },
};


