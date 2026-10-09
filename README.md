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

Actualmente, la compilación `release` utiliza la firma de depuración en `android/app/build.gradle.kts`. Configura una firma de distribución antes de publicar y conserva la misma firma para futuras actualizaciones.

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
