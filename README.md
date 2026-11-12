# Mi Presupuesto

Aplicación de finanzas personales desarrollada con Flutter para registrar ingresos y gastos, organizar presupuestos mensuales y consultar el historial financiero.

El proyecto se llama `control_financiero` en el código. La interfaz está en español, con configuración regional `es_EC` y zona horaria `America/Guayaquil`.

## Funciones

- Registro de movimientos por categoría y búsqueda paginada con filtros.
- Presupuestos por categoría e ingreso presupuestado para cada mes.
- Historial financiero y administración de categorías y tipos de categorías.
- Recordatorios, notificaciones y configuración de umbrales de presupuesto.
- Exportación de movimientos a Excel, respaldos cifrados con contraseña y restauración de datos.

## Requisitos

- Flutter con una versión de Dart compatible con `^3.10.4`, según `pubspec.yaml`.
- **Java JDK 21 (LTS)** para depurar y generar compilaciones Android, incluidos los releases. Configura Flutter y el entorno de compilación para utilizar este JDK y evitar problemas de compatibilidad.
- Android SDK y herramientas de compilación para ejecutar o generar la aplicación Android.
- Un dispositivo Android o emulador para comprobar la aplicación y sus permisos.

Comprueba el JDK antes de ejecutar o compilar:

```powershell
java -version
flutter doctor -v
```

`java -version` debe mostrar la versión 21. En `flutter doctor -v`, verifica que el JDK utilizado por Flutter también sea el 21; puede diferir del configurado en `PATH`. Si Flutter utiliza otro JDK, selecciona el correcto con `flutter config --jdk-dir "C:\ruta\al\jdk-21"`, sustituyendo la ruta por la de tu instalación.

El repositorio incluye carpetas para Android, iOS, Linux, macOS, Windows y Web. Esto no garantiza compatibilidad completa: el arranque utiliza `dart:io` y los servicios dependen de complementos nativos. Los comandos siguientes corresponden a Android.

## Inicio rápido

Ejecuta los comandos desde la raíz del repositorio. Los ejemplos utilizan PowerShell.

1. Comprueba el entorno:

   ```powershell
   flutter doctor
   ```

2. Instala las dependencias:

   ```powershell
   flutter pub get
   ```

3. Inicia la aplicación de desarrollo en un dispositivo o emulador:

   ```powershell
   flutter run --flavor dev --dart-define=FLAVOR=dev
   ```

### Entornos Android

| Entorno | Nombre visible | Identificador de aplicación |
| --- | --- | --- |
| `dev` | Mi Presupuesto DEV | `com.example.control_financiero.dev` |
| `prod` | Mi Presupuesto | `com.example.control_financiero` |

Pasa tanto `--flavor` como `--dart-define=FLAVOR=...`: el primero selecciona la configuración Android y el segundo configura `AppConfig` en Dart. Los identificadores diferentes permiten instalar ambos entornos por separado.

Para ejecutar el entorno de producción:

```powershell
flutter run --flavor prod --dart-define=FLAVOR=prod
```

## Generar el APK

```powershell
flutter build apk --release --flavor prod --dart-define=FLAVOR=prod
```

Archivo generado: `build/app/outputs/flutter-apk/app-prod-release.apk`.

La versión de compilación se define en `pubspec.yaml`; la versión mostrada en la interfaz se define en `lib/core/constants/app_strings.dart`. Mantén ambas sincronizadas. Android toma `versionName` y `versionCode` de la versión de Flutter; para actualizar una instalación, el número después de `+` debe aumentar.

### Firma de release

Release usa una clave PKCS12 propia, con el alias `mi-presupuesto`. Para crearla una sola vez, ejecuta en PowerShell e introduce la contraseña cuando `keytool` la solicite:

```powershell
keytool -genkeypair -v -keystore "$env:USERPROFILE\.android\mi-presupuesto-release.p12" -storetype PKCS12 -alias mi-presupuesto -keyalg RSA -keysize 3072 -validity 10000
```

Conserva una copia segura del keystore y su contraseña fuera del repositorio. Para compilar localmente, crea `android/key.properties` (ignorado por Git):

```properties
storeFile=C:/Users/TU_USUARIO/.android/mi-presupuesto-release.p12
storePassword=TU_CONTRASENA
```

