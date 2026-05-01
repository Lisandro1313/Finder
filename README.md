# Finder App

Base MVP de app de citas para Android con Flutter.

## Estado actual

- Flujo inicial de login.
- Autenticacion integrada por Firebase Auth (anonima para MVP).
- Descubrir perfiles + likes + superlikes + matches + chat.
- Compras Play Billing con encolado server-side en `purchase_events`.
- Safety base: reportes y bloqueos.
- Push token guardado para notificaciones (Firebase Messaging).

## Setup rapido

1. Activar `Developer Mode` en Windows (para symlinks Flutter).
2. Crear proyecto Firebase.
3. Configurar app Android (`google-services.json`) en `android/app/`.
4. Habilitar en Firebase:
   - Authentication -> Anonymous
   - Firestore Database
   - Cloud Messaging
5. Crear coleccion `profiles` con documentos usando `sample_profiles.json` como referencia.
6. Publicar reglas `firestore.rules`.

## Cloud Functions (compra server-side)

1. Instalar Firebase CLI y loguearte.
2. Entrar a `functions/` e instalar deps:
   - `npm install`
3. Para pruebas dev (sin verificacion real de Google Play):
   - setear variable `TRUST_CLIENT_PURCHASES=true` en Functions.
4. Deploy:
   - `firebase deploy --only functions`

## Ejecutar app

```bash
flutter pub get
flutter run
```

## Nota

Si Firebase no esta configurado aun, la app entra en modo mock automaticamente.
