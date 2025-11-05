const fs = require('fs');
const path = require('path');

const admin = require('firebase-admin');

let appInitialized = false;

function initializeFirebase() {
  if (appInitialized) return admin;

  const credentialsPath = process.env.FIREBASE_CREDENTIALS;
  const storageBucket = process.env.FIREBASE_STORAGE_BUCKET;

  if (!credentialsPath) {
    console.warn('FIREBASE_CREDENTIALS not set. Firebase Admin not initialized.');
    appInitialized = true;
    return admin;
  }

  let serviceAccount;
  if (fs.existsSync(path.resolve(credentialsPath))) {
    // Nếu là đường dẫn file
    serviceAccount = require(path.resolve(credentialsPath));
  } else {
    // Nếu là JSON string hoặc base64
    try {
      const decoded = Buffer.from(credentialsPath, 'base64').toString('utf8');
      serviceAccount = JSON.parse(decoded);
    } catch (_) {
      serviceAccount = JSON.parse(credentialsPath);
    }
  }

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    storageBucket,
  });

  appInitialized = true;
  return admin;
}

module.exports = { admin, initializeFirebase };