`key.properties` usa el formato Java Properties: los caracteres especiales, como las barras invertidas, requieren escape. También puedes proporcionar `RELEASE_KEYSTORE_PATH` y `RELEASE_KEYSTORE_PASSWORD` como variables de entorno; tienen prioridad sobre el archivo local. PKCS12 usa la misma contraseña para el almacén y la clave.

Configura estos valores del repositorio para GitHub Actions:

| Tipo | Nombre | Contenido |
| --- | --- | --- |
| Secret | `ANDROID_RELEASE_KEYSTORE_BASE64` | Keystore de release codificado en Base64 |
| Secret | `ANDROID_RELEASE_PASSWORD` | Contraseña del keystore |
| Variable | `ANDROID_RELEASE_CERT_SHA256` | SHA-256 del certificado: 64 caracteres hexadecimales en minúsculas, sin `:` |

Obtén la huella pública con `keytool -list -v -keystore "$env:USERPROFILE\.android\mi-presupuesto-release.p12" -alias mi-presupuesto`. El workflow verifica el certificado restaurado y la firma del APK antes de publicarlo. El secret anterior `ANDROID_DEBUG_KEYSTORE_BASE64` ya no se utiliza.

El cambio desde las versiones firmadas con debug requiere respaldar los datos, desinstalar, instalar el primer APK con la nueva firma y restaurar el respaldo. Después, conserva esta misma clave para permitir actualizaciones normales.

### Publicar una nueva versión

El workflow `.github/workflows/android-release.yml` se ejecuta al subir un tag `v*`. Subir cambios a `main` por sí solo no inicia una publicación. Para cada versión, crea un tag nuevo; conserva los tags publicados sin moverlos ni reutilizarlos.

1. Actualiza `pubspec.yaml` y `lib/core/constants/app_strings.dart`. Por ejemplo: `version: 1.1.3+17` y `appVersion = '1.1.3'`. Aumenta siempre el número después de `+` y conserva la misma clave de release, sus secrets y la variable del certificado.
2. Verifica los cambios, crea el commit y súbelo a `main` (o fusiona el PR). El commit del tag debe pertenecer al historial de `main`.
3. Desde el commit que deseas publicar, crea y sube el tag. Debe coincidir con la versión de `pubspec.yaml` antes del `+`:

   ```powershell
   git switch main
   git pull --ff-only origin main
   git tag -a v1.1.3 -m "Release 1.1.3"
   git push origin v1.1.3
   ```

4. En GitHub Actions, comprueba que `Android Release APK` termine correctamente. El workflow ejecuta análisis y pruebas, valida el certificado, compila el APK, verifica su firma y crea una release en borrador con el APK adjunto.
5. Descarga el APK del borrador y prueba la actualización sin desinstalar la versión anterior firmada con la misma clave. Comprueba versión, funciones afectadas y conservación de datos. Después, abre la release en GitHub y pulsa **Publish release**, dejando desmarcada la opción de prerelease si es una versión estable.

Los valores `1.1.3+17` y `v1.1.3` son un ejemplo; sustitúyelos en publicaciones posteriores. Si necesitas reconstruir un tag existente con una corrección del workflow, usa Actions → **Android Release APK** → **Run workflow**, selecciona `main` y escribe el tag existente. Esa ejecución usa el workflow de `main` y compila el código del tag. **Re-run jobs** usa la revisión original del workflow; no incorpora correcciones posteriores. El paso actual de creación de release no reemplaza una release que ya exista: revisa ese caso antes de reconstruirla.

## Estructura del proyecto

```text
lib/
├── main.dart          # Inicialización de Hive, notificaciones y zona horaria
├── app/               # AppState, navegación y configuración de la aplicación
├── core/              # Base de datos, servicios, modelos y utilidades compartidas
└── features/          # Funcionalidades organizadas por dominio
test/                  # Pruebas automatizadas
docs/                  # Documentación técnica
assets/                # Recursos gráficos
```

Las funcionalidades se organizan en `movimientos`, `presupuestos`, `categorias`, `tipo_categorias`, `ingresos`, `historial`, `ajustes`, `notificaciones` y `recordatorios`, con componentes comunes en `shared`.

### Flujo de datos

```text
Interfaz → AppState (Provider) → Repositorio → Data source local → SQLite
```

`AppState` recarga los datos afectados y notifica a la interfaz después de las operaciones. Los servicios de respaldo y notificaciones también tienen acceso a persistencia.

