require('dotenv').config();
const { initializeFirebase } = require('../src/config/firebase');
const admin = initializeFirebase();

(async () => {
  try {
    const auth = admin.auth();
    const db = admin.firestore();

    const samples = [
      {
        email: 'alice@example.com',
        password: 'Password123!@#',
        displayName: 'Alice Nguyen',
        photoURL: 'https://i.pravatar.cc/300?img=5',
        gender: 'female',
        interests: ['Music', 'Travel', 'Books'],
        bio: 'Yêu sách, cà phê và những chuyến đi ngẫu hứng. Tìm bạn đồng hành cùng đọc và khám phá.',
      },
      {
        email: 'bob@example.com',
        password: 'Password123!@#',
        displayName: 'Bob Tran',
        photoURL: 'https://i.pravatar.cc/300?img=12',
        gender: 'male',
        interests: ['Fitness', 'Tech', 'Movies'],
        bio: 'Thích chạy bộ buổi sáng, mê công nghệ và phim sci‑fi. Luôn sẵn sàng cho thử thách mới.',
      },
    ];

    const userIds = [];

    // Bước 1: Tạo users và lưu UIDs
    for (const s of samples) {
      // Create or get user
      let userRecord;
      try {
        userRecord = await auth.getUserByEmail(s.email);
        console.log(`Found existing user: ${s.email}`);
      } catch (_) {
        userRecord = await auth.createUser({
          email: s.email,
          password: s.password,
          displayName: s.displayName,
          photoURL: s.photoURL,
          emailVerified: true,
        });
        console.log(`Created user: ${s.email}`);
      }

      const uid = userRecord.uid;
      userIds.push(uid);

      // Seed Firestore profile
      const docRef = db.collection('users').doc(uid);
      await docRef.set(
        {
          user_id: uid,
          email: s.email,
          name: s.displayName,
          avatar_url: s.photoURL,
          gender: s.gender,
          interests: s.interests,
          bio: s.bio,
          profileComplete: true,
          role: 'user',
          created_at: admin.firestore.FieldValue.serverTimestamp(),
          updated_at: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      console.log(`Seeded Firestore profile for ${s.email}`);
    }

    // Bước 2: Tạo mutual likes để matching
    if (userIds.length === 2) {
      const [uid1, uid2] = userIds;
      
      // Alice like Bob
      await db.collection('matches').doc(`${uid1}_${uid2}`).set({
        from: uid1,
        to: uid2,
        action: 'like',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
      console.log(`✅ Created like: ${samples[0].displayName} → ${samples[1].displayName}`);

      // Bob like Alice
      await db.collection('matches').doc(`${uid2}_${uid1}`).set({
        from: uid2,
        to: uid1,
        action: 'like',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
      console.log(`✅ Created like: ${samples[1].displayName} → ${samples[0].displayName}`);

      // Bước 3: Tạo match room (chat room)
      const roomId = [uid1, uid2].sort().join('_');
      await db.collection('matches').doc(`room_${roomId}`).set({
        users: [uid1, uid2],
        roomId,
        matchedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
      console.log(`✅ Created match room: ${roomId}`);

      // Bước 4: Tạo một vài tin nhắn mẫu
      const sampleMessages = [
        { from: uid1, to: uid2, text: 'Xin chào! 👋' },
        { from: uid2, to: uid1, text: 'Chào bạn! Rất vui được match với bạn 😊' },
        { from: uid1, to: uid2, text: 'Bạn có sở thích gì không? Mình thích đọc sách và du lịch!' },
        { from: uid2, to: uid1, text: 'Mình thích fitness và công nghệ. Có vẻ chúng ta có nhiều điểm chung!' },
      ];

      for (const msg of sampleMessages) {
        await db.collection('messages').add({
          roomId,
          from: msg.from,
          to: msg.to,
          text: msg.text,
          imageUrl: '',
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
      console.log(`✅ Created ${sampleMessages.length} sample messages`);
    }

    console.log('\n✔️  Seeding done!');
    console.log('\n📧 Login credentials:');
    samples.forEach((s, i) => {
      console.log(`  ${i + 1}. ${s.email} / ${s.password}`);
    });
    console.log('\n💬 2 users are now matched and can chat with each other!');
    process.exit(0);
  } catch (err) {
    console.error('Seeding failed:', err);
    process.exit(1);
  }
})();


