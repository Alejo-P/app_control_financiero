# Envío de reportes por correo

La app sube el ZIP a `POST /reports`. El Worker envía el adjunto mediante Resend al destinatario fijo de `wrangler.jsonc`. La clave de Resend se guarda como secreto de Cloudflare y nunca se incluye en el APK.

## Configuración desde PowerShell

1. En esta carpeta, inicia sesión en Cloudflare:

   ```powershell
   npx wrangler login
   ```

2. En https://resend.com/api-keys crea una clave con permiso de envío. Después guárdala directamente en Cloudflare, pegándola únicamente en el campo que solicita este comando:

   ```powershell
   npx wrangler secret put RESEND_API_KEY
   ```

3. Despliega la función:

   ```powershell
   npm run deploy
   ```

4. La app ya usa por defecto la función desplegada en `https://mi-presupuesto-reportes.mi-presupuesto-pinzon.workers.dev/reports`. Desde la raíz del proyecto ejecuta:

   ```powershell
   flutter run --flavor dev --dart-define=FLAVOR=dev
   ```

   El APK de producción usa la misma URL por defecto. Para cambiar de servidor, añade `--dart-define=ERROR_REPORT_URL=https://TU-WORKER.workers.dev/reports` al comando de ejecución o compilación. Android tiene el permiso INTERNET en el manifiesto principal.

5. En Ajustes, abre “Notificar un error”, escribe una descripción y pulsa “Enviar reporte”. Comprueba el adjunto en tu correo y en Resend > Emails. El mensaje de la app confirma la aceptación del envío por Resend, no la entrega al buzón.

## Comprobaciones locales

```powershell
npm test
npm run check
```

`npm run check` empaqueta la función sin desplegarla ni enviar correos. Las pruebas usan un proveedor simulado.

## Comportamiento y límites

- Destinatario: el correo configurado en `REPORT_TO`. El cliente no puede cambiarlo.
- Remitente de prueba: `onboarding@resend.dev`; solo puede enviar al correo de la cuenta de Resend. Para un remitente de producción, configura un dominio verificado y cambia `REPORT_FROM`.
- Máximo: 4 MiB por ZIP. No se descomprime ni se almacena el adjunto en Cloudflare; se reenvía a Resend.
- Frecuencia: 3 solicitudes por minuto por IP y 10 por minuto para el servicio en cada ubicación de Cloudflare. Estos contadores son aproximados y no son un límite global de facturación. El endpoint es público: este control reduce abusos, pero no autentica la instalación de la app.
- El diálogo conserva el ZIP al reintentar sin modificar la descripción. Resend deduplica durante 24 horas usando el ID y el hash del ZIP. Cambiar la descripción o abrir un nuevo diálogo genera otro reporte.

Fuentes: [Secrets](https://developers.cloudflare.com/workers/configuration/secrets/), [Rate limits](https://developers.cloudflare.com/workers/runtime-apis/bindings/rate-limit/), [Resend API](https://resend.com/docs/api-reference/emails/send-email).
