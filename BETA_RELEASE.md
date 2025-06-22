# Instrucciones para el lanzamiento Beta de Rentem

## Preparaciu00f3n del entorno

1. **Configura el archivo local.properties**:
   - Copia el archivo `android/local.properties.example` a `android/local.properties`
   - Actualiza las rutas del SDK y las contraseu00f1as del keystore segu00fan tu configuraciu00f3n

2. **Verifica la configuraciu00f3n del Keystore**:
   - Asegu00farate de que el archivo `android/app/rentem-key.keystore` existe
   - Guarda tu contraseu00f1a del keystore en un lugar seguro (no en el repositorio)

## Construir el APK para beta

```bash
flutter build apk --release
```

El APK se generaru00e1 en: `build/app/outputs/flutter-apk/app-release.apk`

## Construir un App Bundle (recomendado para Google Play)

```bash
flutter build appbundle --release
```

El bundle se generaru00e1 en: `build/app/outputs/bundle/release/app-release.aab`

## Subir a Google Play Console

1. Accede a [Google Play Console](https://play.google.com/console)
2. Selecciona tu aplicaciu00f3n (o crea una nueva)
3. Ve a "Testing" > "Open Testing" o "Closed Testing"
4. Sube el archivo `.aab` o `.apk`
5. Completa la informaciu00f3n requerida (descripciones, capturas de pantalla, etc.)
6. Envu00eda para revisiu00f3n

## Nota importante

Asegu00farate de excluir los siguientes archivos del repositorio Git:

- `android/app/rentem-key.keystore` (clave privada)
- `android/local.properties` (contiene informaciu00f3n sensible)
- Directorios `.cxx` (archivos de compilaciu00f3n C/C++)

Verifica que estu00e1n incluidos en tu archivo `.gitignore`.
