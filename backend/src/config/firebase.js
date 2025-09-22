const admin = require('firebase-admin');

let appInitialized = false;

function initializeFirebase() {
  if (appInitialized) return admin;

  const credentialsJson = process.env.FIREBASE_CREDENTIALS;
  const storageBucket = process.env.FIREBASE_STORAGE_BUCKET;

  if (!credentialsJson) {
    // Allow server to boot without Firebase for local dev; controllers will fail on use.
    console.warn('FIREBASE_CREDENTIALS not set. Firebase Admin not initialized.');
    appInitialized = true;
    return admin;
  }

  // Support both base64-encoded JSON or raw JSON string
  let serviceAccount;
  try {
    const decoded = Buffer.from(credentialsJson, 'base64').toString('utf8');
    serviceAccount = JSON.parse(decoded);
  } catch (_) {
    // Not base64
    serviceAccount = JSON.parse(credentialsJson);
  }

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    storageBucket,
  });

  appInitialized = true;
  return admin;
}

module.exports = { admin, initializeFirebase };


