# Play Console - Paso a Paso (Finder)

Fecha de referencia: 2026-05-02

## 1) Preparar Firebase
1. Crear/usar proyecto Firebase final.
2. Descargar `google-services.json` de Android y copiar en:
   - `android/app/google-services.json`
3. En Firebase -> Project Settings -> tu app Android:
   - Cargar SHA-1 y SHA-256 de debug/release.
4. Verificar servicios activos:
   - Authentication: Google + Anonymous
   - Firestore
   - Cloud Messaging

## 2) Preparar backend Functions
1. Entrar a `functions/` y correr `npm ci`.
2. Configurar variables:
   - `ANDROID_PACKAGE_NAME` (obligatoria)
   - `TRUST_CLIENT_PURCHASES=true` (solo dev/testing si aplica)
3. Deploy:
   - `firebase deploy --only functions`

## 3) Preparar assets y listing
1. Correr:
   - `powershell -ExecutionPolicy Bypass -File scripts/prepare_play_store.ps1`
2. Assets generados:
   - `assets/branding/finder_launcher_1024.png`
   - `assets/branding/finder_feature_graphic_1024x500.png`
3. Copy listing:
   - usar `PLAY_STORE_METADATA_ES.md`

## 4) Build de release
1. Correr:
   - `powershell -ExecutionPolicy Bypass -File scripts/release_build.ps1`
2. Resultado esperado:
   - `build/app/outputs/bundle/release/app-release.aab`

## 5) Subida a Play Console (Closed Testing)
1. Play Console -> app Finder -> Testing cerrado.
2. Crear nueva release y subir `app-release.aab`.
3. Completar notas de version (usar `RELEASE_NOTES_1.0.1.md`).
4. Guardar y revisar warnings.
5. Publicar en track cerrado.
6. Agregar testers (emails o grupo).

## 6) Verificacion post-subida
1. Instalar build desde track cerrado.
2. Probar:
   - Login
   - Onboarding
   - Match + chat
   - Push
   - Compra y aplicacion de entitlements
