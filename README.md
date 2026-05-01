# Finder App

Base MVP de app de citas para Android con Flutter.

## Estado actual

- Login + onboarding + discover + likes + superlikes + matches + chat.
- Google Sign-In activo con fallback anonimo para testing.
- Compras Play Billing con pipeline server-side (`purchase_events`).
- Safety base: reportes y bloqueos.
- Push token registrado y Functions de push para match/mensaje.
- Panel de moderacion basico para admins en Perfil.
- Observabilidad de compras en Premium (status feed de `purchase_events`).

## Setup rapido

1. Activar `Developer Mode` en Windows (para symlinks Flutter).
2. Crear proyecto Firebase.
3. Configurar app Android (`google-services.json`) en `android/app/`.
4. En Firebase Console -> Project Settings -> agregar SHA-1 y SHA-256 del keystore debug/release.
5. Habilitar en Firebase:
   - Authentication -> Google + Anonymous
   - Firestore Database
   - Cloud Messaging
6. Publicar reglas e indices:
   - `firebase deploy --only firestore`

## Activar admin para moderacion

Crear documento en `admin_users/{uid}` para el usuario que administrara reportes.
Con eso se habilita el panel "Moderacion (Admin)" en Perfil.

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

## Nota de produccion (pagos)

En release, la app exige `verificationData` para crear `purchase_events`.
Si falta, rechaza la operacion localmente para evitar compras sin verificacion.

## Preflight de release

Checklist completo: `RELEASE_CHECKLIST.md`

Chequeo automatico local:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/preflight.ps1
```

Build AAB automatizado:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/release_build.ps1
```

## Ejecutar app

```bash
flutter pub get
flutter run
```

## Nota

Si Firebase no esta configurado aun, la app entra en modo mock automaticamente.
