# Matcha Monorepo

- `frontend/` – Flutter app (Android, iOS, Web)
- `backend/` – Node.js + Express + Firebase Admin
- `docs/` – Project documentation

## Quick Start

### Backend
1) Create `.env` in `backend/` and fill: `PORT`, `JWT_SECRET`, `FIREBASE_CREDENTIALS`, `FIREBASE_STORAGE_BUCKET`
2) Install and run:
```
cd backend
npm install
npm run dev
```
Health: http://localhost:4000/health

### Frontend
```
cd frontend
flutter pub get
flutter run
```

See `docs/` for more details.
