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

### Chạy trên 2 Emulator (Test Match & Chat)

**Cách 1: Dùng script tự động**
```powershell
.\scripts\run-on-two-emulators.ps1
```

**Cách 2: Chạy thủ công**
1. Khởi động backend: `cd backend && npm run dev`
2. Terminal 1: `cd frontend && flutter run -d emulator-5554`
3. Terminal 2: `cd frontend && flutter run -d emulator-5556`

Xem chi tiết: `docs/RUN_ON_TWO_EMULATORS.md`

See `docs/` for more details.
