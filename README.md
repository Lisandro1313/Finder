# Finder App

Base MVP de app de citas para Android con Flutter.

## Estado actual

- Login + onboarding + discover + likes + superlikes + matches + chat.
- Google Sign-In activo con fallback anonimo para testing.
- Compras Play Billing con pipeline server-side (`purchase_events`).
- Safety base: reportes y bloqueos.
- Push token registrado y Functions de push para match/mensaje.

## Setup rapido

1. Activar `Developer Mode` en Windows (para symlinks Flutter).
2. Crear proyecto Firebase.
3. Configurar app Android (`google-services.json`) en `android/app/`.
4. En Firebase Console -> Project Settings -> agregar SHA-1 y SHA-256 del keystore debug/release.
5. Habilitar en Firebase:
   - Authentication -> Google + Anonymous
   - Firestore Database
   - Cloud Messaging
6. Publicar reglas `firestore.rules`.

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

## QA checklist (Android fisico)

1. Login con Google funciona.
2. Si Google falla, entra anónimo y permite continuar.
3. Crear perfil y verlo en `profiles/{uid}`.
4. Dar likes y generar match reciproco.
5. Enviar mensaje y recibir push en otro dispositivo.
6. Comprar producto test en Play y verificar `purchase_events` -> `status: applied`.
7. Verificar aumento de entitlements (`plusActive`, `boostCount`, `superLikeCount`).
8. Bloquear/reportar usuario y confirmar que bloqueados no matchean.

## Ejecutar app

```bash
flutter pub get
flutter run
```

## Nota

Si Firebase no esta configurado aun, la app entra en modo mock automaticamente.
