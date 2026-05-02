# Release Checklist (Closed Testing)

## 1) Firebase + Play setup

- [ ] `android/app/google-services.json` final
- [ ] SHA-1 and SHA-256 loaded in Firebase Project Settings
- [ ] Firebase Auth: Google + Anonymous enabled
- [ ] Firestore database enabled
- [ ] Storage enabled
- [ ] Cloud Messaging enabled
- [ ] Firestore/Storage rules and indexes deployed (`firebase deploy --only firestore,storage`)

## 2) Functions setup

- [ ] `npm ci` inside `functions/`
- [ ] Env var `ANDROID_PACKAGE_NAME` configured in Functions
- [ ] (Optional dev only) `TRUST_CLIENT_PURCHASES=true`
- [ ] Functions deployed (`firebase deploy --only functions`)

## 3) App quality gates

- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
- [ ] CI workflow green on `main`

## 4) Payments QA

- [ ] Product IDs exist in Play Console:
  - `finder_plus_monthly`
  - `finder_boost_pack`
  - `finder_superlike_pack`
- [ ] Test purchase succeeds
- [ ] `purchase_events` gets `status: applied`
- [ ] Entitlements update in `users/{uid}`

## 5) E2E social flow

- [ ] User A and B login
- [ ] Permiso de ubicacion aceptado y distancia real visible en Discover
- [ ] Match created
- [ ] Chat message received
- [ ] Push notification received
- [ ] Block/report flow works

## 6) Build and upload

- [ ] Run release build script (`scripts/release_build.ps1`)
- [ ] Upload generated AAB to Play Console closed testing
- [ ] Add testers
- [ ] Validate crash-free startup and core flows

## 7) Store listing assets

- [ ] Run Play Store asset prep (`scripts/prepare_play_store.ps1`)
- [ ] Upload icon + feature graphic from `assets/branding/`
- [ ] Paste listing copy from `PLAY_STORE_METADATA_ES.md`

## Helpers

Preflight:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/preflight.ps1
```

Release build:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/release_build.ps1
```

Play Store assets:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/prepare_play_store.ps1
```