| Componente | Archivo o directorio |
| --- | --- |
| Estado compartido | `lib/app/app_state.dart` |
| Configuración y rutas | `lib/app/app.dart` |
| Configuración del entorno | `lib/core/config/app_config.dart` |
| Esquema SQLite | `lib/core/database/db_tables.dart` |
| Servicios | `lib/core/services/` |

## Buscar actualizaciones (Android)

En **Sobre la aplicación → Buscar actualizaciones**, la app consulta la última release estable publicada de `Alejo-P/app_control_financiero`. El repositorio debe ser público: no se incluye un token de GitHub en la aplicación. Los borradores y las prereleases no se ofrecen como actualizaciones.

Cada nueva release debe adjuntar `mi-presupuesto-vX.Y.Z.apk` y `update.json`. El workflow genera ambos archivos; el JSON contiene `version`, `buildNumber`, `file`, `size` y `sha256`. Deben coincidir con el APK de producción firmado, y el número de build debe superar al instalado. No adjuntes manualmente un manifiesto de otra compilación. Revisa las notas de la release antes de publicarla: se muestran como novedades dentro de la aplicación.

La descarga muestra progreso, tamaño, velocidad media y tiempo estimado. **Cancelar**, volver atrás, salir de la vista, minimizar, bloquear o cerrar la aplicación cancela la transferencia; no hay un servicio de descarga en segundo plano ni reanudación. Los archivos incompletos se eliminan al cancelar, o al próximo inicio si Android terminó el proceso. El caché de actualizaciones se limpia al iniciar la app.

Antes de habilitar **Instalar**, se comprueban tamaño, SHA-256, identificador de aplicación, versión, build y certificado de firma del APK. Se exige el mismo certificado de la instalación actual; la rotación de claves no está contemplada. Android realiza la validación final al instalar. Las compilaciones `dev` no reciben APKs de producción; una instalación con firma debug tampoco puede actualizarse con la firma de release.

Al pulsar **Instalar**, Android puede solicitar **Permitir desde esta fuente**. Al regresar se comprueba el permiso de nuevo, sin repetir automáticamente la pantalla si se rechazó. Abrir ajustes o el instalador conserva el APK ya verificado. El usuario confirma la instalación en el diálogo del sistema; abrir ese diálogo no se anuncia como instalación completada.

### Comprobación en un dispositivo

1. Instala una versión de producción firmada con la clave de release y conserva datos de prueba. Publica una versión superior con APK y manifiesto correspondientes.
2. Busca la actualización, comprueba las novedades e inicia la descarga. Cancela y repite; prueba también volver atrás y minimizar. Al regresar no debe continuar descargando.
3. Completa otra descarga. Prueba rechazar el permiso, volver a intentarlo y concederlo. No debe haber un bucle de ajustes ni perderse el archivo verificado.
4. Confirma la actualización en Android sin desinstalar. Abre la app y comprueba la versión y los datos conservados.
5. Comprueba falta de conexión, ausencia de release pública y descarga interrumpida. Debe ofrecer reintentar y nunca anunciar que está actualizada ante un error.

## Datos y respaldos

Los datos financieros se almacenan localmente en SQLite (`control_financiero.db`), en el directorio de documentos de la aplicación. Hive almacena parte del estado local.

Los respaldos cifrados requieren el archivo y la contraseña elegida al crearlos. La contraseña no se guarda y, si se pierde, no se puede recuperar el respaldo. Restaurar un respaldo reemplaza los datos actuales; guarda una copia antes de hacerlo. Consulta el [formato de respaldos](docs/backup-format.md) para los detalles técnicos y la comprobación manual.

El esquema se crea al abrir una base nueva. Actualmente no hay una migración `onUpgrade` activa; cualquier cambio de esquema debe contemplar cómo preservar los datos de instalaciones existentes.

## Verificación

Ejecuta el análisis estático y las pruebas:

```powershell
flutter analyze
flutter test
```

Para comprobar una funcionalidad concreta y revisar el diff:

```powershell
flutter test test/features/presupuestos/budget_transfer_test.dart
git diff --check
```

Las pruebas cubren estado, widgets, búsquedas, transferencias, categorías, recordatorios, notificaciones y respaldos. La entrega real de notificaciones y el comportamiento de permisos requieren comprobación en un dispositivo.

## Trabajar en el repositorio

Consulta [AGENTS.md](AGENTS.md) para las reglas de arquitectura, cambios sensibles y verificación. Mantén las reglas de negocio en las capas de persistencia además de las validaciones de interfaz y añade pruebas para los riesgos o casos límite del cambio.
