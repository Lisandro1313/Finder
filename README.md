# Finder App

Base MVP de app de citas para Android con Flutter.

## Estado actual

- Flujo inicial de login.
- Autenticacion integrada por Firebase Auth (anonima para MVP).
- Descubrir perfiles conectado a Firestore (`profiles`) con fallback local.
- Shell de pantallas para Matches, Chats, Premium y Perfil.

## Setup rapido

1. Activar `Developer Mode` en Windows (para symlinks Flutter).
2. Crear proyecto Firebase.
3. Configurar app Android (`google-services.json`) en `android/app/`.
4. Habilitar en Firebase:
   - Authentication -> Anonymous
   - Firestore Database
5. Crear coleccion `profiles` con documentos usando `sample_profiles.json` como referencia.
6. (Opcional) Publicar reglas iniciales usando `firestore.rules`.

## Ejecutar

```bash
flutter pub get
flutter run
```

## Nota

Si Firebase no esta configurado aun, la app entra en modo mock automaticamente.
