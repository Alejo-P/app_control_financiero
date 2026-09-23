# Recordatorios y validación móvil

La inicialización solicita autorización en Android y configura permisos y
presentación en iOS. Denegar el permiso no impide iniciar la aplicación.

Los recordatorios diarios, semanales, mensuales y anuales se repiten mediante
el calendario nativo cuando la primera coincidencia respeta la fecha elegida.
Los meses sin el día elegido se omiten: el 31 de enero pasa al 31 de marzo;
el 29 de febrero anual pasa al siguiente año bisiesto.

El plugin calcula las coincidencias recurrentes desde hoy, sin respetar una
fecha de inicio posterior. Para evitar avisos anticipados, esos recordatorios
usan fechas individuales. Esto también permite omitir el aviso diario de hoy
si ya se registraron movimientos y conservar los avisos posteriores.

La cola reserva hasta 60 solicitudes en total, descontando otras notificaciones
pendientes para respetar el máximo de 64 en iOS. Se reserva primero una
ocurrencia por recordatorio (priorizando las más cercanas si no caben todos),
y luego las fechas diferidas más próximas. Abrir la aplicación, actualizar
recordatorios o cambiar movimientos repone la cola y permite pasar a repetición
nativa. **Las fechas individuales no se reponen con la app cerrada**: si se
agotan, hay que abrirla. Las reglas nativas no tienen ese horizonte de 60 avisos.

Desactivar o eliminar un recordatorio retira sus ocurrencias pendientes,
incluidas las fechas adicionales. La sincronización consulta el estado guardado
y se ejecuta en serie. Calcular la siguiente fecha no sobrescribe en SQLite
una edición o desactivación que esté ocurriendo a la vez.

## Validación en dispositivos

1. En una instalación de desarrollo nueva de Android 13 o posterior, iniciar,
   aceptar el permiso y programar un aviso para dentro de dos minutos. Repetir
   denegando el permiso: la aplicación debe seguir abriendo normalmente.
2. En iOS, iniciar, aceptar el permiso y comprobar un aviso con la app abierta
   y otro con la app en segundo plano. Requiere macOS/Xcode y un destino iOS.
3. Crear un recordatorio diario y uno semanal, cerrar la app normalmente y
   comprobar su primera y siguiente ocurrencia. Un inicio futuro no debe
   generar avisos antes de la fecha indicada. No usar «Forzar detención» de
   Android para esta prueba, pues el sistema suspende las alarmas de la app.
4. Desactivar el recordatorio diario y cambiar de mes: no debe volver a
   programarse. Con el diario habilitado, registrar un movimiento antes del
   aviso de hoy: debe omitirse hoy y conservar las fechas siguientes.
5. Asociar un recordatorio a una categoría personalizada sin movimientos ni
   presupuestos e intentar eliminarla: debe explicar la relación y mantener
   el formulario utilizable. Eliminar el recordatorio y repetir permite borrar
   la categoría si no tiene otras relaciones.

Las pruebas automatizadas usan canales de plataforma simulados; verifican
configuración, recurrencia y cancelación, pero no sustituyen la entrega real
de notificaciones en estos dispositivos.
