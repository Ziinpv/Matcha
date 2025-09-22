# Matcha Backend (Node.js + Express + Firebase)

## Setup
1. Create `.env` based on `.env.example`.
2. Put Firebase service account JSON (raw or base64) into `FIREBASE_CREDENTIALS`.
3. Set `FIREBASE_STORAGE_BUCKET` to your bucket, e.g. `your-project.appspot.com`.
4. Install dependencies and run:

```bash
cd backend
npm install
npm run dev
```

## API
- POST `/api/auth/register`
- POST `/api/auth/login`
- GET `/api/user/:id`
- PUT `/api/user/:id`
- POST `/api/match/swipe`
- POST `/api/match/check`
- GET `/api/match/list`
- POST `/api/chat/send`
- GET `/api/chat/:matchId`
- POST `/api/block`
- GET `/api/block/list`

All protected routes require `Authorization: Bearer <jwt>`.


