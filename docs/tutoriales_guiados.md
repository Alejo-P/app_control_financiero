# Tutoriales guiados

Dependencia: `showcaseview 5.1.0`. La guía se inicia después de montar los controles y finalizar la carga de la sección. No usa ni modifica el esquema SQLite.

## Recorridos

| Vista | Controles iniciales | Controles condicionados |
| --- | --- | --- |
| Movimientos | Notificaciones, búsqueda, mes, agregar, navegación inferior | Resumen, chips, uso del menú del primer movimiento visible (copiar/mover) |
| Presupuestos | Mes e ingreso presupuestado desde el AppBar | Agregar cuando el ingreso es positivo; resumen cuando hay tarjetas; tarjeta y menú cuando existe un presupuesto definido |
| Historial | Selector de año del AppBar | Detalle mensual y balance anual cuando existen movimientos |
| Más acciones | Excel, respaldo, restauración, categorías, recordatorios, modo oscuro, notificaciones, información de la app | Desplazamiento automático hasta cada opción |

## Persistencia y repetición

`TutorialProgress` guarda un mapa en `settings/tutoriales_v1` de Hive. Cada recorrido puede estar completado, omitido o pendiente (sin entrada). Los recorridos que requieren datos son independientes de la introducción de su vista.

Completar u omitir guarda únicamente el recorrido activo. Cerrar la app, enviarla al fondo, cambiar de pestaña o abrir otra ruta conserva pendiente un recorrido incompleto. Al regresar se reinicia desde su primer paso. Una ruta abierta desde notificaciones tiene prioridad sobre el tutorial de la pantalla principal.

**Más acciones → Ver tutoriales** borra únicamente ese mapa y regresa a Movimientos. Las guías de otras secciones se repiten al entrar a ellas; los pasos sin datos siguen pendientes.

Las claves de `Showcase` en la versión 5 identifican controladores. `TutorialTarget` mantiene otra clave para comprobar montaje, ruta y tamaño del objetivo. Un único `TutorialHost` registra el scope `tutoriales` y libera los recursos al desmontarse.

El tutorial explica el uso del menú contextual en un único paso, sin abrirlo ni guiar cada opción. Describe copiar y mover; las explicaciones no ejecutan operaciones.

## Verificación automática

```powershell
flutter test --no-pub test/core/tutorials test/widgets/record_actions_menu_test.dart test/widgets/widgets_container_test.dart
flutter analyze --no-pub
git diff --check
```

Las pruebas de widgets usan preferencias en memoria; las pruebas de persistencia abren Hive real y comprueban reapertura y reinicio. Se cubren las cuatro vistas reales, ingreso nulo/cero/positivo, aparición de datos, rutas superpuestas, segundo plano, menú contextual, repetición, modo oscuro y pantalla de 390 × 844 con texto al 130 %.

Integración inicial del 8 de octubre de 2026: 172 pruebas de la suite completa y 40 focalizadas pasaron. Tras simplificar el menú contextual, pasaron 39 pruebas focalizadas y el análisis de los archivos afectados no tuvo observaciones. La verificación en dispositivo sigue pendiente.

## Prueba en dispositivo pendiente

1. Abrir una instalación nueva: completar u omitir la introducción de Movimientos y reiniciar; comprobar que no se repite.
2. Crear un movimiento: recorrer resumen, filtros y explicación del menú; comprobar que el recorrido termina sin abrirlo.
3. Abrir Presupuestos sin ingreso, establecer un ingreso positivo y crear un presupuesto; comprobar los pasos diferidos.
4. Visitar Historial y Más acciones: comprobar el año y el desplazamiento hasta la última opción.
5. Tocar Ver tutoriales: comprobar repetición, salir al fondo y regresar; revisar tooltips con el tamaño de texto del dispositivo.

Referencia de la API: [documentación oficial de showcaseview](https://pub.dev/packages/showcaseview).
