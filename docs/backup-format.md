# Respaldos recuperables (v2)

Para recuperar un respaldo basta el archivo JSON y la contraseña elegida al
crearlo, incluso en otra instalación. La contraseña no se guarda en Hive ni en
el archivo. Si se pierde, la aplicación no puede recuperar el respaldo.

## Formato

El objeto JSON contiene `version: 2`, `cipher: AES-256-GCM`,
`kdf: PBKDF2-HMAC-SHA256`, `iterations: 600000`, `keyLength: 32`, `salt`,
`nonce` y `data`. Los tres últimos campos usan Base64 canónico. El salt tiene
16 bytes y el nonce 12 bytes, generados con `Random.secure()` en cada respaldo.
`data` concatena el texto cifrado y la etiqueta de autenticación de 16 bytes.

La contraseña se codifica en UTF-8 exactamente como se escribió, sin recortar
espacios ni normalizar Unicode. Al crear se requieren 12 caracteres Unicode.
PBKDF2 deriva 32 bytes. La restauración admite entre 600000 y 1200000 iteraciones
para limitar el trabajo provocado por parámetros de archivos externos.

Los datos adicionales autenticados de GCM son el UTF-8 del array JSON compacto
`[version,cipher,kdf,iterations,keyLength,salt,nonce]`, en ese orden. El contenido
cifrado es el JSON de `BackupContent`. Se verifica la autenticación antes de
interpretar ese contenido o iniciar la restauración en SQLite. En plataformas
nativas, `compute` ejecuta la derivación fuera del hilo de interfaz.

Implementación basada en las APIs de
[Pointy Castle](https://pub.dev/packages/pointycastle/versions/3.9.1).

## Archivos v1

La nueva ruta de restauración rechaza v1 con instrucciones explícitas: requieren
la clave de la instalación original, no una contraseña. Se deben restaurar con
la versión anterior en esa instalación y, después de actualizar, crear un v2.
No es posible convertir un v1 sin su clave. La clave local antigua se conserva;
los nuevos respaldos no la utilizan. No hay conversión automática ni cambios
en los archivos existentes.

## Comprobación manual

1. Crear un respaldo con contraseña y confirmación.
2. En una instalación de prueba, restaurarlo usando esa contraseña y verificar
   movimientos, categorías y presupuestos.
3. Intentar restaurar con otra contraseña: debe fallar sin modificar datos.
