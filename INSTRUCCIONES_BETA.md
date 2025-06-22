# Instrucciones para Generar la Versiu00f3n Beta de Rentem

## Preparaciu00f3n del Entorno

1. **Requisitos previos**:
   - Flutter SDK instalado y configurado
   - Android SDK instalado (con API level 35)
   - Java Development Kit (JDK) instalado

2. **Verificar configuraciu00f3n**:
   ```bash
   flutter doctor
   ```

## Configuraciu00f3n de Firma (IMPORTANTE)

Para subir una aplicaciu00f3n a Google Play, DEBE estar firmada con claves de lanzamiento, no de depuraciu00f3n.

1. **Crear archivo key.properties**:
   - Crea un archivo `android/key.properties` basado en el ejemplo proporcionado
   - Completa con las credenciales correctas del keystore

```
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=rentem
storeFile=../app/rentem-key.keystore
```

> **IMPORTANTE**: No compartas nunca este archivo en Git. Ya estu00e1 incluido en .gitignore por seguridad.

2. **Verificar el keystore**:
   - Asegu00farate de que el archivo `rentem-key.keystore` existe en `android/app/`
   - Si necesitas generar uno nuevo, usa el siguiente comando:
   ```bash
   keytool -genkey -v -keystore android/app/rentem-key.keystore -alias rentem -keyalg RSA -keysize 2048 -validity 10000
   ```

## Generar APK para Distribuciu00f3n

Ejecutar el siguiente comando para generar un APK firmado correctamente:

```bash
flutter clean
flutter build apk --release
```

El APK se generaru00e1 en la ruta: `build/app/outputs/flutter-apk/app-release.apk`

## Generar App Bundle (AAB) para Google Play

Ejecutar el siguiente comando para generar un AAB firmado para Google Play:

```bash
flutter clean
flutter build appbundle
```

El AAB se generaru00e1 en la ruta: `build/app/outputs/bundle/release/app-release.aab`

## Publicaciu00f3n en Google Play Console

1. Accede a [Google Play Console](https://play.google.com/console/)
2. Crea una nueva aplicaciu00f3n o selecciona la existente
3. Ve a la secciu00f3n "Testing" > "Open testing" o "Closed testing"
4. Sube el archivo AAB generado
5. Completa toda la informaciu00f3n necesaria:
   - Imu00e1genes de la aplicaciu00f3n
   - Descripciu00f3n
   - Capturas de pantalla
   - Polu00edticas de privacidad
6. Envu00eda la versiu00f3n para revisiu00f3n

## Distribuciu00f3n Manual del APK

Si deseas distribuir el APK directamente para pruebas:

1. Envu00eda el archivo APK a los testers por correo electru00f3nico o servicio de almacenamiento
2. Los testers necesitaru00e1n habilitar "Fuentes desconocidas" en sus dispositivos
3. Instalar el APK directamente en el dispositivo

## Notas Importantes

- La versiu00f3n actual de la aplicaciu00f3n es **0.9.0+1** (versiu00f3n beta)
- Recuerda excluir de Git los directorios `.cxx` que contienen archivos de compilaciu00f3n C/C++ de Android 
- El keystore y las credenciales deben guardarse de forma segura
- NUNCA subas claves de firma a repositorios de control de versiones
