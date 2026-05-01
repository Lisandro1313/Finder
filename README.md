# Finder App

Base MVP de app de citas para Android con Flutter.

## Estado actual

- Login + onboarding + discover + likes + superlikes + matches + chat.
- Compras Play Billing con pipeline server-side (`purchase_events`).
- Safety base: reportes y bloqueos.
- Push token registrado en `profiles` y Functions de push para match/mensaje.

## Setup rapido

1. Activar `Developer Mode` en Windows (para symlinks Flutter).
2. Crear proyecto Firebase.
3. Configurar app Android (`google-services.json`) en `android/app/`.
4. Habilitar en Firebase:
   - Authentication -> Anonymous
   - Firestore Database
   - Cloud Messaging
5. Publicar reglas `firestore.rules`.

## Cloud Functions

1. Instalar Firebase CLI y loguearte.
2. Entrar a `functions/` e instalar deps:
   - `npm install`
3. Configurar variable obligatoria para verificacion Play:
   - `ANDROID_PACKAGE_NAME` (ejemplo: `com.tuempresa.finder`)
4. Para pruebas dev sin verificacion real:
   - `TRUST_CLIENT_PURCHASES=true`
5. Deploy:
   - `firebase deploy --only functions`

## Ejecutar app

```bash
flutter pub get
flutter run
```

## Nota

Si Firebase no esta configurado aun, la app entra en modo mock automaticamente.
